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
app.config['MYSQL_PASSWORD'] = 'your passwd'
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
    cur.execute(
        "SELECT id, name, email, password, role FROM users WHERE id = %s",
        (user_id,)
    )
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
                status,
                projected_cost,
                actual_cost,
                final_score,
                notes,
                in_results
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
                'status': row[5],
                'projected_cost': float(row[6]) if row[6] is not None else None,
                'actual_cost': float(row[7]) if row[7] is not None else None,
                'final_score': row[8],
                'notes': row[9],
                'in_results': bool(row[10])
            }
            for row in rows
        ]
    except Exception:
        mysql.connection.rollback()
        cur.close()
        return []


def get_all_practices():
    cur = mysql.connection.cursor()
    try:
        cur.execute("""
            SELECT
                practice_id,
                title,
                practice_date,
                practice_time,
                location,
                contact_email,
                notes,
                status,
                projected_cost,
                actual_cost,
                in_results
            FROM practices
            ORDER BY practice_date, practice_time
        """)
        rows = cur.fetchall()
        cur.close()

        return [
            {
                'practice_id': row[0],
                'title': row[1],
                'practice_date': row[2],
                'practice_time': row[3],
                'location': row[4],
                'contact_email': row[5],
                'notes': row[6],
                'status': row[7],
                'projected_cost': float(row[8]) if row[8] is not None else None,
                'actual_cost': float(row[9]) if row[9] is not None else None,
                'in_results': bool(row[10])
            }
            for row in rows
        ]
    except Exception:
        mysql.connection.rollback()
        cur.close()
        return []


def build_game_comparisons(actual_games, projected_games):
    projected_map = {game['game_id']: game for game in projected_games}
    comparisons = []

    for actual in actual_games:
        projected = projected_map.get(actual['game_id'])
        projected_revenue = float(projected['projected_revenue']) if projected else 0.0
        projected_expenses = float(projected['projected_expenses']) if projected else 0.0
        projected_net = float(projected['projected_net']) if projected else 0.0

        actual_revenue = float(actual['total_revenue'])
        actual_expenses = float(actual['total_expenses'])
        actual_net = float(actual['net_result'])

        revenue_variance = actual_revenue - projected_revenue
        expense_variance = actual_expenses - projected_expenses

        revenue_variance_percent = (
            abs(revenue_variance) / projected_revenue * 100
            if projected_revenue > 0 else (100.0 if actual_revenue > 0 else 0.0)
        )
        expense_variance_percent = (
            abs(expense_variance) / projected_expenses * 100
            if projected_expenses > 0 else (100.0 if actual_expenses > 0 else 0.0)
        )

        comparisons.append({
            'game_id': actual['game_id'],
            'opponent': actual['opponent'],
            'game_date': actual['game_date'],
            'game_type': actual['game_type'],
            'status': actual['status'],
            'projected_revenue': projected_revenue,
            'actual_revenue': actual_revenue,
            'projected_expenses': projected_expenses,
            'actual_expenses': actual_expenses,
            'projected_net': projected_net,
            'actual_net': actual_net,
            'revenue_variance': revenue_variance,
            'expense_variance': expense_variance,
            'revenue_variance_percent': revenue_variance_percent,
            'expense_variance_percent': expense_variance_percent
        })

    return comparisons


