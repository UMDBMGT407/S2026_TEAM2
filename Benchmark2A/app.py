from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_mysqldb import MySQL
from werkzeug.security import check_password_hash
from functools import wraps
import MySQLdb.cursors

app = Flask(__name__)

# =========================
# Flask / MySQL Config
# =========================
app.secret_key = 'your_secret_key_here'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'ebabumba1'
app.config['MYSQL_DB'] = 'user_management'

mysql = MySQL(app)

# =========================
# Helpers
# =========================
def normalize_role(role):
    return role.strip().lower() if role else ''

def get_dashboard_by_role(role):
    role = normalize_role(role)

    if role == 'admin':
        return 'admin_page'
    elif role == 'coach':
        return 'coach_page'
    elif role == 'player':
        return 'player_page'
    elif role == 'supplier':
        return 'supplier_page'
    return 'login'

def get_all_users():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("SELECT id, name, email, role FROM users ORDER BY id ASC")
    users = cur.fetchall()
    cur.close()
    return users

# =========================
# Helper Decorators
# =========================
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('loggedin'):
            flash('Please log in first.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def role_required(*allowed_roles):
    normalized_allowed_roles = [normalize_role(role) for role in allowed_roles]

    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not session.get('loggedin'):
                flash('Please log in first.', 'warning')
                return redirect(url_for('login'))

            user_role = normalize_role(session.get('role'))

            if user_role not in normalized_allowed_roles:
                flash('You do not have permission to access that page.', 'danger')
                return redirect(url_for(get_dashboard_by_role(user_role)))

            return f(*args, **kwargs)
        return decorated_function
    return decorator

# =========================
# Root Route
# =========================
@app.route('/')
def root():
    return redirect(url_for('login'))

# =========================
# Login / Logout
# =========================
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cur.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cur.fetchone()
        cur.close()

        if user and check_password_hash(user['password'], password):
            role = normalize_role(user['role'])

            session['loggedin'] = True
            session['id'] = user['id']
            session['name'] = user['name']
            session['email'] = user['email']
            session['role'] = role.capitalize()

            flash('Login successful.', 'success')

            if role == 'admin':
                return redirect(url_for('admin_page'))
            elif role == 'coach':
                return redirect(url_for('coach_page'))
            elif role == 'player':
                return redirect(url_for('player_page'))
            elif role == 'supplier':
                return redirect(url_for('supplier_page'))
            else:
                session.clear()
                flash('Invalid role assigned to this account.', 'danger')
                return redirect(url_for('login'))

        flash('Invalid email or password.', 'danger')
        return redirect(url_for('login'))

    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.', 'info')
    return redirect(url_for('login'))

# =========================
# Dashboard Routes
# =========================
@app.route('/admin')
@login_required
@role_required('Admin')
def admin_page():
    return render_template('admin-dashboard.html')

@app.route('/admin-dashboard')
@login_required
@role_required('Admin')
def admin_dashboard():
    return render_template('admin-dashboard.html')

@app.route('/admin_dashboard')
@login_required
@role_required('Admin')
def admin_dashboard_underscore():
    return render_template('admin-dashboard.html')

@app.route('/coach')
@login_required
@role_required('Coach', 'Admin')
def coach_page():
    users = get_all_users()
    return render_template('home.html', users=users)

@app.route('/coach-dashboard')
@login_required
@role_required('Coach', 'Admin')
def coach_dashboard():
    users = get_all_users()
    return render_template('home.html', users=users)

@app.route('/coach_dashboard')
@login_required
@role_required('Coach', 'Admin')
def coach_dashboard_underscore():
    users = get_all_users()
    return render_template('home.html', users=users)

@app.route('/player')
@login_required
@role_required('Player', 'Admin')
def player_page():
    users = get_all_users()
    return render_template('home.html', users=users)

@app.route('/player-dashboard')
@login_required
@role_required('Player', 'Admin')
def player_dashboard():
    users = get_all_users()
    return render_template('home.html', users=users)

@app.route('/player_dashboard')
@login_required
@role_required('Player', 'Admin')
def player_dashboard_underscore():
    users = get_all_users()
    return render_template('home.html', users=users)

@app.route('/supplier')
@login_required
@role_required('Supplier', 'Admin')
def supplier_page():
    return render_template('supplier.html')

@app.route('/supplier-dashboard')
@login_required
@role_required('Supplier', 'Admin')
def supplier_dashboard():
    return render_template('supplier.html')

@app.route('/supplier_dashboard')
@login_required
@role_required('Supplier', 'Admin')
def supplier_dashboard_underscore():
    return render_template('supplier.html')

# =========================
# General Site Pages
# =========================
@app.route('/public')
@login_required
def public_page():
    return render_template('index.html')

@app.route('/index')
@login_required
def index():
    return render_template('index.html')

@app.route('/home')
@login_required
def home():
    users = get_all_users()
    return render_template('home.html', users=users)

@app.route('/equipment')
@login_required
def equipment():
    return render_template('equipment.html')

@app.route('/finances')
@login_required
@role_required('Admin', 'Coach')
def finances():
    return render_template('finances.html')

@app.route('/newsletters')
@login_required
def newsletters():
    return render_template('newsletters.html')

@app.route('/alumni')
@login_required
def alumni():
    return render_template('alumni.html')

@app.route('/schedule')
@login_required
def schedule():
    return render_template('schedule.html')

# =========================
# Roster Route
# =========================
@app.route('/roster')
@login_required
def roster():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cur.execute("""
        SELECT
            players.player_id,
            users.name,
            players.jersey_number,
            players.position,
            players.year,
            players.injured,
            users.email,
            players.phone
        FROM players
        JOIN users ON players.user_id = users.id
        WHERE LOWER(TRIM(users.role)) = %s
    """, ('player',))
    players = cur.fetchall()
    cur.close()

    return render_template('roster.html', players=players)

# =========================
# Run App
# =========================
if __name__ == '__main__':
    app.run(debug=True)
