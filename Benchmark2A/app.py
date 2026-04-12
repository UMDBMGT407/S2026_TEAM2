from flask import Flask, request, jsonify, render_template, redirect, abort, flash, url_for
from flask_mysqldb import MySQL
from flask_login import LoginManager, login_user, logout_user, login_required, current_user, UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps

app = Flask(__name__)
app.secret_key = 'bmgt407_hockey_secret_key'

# ---------------------------
# MySQL CONFIG
# ---------------------------
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Acciaio1!'
app.config['MYSQL_DB'] = 'user_management'

mysql = MySQL(app)

# ---------------------------
# LOGIN CONFIG
# ---------------------------
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = None


# ---------------------------
# USER CLASS
# ---------------------------
class User(UserMixin):
    def __init__(self, id, name, email, password, role):
        self.id = str(id)
        self.name = name
        self.email = email
        self.password = password
        self.role = role


@login_manager.user_loader
def load_user(user_id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, name, email, password, role FROM users WHERE id = %s", (user_id,))
    user_data = cur.fetchone()
    cur.close()

    if user_data:
        return User(*user_data)
    return None


# ---------------------------
# HELPERS
# ---------------------------
def role_required(*roles):
    def wrapper(fn):
        @wraps(fn)
        def decorated_view(*args, **kwargs):
            if not current_user.is_authenticated:
                return redirect(url_for('login'))
            if current_user.role not in roles:
                return abort(403)
            return fn(*args, **kwargs)
        return decorated_view
    return wrapper


def get_all_players():
    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            SELECT
                p.jersey_number,
                u.name,
                p.position,
                p.year,
                p.injured,
                u.email,
                p.phone
            FROM players p
            JOIN users u ON p.user_id = u.id
            ORDER BY p.jersey_number IS NULL, p.jersey_number, u.name
        """)
        rows = cur.fetchall()
        cur.close()

        return [
            {
                'jersey_number': row[0],
                'name': row[1],
                'position': row[2],
                'year': row[3],
                'injured': bool(row[4]),
                'email': row[5],
                'phone': row[6],
            }
            for row in rows
        ]
    except Exception:
        mysql.connection.rollback()
        cur.close()
        return []


def get_all_games():
    cur = mysql.connection.cursor()
    try:
        cur.execute("""
            SELECT
                game_id,
                opponent,
                game_date,
                location,
                game_type,
                status
            FROM games
            ORDER BY game_date
        """)
        rows = cur.fetchall()
        cur.close()

        return [
            {
                'game_id': row[0],
                'opponent': row[1],
                'game_date': row[2],
                'location': row[3],
                'game_type': row[4],
                'status': row[5]
            }
            for row in rows
        ]
    except Exception:
        mysql.connection.rollback()
        cur.close()
        return []


# ---------------------------
# ROOT / PUBLIC ROUTES
# ---------------------------
@app.route('/')
def root():
    return redirect(url_for('login'))


@app.route('/index')
@app.route('/index.html')
def public_page():
    return render_template('index.html')


# ---------------------------
# AUTH ROUTES
# ---------------------------
@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        if current_user.role == 'Supplier':
            return redirect(url_for('supplier_page'))
        elif current_user.role == 'Admin':
            return redirect(url_for('admin_page'))
        else:
            return redirect(url_for('home'))

    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')

        if not email or not password:
            flash('Please enter both email and password.', 'danger')
            return render_template('login.html')

        cur = mysql.connection.cursor()
        cur.execute("SELECT id, name, email, password, role FROM users WHERE email = %s", (email,))
        user_data = cur.fetchone()
        cur.close()

        if user_data and check_password_hash(user_data[3], password):
            user = User(*user_data)
            login_user(user)
            flash(f'Welcome, {user.name}!', 'success')

            if user.role == 'Supplier':
                return redirect(url_for('supplier_page'))
            elif user.role == 'Admin':
                return redirect(url_for('admin_page'))
            else:
                return redirect(url_for('home'))

        flash('Invalid email or password.', 'danger')

    return render_template('login.html')


@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.', 'info')
    return redirect(url_for('login'))


# ---------------------------
# MAIN PAGES
# ---------------------------
@app.route('/home')
@login_required
def home():
    return render_template('admin-dashboard.html')


@app.route('/admin')
@app.route('/admin-dashboard')
@app.route('/admin-dashboard.html')
@login_required
@role_required('Admin')
def admin_page():
    return render_template('admin-dashboard.html')


@app.route('/schedule')
@app.route('/schedule.html')
@login_required
@role_required('Admin', 'Coach', 'Player')
def schedule():
    games = get_all_games()
    return render_template('schedule.html', games=games)


@app.route('/calendar')
@app.route('/calendar.html')
@login_required
@role_required('Admin', 'Coach', 'Player')
def calendar():
    return render_template('calendar.html')


@app.route('/roster')
@app.route('/roster.html')
@login_required
@role_required('Admin', 'Coach', 'Player')
def roster():
    players = get_all_players()
    return render_template('roster.html', players=players)


@app.route('/equipment')
@app.route('/equipment.html')
@login_required
@role_required('Admin', 'Coach')
def equipment():
    return render_template('equipment.html')


@app.route('/finances')
@app.route('/finances.html')
@login_required
@role_required('Admin', 'Coach')
def finances():
    cur = mysql.connection.cursor()

    try:
        # Overall actual totals
        cur.execute("""
            SELECT
                COALESCE(SUM(CASE WHEN entry_type = 'Revenue' THEN amount ELSE 0 END), 0) AS total_revenue,
                COALESCE(SUM(CASE WHEN entry_type = 'Expense' THEN amount ELSE 0 END), 0) AS total_expenses,
                COALESCE(SUM(CASE WHEN entry_type = 'Revenue' THEN amount ELSE -amount END), 0) AS net_balance
            FROM financial_entries
        """)
        totals_row = cur.fetchone()

        totals = {
            'total_revenue': float(totals_row[0] or 0),
            'total_expenses': float(totals_row[1] or 0),
            'net_balance': float(totals_row[2] or 0)
        }

        # Overall projected totals
        cur.execute("""
            SELECT
                COALESCE(SUM(CASE WHEN projection_type = 'Revenue' THEN projected_amount ELSE 0 END), 0) AS projected_revenue,
                COALESCE(SUM(CASE WHEN projection_type = 'Expense' THEN projected_amount ELSE 0 END), 0) AS projected_expenses
            FROM financial_projections
        """)
        projected_row = cur.fetchone()

        projections = {
            'projected_revenue': float(projected_row[0] or 0),
            'projected_expenses': float(projected_row[1] or 0)
        }

        # Actual result by game
        cur.execute("""
            SELECT
                g.game_id,
                g.opponent,
                g.game_date,
                g.game_type,
                g.status,
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Revenue' THEN fe.amount ELSE 0 END), 0) AS total_revenue,
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Expense' THEN fe.amount ELSE 0 END), 0) AS total_expenses,
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Revenue' THEN fe.amount ELSE -fe.amount END), 0) AS net_result
            FROM games g
            LEFT JOIN financial_entries fe ON g.game_id = fe.game_id
            GROUP BY g.game_id, g.opponent, g.game_date, g.game_type, g.status
            ORDER BY g.game_date
        """)
        actual_games_raw = cur.fetchall()

        actual_games = []
        for row in actual_games_raw:
            actual_games.append({
                'game_id': row[0],
                'opponent': row[1],
                'game_date': row[2],
                'game_type': row[3],
                'status': row[4],
                'total_revenue': float(row[5] or 0),
                'total_expenses': float(row[6] or 0),
                'net_result': float(row[7] or 0)
            })

        # Projected result by game
        cur.execute("""
            SELECT
                g.game_id,
                g.opponent,
                g.game_date,
                g.game_type,
                g.status,
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Revenue' THEN fp.projected_amount ELSE 0 END), 0) AS projected_revenue,
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Expense' THEN fp.projected_amount ELSE 0 END), 0) AS projected_expenses,
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Revenue' THEN fp.projected_amount ELSE -fp.projected_amount END), 0) AS projected_net
            FROM games g
            LEFT JOIN financial_projections fp ON g.game_id = fp.game_id
            GROUP BY g.game_id, g.opponent, g.game_date, g.game_type, g.status
            ORDER BY g.game_date
        """)
        projected_games_raw = cur.fetchall()

        projected_games = []
        for row in projected_games_raw:
            projected_games.append({
                'game_id': row[0],
                'opponent': row[1],
                'game_date': row[2],
                'game_type': row[3],
                'status': row[4],
                'projected_revenue': float(row[5] or 0),
                'projected_expenses': float(row[6] or 0),
                'projected_net': float(row[7] or 0)
            })

        # General non-game entries
        cur.execute("""
            SELECT
                fe.entry_id,
                fe.entry_type,
                fe.amount,
                fe.description,
                fe.entry_date,
                fc.category_name
            FROM financial_entries fe
            JOIN financial_categories fc ON fe.category_id = fc.category_id
            WHERE fe.game_id IS NULL
            ORDER BY fe.entry_date DESC, fe.entry_id DESC
        """)
        general_entries_raw = cur.fetchall()

        general_entries = []
        for row in general_entries_raw:
            general_entries.append({
                'entry_id': row[0],
                'entry_type': row[1],
                'amount': float(row[2] or 0),
                'description': row[3],
                'entry_date': row[4],
                'category_name': row[5]
            })

        # Games for modal dropdown
        cur.execute("""
            SELECT game_id, opponent, game_date
            FROM games
            ORDER BY game_date
        """)
        games_raw = cur.fetchall()

        games = []
        for row in games_raw:
            games.append({
                'game_id': row[0],
                'label': f"{row[1]} - {row[2]}"
            })

        # Categories for modal dropdown
        cur.execute("""
            SELECT category_id, category_name, category_type
            FROM financial_categories
            ORDER BY category_type, category_name
        """)
        categories_raw = cur.fetchall()

        categories = []
        for row in categories_raw:
            categories.append({
                'category_id': row[0],
                'category_name': row[1],
                'category_type': row[2]
            })

        return render_template(
            'finances.html',
            totals=totals,
            projections=projections,
            actual_games=actual_games,
            projected_games=projected_games,
            general_entries=general_entries,
            games=games,
            categories=categories
        )

    except Exception as e:
        flash(f'Could not load financial data: {e}', 'danger')
        return render_template(
            'finances.html',
            totals={'total_revenue': 0, 'total_expenses': 0, 'net_balance': 0},
            projections={'projected_revenue': 0, 'projected_expenses': 0},
            actual_games=[],
            projected_games=[],
            general_entries=[],
            games=[],
            categories=[]
        )
    finally:
        cur.close()


@app.route('/alumni')
@app.route('/alumni.html')
@login_required
@role_required('Admin', 'Coach')
def alumni():
    return render_template('alumni.html')


@app.route('/newsletters')
@app.route('/newsletters.html')
@login_required
@role_required('Admin', 'Coach')
def newsletters():
    return render_template('newsletters.html')


@app.route('/supplier')
@app.route('/supplier.html')
@login_required
@role_required('Admin', 'Supplier')
def supplier_page():
    return render_template('supplier.html')


# ---------------------------
# ADD PLAYER
# ---------------------------
@app.route('/add_player', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_player():
    name = request.form.get('name', '').strip()
    jersey_number = request.form.get('jersey_number', '').strip()
    position = request.form.get('position', '').strip()
    year = request.form.get('year', '').strip()
    injured = 1 if request.form.get('injured') in ('1', 'true', 'True', 'yes', 'on') else 0
    email = request.form.get('email', '').strip()
    phone = request.form.get('phone', '').strip()

    if not name or not position or not year or not email:
        flash('Please fill in all required fields.', 'danger')
        return redirect(url_for('roster'))

    if jersey_number == '':
        jersey_number = None

    cur = mysql.connection.cursor()

    try:
        hashed_password = generate_password_hash('test123')

        cur.execute("""
            INSERT INTO users (name, email, password, role)
            VALUES (%s, %s, %s, %s)
        """, (name, email, hashed_password, 'Player'))

        user_id = cur.lastrowid

        cur.execute("""
            INSERT INTO players (user_id, jersey_number, position, year, injured, phone)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (user_id, jersey_number, position, year, injured, phone))

        mysql.connection.commit()
        flash('Player added successfully.', 'success')

    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not add player: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('roster'))