def build_practice_comparisons(actual_practices, projected_practices):
    projected_map = {practice['practice_id']: practice for practice in projected_practices}
    comparisons = []

    for actual in actual_practices:
        projected = projected_map.get(actual['practice_id'])
        projected_revenue = float(projected['projected_revenue']) if projected else 0.0
        projected_expenses = float(projected['projected_expenses']) if projected else 0.0
        projected_net = float(projected['projected_net']) if projected else 0.0

        actual_revenue = float(actual['total_revenue'])
        actual_expenses = float(actual['total_expenses'])
        actual_net = float(actual['net_result'])

        revenue_variance = actual_revenue - projected_revenue
        expense_variance = actual_expenses - projected_expenses

        revenue_variance_percent = (
            abs(revenue_variance) / projected_revenue * 100
            if projected_revenue > 0 else (100.0 if actual_revenue > 0 else 0.0)
        )
        expense_variance_percent = (
            abs(expense_variance) / projected_expenses * 100
            if projected_expenses > 0 else (100.0 if actual_expenses > 0 else 0.0)
        )

        comparisons.append({
            'practice_id': actual['practice_id'],
            'title': actual['title'],
            'practice_date': actual['practice_date'],
            'practice_time': actual['practice_time'],
            'status': actual['status'],
            'projected_revenue': projected_revenue,
            'actual_revenue': actual_revenue,
            'projected_expenses': projected_expenses,
            'actual_expenses': actual_expenses,
            'projected_net': projected_net,
            'actual_net': actual_net,
            'revenue_variance': revenue_variance,
            'expense_variance': expense_variance,
            'revenue_variance_percent': revenue_variance_percent,
            'expense_variance_percent': expense_variance_percent
        })

    return comparisons

