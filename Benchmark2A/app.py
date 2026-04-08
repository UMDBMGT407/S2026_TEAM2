from flask import Flask, request, jsonify, render_template, redirect, abort
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
app.config['MYSQL_PASSWORD'] = 'passwd'
app.config['MYSQL_DB'] = 'user_management'

mysql = MySQL(app)

# ---------------------------
# LOGIN CONFIG
# ---------------------------
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'


# ---------------------------
# USER CLASS
# ---------------------------
class User(UserMixin):
    def __init__(self, id, name, email, password, role):
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.role = role


@login_manager.user_loader
def load_user(user_id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
    user_data = cur.fetchone()
    cur.close()

    if user_data:
        return User(*user_data)
    return None


# ---------------------------
# ROLE CHECK
# ---------------------------
def role_required(*roles):
    def wrapper(fn):
        @wraps(fn)
        def decorated_view(*args, **kwargs):
            if not current_user.is_authenticated or current_user.role not in roles:
                return abort(403)
            return fn(*args, **kwargs)
        return decorated_view
    return wrapper


# ---------------------------
# ROUTES
# ---------------------------

# LOGIN
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE email = %s", (email,))
        user_data = cur.fetchone()
        cur.close()

        if user_data and check_password_hash(user_data[3], password):
            user = User(*user_data)
            login_user(user)
            return redirect('/')
        else:
            return render_template('login.html', error='Invalid credentials')

    return render_template('login.html')


# LOGOUT
@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect('/login')


# HOME
@app.route('/')
@login_required
def home():
    return render_template('admin-dashboard.html')


# ---------------------------
# PAGE ROUTES
# ---------------------------

@app.route('/schedule')
@login_required
@role_required('Admin', 'Coach', 'Player')
def schedule():
    return render_template('schedule.html')


@app.route('/roster')
@login_required
@role_required('Admin', 'Coach', 'Player')
def roster():
    return render_template('roster.html')


@app.route('/equipment')
@login_required
@role_required('Admin', 'Coach')
def equipment():
    return render_template('equipment.html')


@app.route('/admin')
@login_required
@role_required('Admin')
def admin_page():
    return render_template('admin-dashboard.html')

@app.route('/finances')
@login_required
@role_required('Admin', 'Coach')
def finances():
    return render_template('finances.html')


@app.route('/alumni')
@login_required
@role_required('Admin', 'Coach')
def alumni():
    return render_template('alumni.html')


@app.route('/newsletters')
@login_required
@role_required('Admin', 'Coach')
def newsletters():
    return render_template('newsletters.html')


@app.route('/supplier')
@login_required
@role_required('Admin', 'Coach')
def supplier():
    return render_template('supplier.html')


# ---------------------------
# USER MANAGEMENT ROUTES
# ---------------------------

# ADD USER - Admin only
@app.route('/user', methods=['POST'])
@login_required
@role_required('Admin')
def add_user():
    if request.is_json:
        data = request.get_json()

        name = data['name']
        email = data['email']
        password = generate_password_hash(data.get('password', 'test123'))
        role = data.get('role', 'Player')

        cur = mysql.connection.cursor()
        sql = "INSERT INTO users (name, email, password, role) VALUES (%s, %s, %s, %s)"
        cur.execute(sql, (name, email, password, role))
        mysql.connection.commit()
        cur.close()

        return jsonify(message="User added successfully"), 201

    return jsonify(error="Invalid submission"), 400


# GET USERS - all logged-in users
@app.route('/users', methods=['GET'])
@login_required
def get_users():
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, name, email, role FROM users")
    users = cur.fetchall()
    cur.close()

    user_dicts = []
    for user in users:
        user_data = {
            'id': user[0],
            'name': user[1],
            'role': user[3]
        }

        # Only Admin can see emails
        if current_user.role == 'Admin':
            user_data['email'] = user[2]

        user_dicts.append(user_data)

    return jsonify(user_dicts)


# DELETE USER - Admin only
@app.route('/user/<int:id>', methods=['DELETE'])
@login_required
@role_required('Admin')
def delete_user(id):
    cur = mysql.connection.cursor()
    cur.execute("DELETE FROM users WHERE id = %s", [id])
    mysql.connection.commit()
    cur.close()

    return jsonify(message="User deleted successfully")


# ---------------------------
# ERROR HANDLER
# ---------------------------
@app.errorhandler(403)
def forbidden(error):
    return "403 Forbidden: You do not have permission to access this page.", 403


# ---------------------------
# RUN APP
# ---------------------------
if __name__ == '__main__':
    app.run(debug=True)