# ---------------------------
# ADD GAME
# ---------------------------
@app.route('/add_game', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_game():
    opponent = request.form.get('opponent', '').strip()
    game_date = request.form.get('game_date')
    location = request.form.get('location', '').strip()
    game_type = request.form.get('game_type', '').strip()
    status = request.form.get('status', '').strip()

    if not opponent or not game_date or not location or not game_type or not status:
        flash('Please fill in all required game fields.', 'danger')
        return redirect(url_for('schedule'))

    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            INSERT INTO games (opponent, game_date, location, game_type, status)
            VALUES (%s, %s, %s, %s, %s)
        """, (opponent, game_date, location, game_type, status))

        mysql.connection.commit()
        flash('Game added successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not add game: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('schedule'))


# ---------------------------
# ADD ACTUAL FINANCIAL ENTRY
# ---------------------------
@app.route('/add_financial_entry', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_financial_entry():
    game_id = request.form.get('game_id')
    category_id = request.form.get('category_id')
    entry_type = request.form.get('entry_type')
    amount = request.form.get('amount')
    description = request.form.get('description', '').strip()
    entry_date = request.form.get('entry_date')

    if not category_id or not entry_type or not amount or not entry_date:
        flash('Please complete all required fields for the financial entry.', 'danger')
        return redirect(url_for('finances'))

    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            INSERT INTO financial_entries (game_id, category_id, entry_type, amount, description, entry_date)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            game_id if game_id else None,
            category_id,
            entry_type,
            amount,
            description,
            entry_date
        ))
        mysql.connection.commit()
        flash('Financial entry added successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not add financial entry: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('finances'))


# ---------------------------
# ADD FINANCIAL PROJECTION
# ---------------------------
@app.route('/add_financial_projection', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_financial_projection():
    game_id = request.form.get('game_id')
    category_id = request.form.get('category_id')
    projection_type = request.form.get('projection_type')
    projected_amount = request.form.get('projected_amount')
    notes = request.form.get('notes', '').strip()
    projection_date = request.form.get('projection_date')

    if not category_id or not projection_type or not projected_amount or not projection_date:
        flash('Please complete all required fields for the projection.', 'danger')
        return redirect(url_for('finances'))

    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            INSERT INTO financial_projections (game_id, category_id, projection_type, projected_amount, notes, projection_date)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            game_id if game_id else None,
            category_id,
            projection_type,
            projected_amount,
            notes,
            projection_date
        ))
        mysql.connection.commit()
        flash('Financial projection added successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not add financial projection: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('finances'))


# ---------------------------
# USER MANAGEMENT
# ---------------------------
@app.route('/user', methods=['POST'])
@login_required
@role_required('Admin')
def add_user():
    data = request.get_json(silent=True)
    if not data:
        return jsonify(error='Invalid submission'), 400

    name = data.get('name', '').strip()
    email = data.get('email', '').strip()
    password = data.get('password', 'test123')
    role = data.get('role', 'Player').strip()

    if not name or not email or not role:
        return jsonify(error='Name, email, and role are required.'), 400

    hashed_password = generate_password_hash(password)

    try:
        cur = mysql.connection.cursor()
        cur.execute("""
            INSERT INTO users (name, email, password, role)
            VALUES (%s, %s, %s, %s)
        """, (name, email, hashed_password, role))
        mysql.connection.commit()
        cur.close()
        return jsonify(message='User added successfully'), 201
    except Exception as e:
        mysql.connection.rollback()
        return jsonify(error=str(e)), 400


@app.route('/users', methods=['GET'])
@login_required
def get_users():
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, name, email, role FROM users ORDER BY name")
    users = cur.fetchall()
    cur.close()

    user_dicts = []
    for user in users:
        item = {
            'id': user[0],
            'name': user[1],
            'role': user[3]
        }

        if current_user.role == 'Admin':
            item['email'] = user[2]

        user_dicts.append(item)

    return jsonify(user_dicts)


@app.route('/user/<int:id>', methods=['DELETE'])
@login_required
@role_required('Admin')
def delete_user(id):
    try:
        cur = mysql.connection.cursor()
        cur.execute("DELETE FROM users WHERE id = %s", (id,))
        mysql.connection.commit()
        cur.close()
        return jsonify(message='User deleted successfully')
    except Exception as e:
        mysql.connection.rollback()
        return jsonify(error=str(e)), 400


# ---------------------------
# ERROR HANDLERS
# ---------------------------
@app.errorhandler(403)
def forbidden(error):
    return "403 Forbidden: You do not have permission to access this page.", 403


@app.errorhandler(404)
def not_found(error):
    return "404 Not Found: The page you requested does not exist.", 404


# ---------------------------
# RUN APP
# ---------------------------
if __name__ == '__main__':
    app.run(debug=True)