def get_all_alumni():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT alumni_id, name, email, grad_year, position, phone, occupation, donation_status
        FROM alumni
        ORDER BY grad_year DESC, name
    """)
    rows = cur.fetchall()
    cur.close()

    return [
        {
            'alumni_id': row[0],
            'name': row[1],
            'email': row[2],
            'grad_year': row[3],
            'position': row[4],
            'phone': row[5],
            'occupation': row[6],
            'donation_status': row[7]
        }
        for row in rows
    ]

def get_all_donations():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT d.donation_id, a.name, a.grad_year, d.amount, d.donation_date, d.message
        FROM donations d
        JOIN alumni a ON d.alumni_id = a.alumni_id
        ORDER BY d.donation_date DESC, d.donation_id DESC
    """)
    rows = cur.fetchall()
    cur.close()

    return [
        {
            'donation_id': row[0],
            'name': row[1],
            'grad_year': row[2],
            'amount': float(row[3]),
            'donation_date': row[4],
            'message': row[5]
        }
        for row in rows
    ]


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
        if current_user.role == 'Admin':
            return redirect(url_for('admin_page'))
        return redirect(url_for('home'))

    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')

        if not email or not password:
            flash('Please enter both email and password.', 'danger')
            return render_template('login.html')

        cur = mysql.connection.cursor()
        cur.execute(
            "SELECT id, name, email, password, role FROM users WHERE email = %s",
            (email,)
        )
        user_data = cur.fetchone()
        cur.close()

        if user_data and check_password_hash(user_data[3], password):
            user = User(*user_data)
            login_user(user)
            flash(f'Welcome, {user.name}!', 'success')

            if user.role == 'Supplier':
                return redirect(url_for('supplier_page'))
            if user.role == 'Admin':
                return redirect(url_for('admin_page'))
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
    practices = get_all_practices()
    return render_template('schedule.html', games=games, practices=practices)


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
        cur.execute("""
            SELECT
                COALESCE(SUM(CASE WHEN entry_type = 'Revenue' THEN amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN entry_type = 'Expense' THEN amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN entry_type = 'Revenue' THEN amount ELSE -amount END), 0)
            FROM financial_entries
        """)
        totals_row = cur.fetchone()
        totals = {
            'total_revenue': float(totals_row[0] or 0),
            'total_expenses': float(totals_row[1] or 0),
            'net_balance': float(totals_row[2] or 0)
        }

        cur.execute("""
            SELECT
                COALESCE(SUM(CASE WHEN projection_type = 'Revenue' THEN projected_amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN projection_type = 'Expense' THEN projected_amount ELSE 0 END), 0)
            FROM financial_projections
            WHERE game_id IS NOT NULL OR practice_id IS NOT NULL
        """)
        projected_row = cur.fetchone()
        projections = {
            'projected_revenue': float(projected_row[0] or 0),
            'projected_expenses': float(projected_row[1] or 0)
        }

        cur.execute("""
            SELECT
                g.game_id,
                g.opponent,
                g.game_date,
                g.game_type,
                g.status,
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Revenue' THEN fe.amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Expense' THEN fe.amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Revenue' THEN fe.amount ELSE -fe.amount END), 0)
            FROM games g
            LEFT JOIN financial_entries fe ON g.game_id = fe.game_id
            GROUP BY g.game_id, g.opponent, g.game_date, g.game_type, g.status
            ORDER BY g.game_date
        """)
        actual_games_raw = cur.fetchall()
        actual_games = [
            {
                'game_id': row[0],
                'opponent': row[1],
                'game_date': row[2],
                'game_type': row[3],
                'status': row[4],
                'total_revenue': float(row[5] or 0),
                'total_expenses': float(row[6] or 0),
                'net_result': float(row[7] or 0)
            }
            for row in actual_games_raw
        ]

        cur.execute("""
            SELECT
                g.game_id,
                g.opponent,
                g.game_date,
                g.game_type,
                g.status,
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Revenue' THEN fp.projected_amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Expense' THEN fp.projected_amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Revenue' THEN fp.projected_amount ELSE -fp.projected_amount END), 0)
            FROM games g
            LEFT JOIN financial_projections fp ON g.game_id = fp.game_id
            GROUP BY g.game_id, g.opponent, g.game_date, g.game_type, g.status
            ORDER BY g.game_date
        """)
        projected_games_raw = cur.fetchall()
        projected_games = [
            {
                'game_id': row[0],
                'opponent': row[1],
                'game_date': row[2],
                'game_type': row[3],
                'status': row[4],
                'projected_revenue': float(row[5] or 0),
                'projected_expenses': float(row[6] or 0),
                'projected_net': float(row[7] or 0)
            }
            for row in projected_games_raw
        ]

        game_comparisons = build_game_comparisons(actual_games, projected_games)

        cur.execute("""
            SELECT
                p.practice_id,
                p.title,
                p.practice_date,
                p.practice_time,
                p.status,
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Revenue' THEN fe.amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Expense' THEN fe.amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fe.entry_type = 'Revenue' THEN fe.amount ELSE -fe.amount END), 0)
            FROM practices p
            LEFT JOIN financial_entries fe ON p.practice_id = fe.practice_id
            GROUP BY p.practice_id, p.title, p.practice_date, p.practice_time, p.status
            ORDER BY p.practice_date, p.practice_time
        """)
        actual_practices_raw = cur.fetchall()
        actual_practices = [
            {
                'practice_id': row[0],
                'title': row[1],
                'practice_date': row[2],
                'practice_time': row[3],
                'status': row[4],
                'total_revenue': float(row[5] or 0),
                'total_expenses': float(row[6] or 0),
                'net_result': float(row[7] or 0)
            }
            for row in actual_practices_raw
        ]

        cur.execute("""
            SELECT
                p.practice_id,
                p.title,
                p.practice_date,
                p.practice_time,
                p.status,
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Revenue' THEN fp.projected_amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Expense' THEN fp.projected_amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN fp.projection_type = 'Revenue' THEN fp.projected_amount ELSE -fp.projected_amount END), 0)
            FROM practices p
            LEFT JOIN financial_projections fp ON p.practice_id = fp.practice_id
            GROUP BY p.practice_id, p.title, p.practice_date, p.practice_time, p.status
            ORDER BY p.practice_date, p.practice_time
        """)
        projected_practices_raw = cur.fetchall()
        projected_practices = [
            {
                'practice_id': row[0],
                'title': row[1],
                'practice_date': row[2],
                'practice_time': row[3],
                'status': row[4],
                'projected_revenue': float(row[5] or 0),
                'projected_expenses': float(row[6] or 0),
                'projected_net': float(row[7] or 0)
            }
            for row in projected_practices_raw
        ]

        practice_comparisons = build_practice_comparisons(actual_practices, projected_practices)

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
            WHERE fe.game_id IS NULL AND fe.practice_id IS NULL
            ORDER BY fe.entry_date DESC, fe.entry_id DESC
        """)
        general_entries_raw = cur.fetchall()
        general_entries = [
            {
                'entry_id': row[0],
                'entry_type': row[1],
                'amount': float(row[2] or 0),
                'description': row[3],
                'entry_date': row[4],
                'category_name': row[5]
            }
            for row in general_entries_raw
        ]

        cur.execute("""
            SELECT game_id, opponent, game_date
            FROM games
            ORDER BY game_date
        """)
        games_raw = cur.fetchall()
        games = [
            {
                'game_id': row[0],
                'label': f"{row[1]} - {row[2]}"
            }
            for row in games_raw
        ]

        cur.execute("""
            SELECT practice_id, title, practice_date, practice_time
            FROM practices
            ORDER BY practice_date, practice_time
        """)
        practices_raw = cur.fetchall()
        practices = [
            {
                'practice_id': row[0],
                'label': f"{row[1]} - {row[2]} {row[3]}"
            }
            for row in practices_raw
        ]

        cur.execute("""
            SELECT category_id, category_name, category_type
            FROM financial_categories
            ORDER BY category_type, category_name
        """)
        categories_raw = cur.fetchall()
        categories = [
            {
                'category_id': row[0],
                'category_name': row[1],
                'category_type': row[2]
            }
            for row in categories_raw
        ]

        cur.execute("""
            SELECT
                fc.category_name,
                COALESCE(SUM(fe.amount), 0) AS total_amount
            FROM financial_entries fe
            JOIN financial_categories fc ON fe.category_id = fc.category_id
            WHERE fe.entry_type = 'Revenue'
            GROUP BY fc.category_name
            ORDER BY total_amount DESC
        """)
        annual_revenue_breakdown_raw = cur.fetchall()
        annual_revenue_breakdown = [
            {
                'category_name': row[0],
                'total_amount': float(row[1] or 0)
            }
            for row in annual_revenue_breakdown_raw
        ]

        cur.execute("""
            SELECT
                fc.category_name,
                COALESCE(SUM(fe.amount), 0) AS total_amount
            FROM financial_entries fe
            JOIN financial_categories fc ON fe.category_id = fc.category_id
            WHERE fe.entry_type = 'Expense'
            GROUP BY fc.category_name
            ORDER BY total_amount DESC
        """)
        annual_expense_breakdown_raw = cur.fetchall()
        annual_expense_breakdown = [
            {
                'category_name': row[0],
                'total_amount': float(row[1] or 0)
            }
            for row in annual_expense_breakdown_raw
        ]

        return render_template(
            'finances.html',
            totals=totals,
            projections=projections,
            actual_games=actual_games,
            projected_games=projected_games,
            game_comparisons=game_comparisons,
            actual_practices=actual_practices,
            projected_practices=projected_practices,
            practice_comparisons=practice_comparisons,
            general_entries=general_entries,
            games=games,
            practices=practices,
            categories=categories,
            annual_revenue_breakdown=annual_revenue_breakdown,
            annual_expense_breakdown=annual_expense_breakdown
        )

    except Exception as e:
        flash(f'Could not load financial data: {e}', 'danger')
        return render_template(
            'finances.html',
            totals={'total_revenue': 0, 'total_expenses': 0, 'net_balance': 0},
            projections={'projected_revenue': 0, 'projected_expenses': 0},
            actual_games=[],
            projected_games=[],
            game_comparisons=[],
            actual_practices=[],
            projected_practices=[],
            practice_comparisons=[],
            general_entries=[],
            games=[],
            practices=[],
            categories=[],
            annual_revenue_breakdown=[],
            annual_expense_breakdown=[]
        )
    finally:
        cur.close()


@app.route('/game_details/<int:game_id>')
@login_required
@role_required('Admin', 'Coach')
def game_details(game_id):
    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            SELECT
                game_id,
                opponent,
                game_date,
                location,
                game_type,
                status,
                projected_cost,
                actual_cost,
                final_score,
                notes,
                in_results
            FROM games
            WHERE game_id = %s
        """, (game_id,))
        game_row = cur.fetchone()

        if not game_row:
            return jsonify({'error': 'Game not found'}), 404

        game = {
            'game_id': game_row[0],
            'opponent': game_row[1],
            'game_date': str(game_row[2]),
            'location': game_row[3],
            'game_type': game_row[4],
            'status': game_row[5],
            'projected_cost': float(game_row[6]) if game_row[6] is not None else None,
            'actual_cost': float(game_row[7]) if game_row[7] is not None else None,
            'final_score': game_row[8],
            'notes': game_row[9],
            'in_results': bool(game_row[10])
        }

        cur.execute("""
            SELECT
                fe.entry_id,
                fe.game_id,
                fe.practice_id,
                fe.entry_type,
                fe.amount,
                fe.description,
                fe.entry_date,
                fc.category_name,
                fc.category_type
            FROM financial_entries fe
            JOIN financial_categories fc ON fe.category_id = fc.category_id
            WHERE fe.game_id = %s
            ORDER BY fe.entry_date, fe.entry_id
        """, (game_id,))
        actual_rows = cur.fetchall()

        actual_entries = []
        actual_revenue = 0.0
        actual_expenses = 0.0

        for row in actual_rows:
            amount = float(row[4] or 0)
            actual_entries.append({
                'entry_id': row[0],
                'game_id': row[1],
                'practice_id': row[2],
                'entry_type': row[3],
                'amount': amount,
                'description': row[5],
                'entry_date': str(row[6]),
                'category_name': row[7],
                'category_type': row[8]
            })
            if row[3] == 'Revenue':
                actual_revenue += amount
            else:
                actual_expenses += amount

        cur.execute("""
            SELECT
                fp.projection_id,
                fp.game_id,
                fp.practice_id,
                fp.projection_type,
                fp.projected_amount,
                fp.notes,
                fp.projection_date,
                fc.category_name,
                fc.category_type
            FROM financial_projections fp
            JOIN financial_categories fc ON fp.category_id = fc.category_id
            WHERE fp.game_id = %s
            ORDER BY fp.projection_date, fp.projection_id
        """, (game_id,))
        projection_rows = cur.fetchall()

        projected_entries = []
        projected_revenue = 0.0
        projected_expenses = 0.0

        for row in projection_rows:
            amount = float(row[4] or 0)
            projected_entries.append({
                'projection_id': row[0],
                'game_id': row[1],
                'practice_id': row[2],
                'projection_type': row[3],
                'projected_amount': amount,
                'notes': row[5],
                'projection_date': str(row[6]),
                'category_name': row[7],
                'category_type': row[8]
            })
            if row[3] == 'Revenue':
                projected_revenue += amount
            else:
                projected_expenses += amount

        return jsonify({
            'game': game,
            'actual_entries': actual_entries,
            'projected_entries': projected_entries,
            'actual_totals': {
                'revenue': actual_revenue,
                'expenses': actual_expenses,
                'net': actual_revenue - actual_expenses
            },
            'projected_totals': {
                'revenue': projected_revenue,
                'expenses': projected_expenses,
                'net': projected_revenue - projected_expenses
            }
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cur.close()


@app.route('/practice_details/<int:practice_id>')
@login_required
@role_required('Admin', 'Coach')
def practice_details(practice_id):
    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            SELECT
                practice_id,
                title,
                practice_date,
                practice_time,
                location,
                contact_email,
                notes,
                status,
                projected_cost,
                actual_cost,
                in_results
            FROM practices
            WHERE practice_id = %s
        """, (practice_id,))
        practice_row = cur.fetchone()

        if not practice_row:
            return jsonify({'error': 'Practice not found'}), 404

        practice = {
            'practice_id': practice_row[0],
            'title': practice_row[1],
            'practice_date': str(practice_row[2]),
            'practice_time': str(practice_row[3]),
            'location': practice_row[4],
            'contact_email': practice_row[5],
            'notes': practice_row[6],
            'status': practice_row[7],
            'projected_cost': float(practice_row[8]) if practice_row[8] is not None else None,
            'actual_cost': float(practice_row[9]) if practice_row[9] is not None else None,
            'in_results': bool(practice_row[10])
        }

        cur.execute("""
            SELECT
                fe.entry_id,
                fe.game_id,
                fe.practice_id,
                fe.entry_type,
                fe.amount,
                fe.description,
                fe.entry_date,
                fc.category_name,
                fc.category_type
            FROM financial_entries fe
            JOIN financial_categories fc ON fe.category_id = fc.category_id
            WHERE fe.practice_id = %s
            ORDER BY fe.entry_date, fe.entry_id
        """, (practice_id,))
        actual_rows = cur.fetchall()

        actual_entries = []
        actual_revenue = 0.0
        actual_expenses = 0.0

        for row in actual_rows:
            amount = float(row[4] or 0)
            actual_entries.append({
                'entry_id': row[0],
                'game_id': row[1],
                'practice_id': row[2],
                'entry_type': row[3],
                'amount': amount,
                'description': row[5],
                'entry_date': str(row[6]),
                'category_name': row[7],
                'category_type': row[8]
            })
            if row[3] == 'Revenue':
                actual_revenue += amount
            else:
                actual_expenses += amount

        cur.execute("""
            SELECT
                fp.projection_id,
                fp.game_id,
                fp.practice_id,
                fp.projection_type,
                fp.projected_amount,
                fp.notes,
                fp.projection_date,
                fc.category_name,
                fc.category_type
            FROM financial_projections fp
            JOIN financial_categories fc ON fp.category_id = fc.category_id
            WHERE fp.practice_id = %s
            ORDER BY fp.projection_date, fp.projection_id
        """, (practice_id,))
        projection_rows = cur.fetchall()

        projected_entries = []
        projected_revenue = 0.0
        projected_expenses = 0.0

        for row in projection_rows:
            amount = float(row[4] or 0)
            projected_entries.append({
                'projection_id': row[0],
                'game_id': row[1],
                'practice_id': row[2],
                'projection_type': row[3],
                'projected_amount': amount,
                'notes': row[5],
                'projection_date': str(row[6]),
                'category_name': row[7],
                'category_type': row[8]
            })
            if row[3] == 'Revenue':
                projected_revenue += amount
            else:
                projected_expenses += amount

        return jsonify({
            'practice': practice,
            'actual_entries': actual_entries,
            'projected_entries': projected_entries,
            'actual_totals': {
                'revenue': actual_revenue,
                'expenses': actual_expenses,
                'net': actual_revenue - actual_expenses
            },
            'projected_totals': {
                'revenue': projected_revenue,
                'expenses': projected_expenses,
                'net': projected_revenue - projected_expenses
            }
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cur.close()

@app.route('/alumni')
@app.route('/alumni.html')
@login_required
@role_required('Admin', 'Coach')
def alumni():
    alumni = get_all_alumni()
    donations = get_all_donations()
    total_donations = sum(d['amount'] for d in donations)

    return render_template(
        'alumni.html',
        alumni=alumni,
        donations=donations,
        total_donations=total_donations
    )

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
# ADD GAME / PRACTICE
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
    projected_cost = request.form.get('projected_cost')
    notes = request.form.get('notes', '').strip()

    if not opponent or not game_date or not location or not game_type or not status:
        flash('Please fill in all required game fields.', 'danger')
        return redirect(url_for('schedule'))

    if projected_cost == '':
        projected_cost = None

    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            INSERT INTO games (
                opponent,
                game_date,
                location,
                game_type,
                status,
                projected_cost,
                notes
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (opponent, game_date, location, game_type, status, projected_cost, notes))
        mysql.connection.commit()
        flash('Game added successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not add game: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('schedule'))


@app.route('/add_practice', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_practice():
    title = request.form.get('title', '').strip()
    practice_date = request.form.get('practice_date')
    practice_time = request.form.get('practice_time')
    location = request.form.get('location', '').strip()
    contact_email = request.form.get('contact_email', '').strip()
    notes = request.form.get('notes', '').strip()
    status = request.form.get('status', 'Scheduled').strip()
    projected_cost = request.form.get('projected_cost')

    if not title or not practice_date or not practice_time or not location:
        flash('Please fill in all required practice fields.', 'danger')
        return redirect(url_for('schedule'))

    if projected_cost == '':
        projected_cost = None

    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            INSERT INTO practices (
                title,
                practice_date,
                practice_time,
                location,
                contact_email,
                notes,
                status,
                projected_cost
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (title, practice_date, practice_time, location, contact_email, notes, status, projected_cost))
        mysql.connection.commit()
        flash('Practice added successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not add practice: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('schedule'))


@app.route('/update_game_results/<int:game_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def update_game_results(game_id):
    actual_cost = request.form.get('actual_cost')
    final_score = request.form.get('final_score', '').strip()
    status = request.form.get('status', 'Completed').strip()
    in_results = 1 if request.form.get('in_results') in ('1', 'true', 'True', 'on', 'yes') else 0

    if actual_cost == '':
        actual_cost = None
    if final_score == '':
        final_score = None

    cur = mysql.connection.cursor()
    try:
        cur.execute("""
            UPDATE games
            SET actual_cost = %s,
                final_score = %s,
                status = %s,
                in_results = %s
            WHERE game_id = %s
        """, (actual_cost, final_score, status, in_results, game_id))
        mysql.connection.commit()
        flash('Game results updated successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not update game results: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('schedule'))


@app.route('/update_practice_results/<int:practice_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def update_practice_results(practice_id):
    actual_cost = request.form.get('actual_cost')
    status = request.form.get('status', 'Completed').strip()
    in_results = 1 if request.form.get('in_results') in ('1', 'true', 'True', 'on', 'yes') else 0

    if actual_cost == '':
        actual_cost = None

    cur = mysql.connection.cursor()
    try:
        cur.execute("""
            UPDATE practices
            SET actual_cost = %s,
                status = %s,
                in_results = %s
            WHERE practice_id = %s
        """, (actual_cost, status, in_results, practice_id))
        mysql.connection.commit()
        flash('Practice results updated successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not update practice results: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('schedule'))


@app.route('/move_game_to_results/<int:game_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def move_game_to_results(game_id):
    cur = mysql.connection.cursor()
    try:
        cur.execute("""
            UPDATE games
            SET in_results = 1,
                status = 'Completed'
            WHERE game_id = %s
        """, (game_id,))
        mysql.connection.commit()
        flash('Game moved to results.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not move game to results: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('schedule'))


@app.route('/move_practice_to_results/<int:practice_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def move_practice_to_results(practice_id):
    cur = mysql.connection.cursor()
    try:
        cur.execute("""
            UPDATE practices
            SET in_results = 1,
                status = 'Completed'
            WHERE practice_id = %s
        """, (practice_id,))
        mysql.connection.commit()
        flash('Practice moved to results.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not move practice to results: {e}', 'danger')
    finally:
        cur.close()

    return redirect(url_for('schedule'))


# ---------------------------
# FINANCIAL ENTRIES / PROJECTIONS
# ---------------------------
@app.route('/add_financial_entry', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_financial_entry():
    game_id = request.form.get('game_id')
    practice_id = request.form.get('practice_id')
    category_id = request.form.get('category_id')
    entry_type = request.form.get('entry_type')
    amount = request.form.get('amount')
    description = request.form.get('description', '').strip()
    entry_date = request.form.get('entry_date')

    if not category_id or not entry_type or not amount or not entry_date:
        flash('Please complete all required fields for the financial entry.', 'danger')
        return redirect(url_for('finances'))

    if game_id == '':
        game_id = None
    if practice_id == '':
        practice_id = None

    if game_id and practice_id:
        flash('An entry cannot be linked to both a game and a practice.', 'danger')
        return redirect(url_for('finances'))

    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            INSERT INTO financial_entries (
                game_id,
                practice_id,
                category_id,
                entry_type,
                amount,
                description,
                entry_date
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            game_id,
            practice_id,
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


@app.route('/add_financial_projection', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_financial_projection():
    game_id = request.form.get('game_id')
    practice_id = request.form.get('practice_id')
    category_id = request.form.get('category_id')
    projection_type = request.form.get('projection_type')
    projected_amount = request.form.get('projected_amount')
    notes = request.form.get('notes', '').strip()
    projection_date = request.form.get('projection_date')

    if not category_id or not projection_type or not projected_amount or not projection_date:
        flash('Please complete all required fields for the projection.', 'danger')
        return redirect(url_for('finances'))

    if game_id == '':
        game_id = None
    if practice_id == '':
        practice_id = None

    if not game_id and not practice_id:
        flash('Projections must be linked to a game or a practice.', 'danger')
        return redirect(url_for('finances'))

    if game_id and practice_id:
        flash('A projection cannot be linked to both a game and a practice.', 'danger')
        return redirect(url_for('finances'))

    cur = mysql.connection.cursor()

    try:
        cur.execute("""
            INSERT INTO financial_projections (
                game_id,
                practice_id,
                category_id,
                projection_type,
                projected_amount,
                notes,
                projection_date
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            game_id,
            practice_id,
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

# --------------
# ADD ALUMNI 
# --------------
@app.route('/add_alumni', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def add_alumni():
    first_name = request.form['first_name']
    last_name = request.form['last_name']
    name = f"{first_name} {last_name}"

    grad_year = request.form.get('grad_year')
    position = request.form.get('position')
    email = request.form.get('email')
    occupation = request.form.get('occupation')
    phone = request.form.get('phone')
    donation_status = request.form.get('donation_status')

    cur = mysql.connection.cursor()
    cur.execute("""
        INSERT INTO alumni (name, email, grad_year, position, phone, occupation, donation_status)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (name, email, grad_year, position, phone, occupation, donation_status))
    mysql.connection.commit()
    cur.close()

    return redirect(url_for('alumni'))


@app.route('/delete_financial_entry/<int:entry_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def delete_financial_entry(entry_id):
    cur = mysql.connection.cursor()
    try:
        cur.execute("DELETE FROM financial_entries WHERE entry_id = %s", (entry_id,))
        mysql.connection.commit()
        flash('Financial entry deleted successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not delete financial entry: {e}', 'danger')
    finally:
        cur.close()
    return redirect(url_for('finances'))


@app.route('/delete_financial_projection/<int:projection_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def delete_financial_projection(projection_id):
    cur = mysql.connection.cursor()
    try:
        cur.execute("DELETE FROM financial_projections WHERE projection_id = %s", (projection_id,))
        mysql.connection.commit()
        flash('Financial projection deleted successfully.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not delete financial projection: {e}', 'danger')
    finally:
        cur.close()
    return redirect(url_for('finances'))


@app.route('/delete_game/<int:game_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def delete_game(game_id):
    next_page = request.form.get('next_page', 'finances')

    cur = mysql.connection.cursor()
    try:
        cur.execute("DELETE FROM financial_entries WHERE game_id = %s", (game_id,))
        cur.execute("DELETE FROM financial_projections WHERE game_id = %s", (game_id,))
        cur.execute("DELETE FROM games WHERE game_id = %s", (game_id,))
        mysql.connection.commit()
        flash('Game and all related financial data were deleted.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not delete game: {e}', 'danger')
    finally:
        cur.close()

    if next_page == 'schedule':
        return redirect(url_for('schedule'))
    return redirect(url_for('finances'))


@app.route('/delete_practice/<int:practice_id>', methods=['POST'])
@login_required
@role_required('Admin', 'Coach')
def delete_practice(practice_id):
    next_page = request.form.get('next_page', 'finances')

    cur = mysql.connection.cursor()
    try:
        cur.execute("DELETE FROM financial_entries WHERE practice_id = %s", (practice_id,))
        cur.execute("DELETE FROM financial_projections WHERE practice_id = %s", (practice_id,))
        cur.execute("DELETE FROM practices WHERE practice_id = %s", (practice_id,))
        mysql.connection.commit()
        flash('Practice and all related financial data were deleted.', 'success')
    except Exception as e:
        mysql.connection.rollback()
        flash(f'Could not delete practice: {e}', 'danger')
    finally:
        cur.close()

    if next_page == 'schedule':
        return redirect(url_for('schedule'))
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


@app.route('/user/<int:user_id>', methods=['DELETE'])
@login_required
@role_required('Admin')
def delete_user(user_id):
    try:
        cur = mysql.connection.cursor()
        cur.execute("DELETE FROM users WHERE id = %s", (user_id,))
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


if __name__ == '__main__':
    app.run(debug=True)
