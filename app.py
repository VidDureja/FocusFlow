from flask import Flask, render_template, request, jsonify, session, redirect, url_for, Response, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta, timezone
import json
import os
import csv
# import pandas as pd  # Commented out for deployment without pandas
# import numpy as np  # Commented out for deployment without numpy
from io import BytesIO
from collections import defaultdict, Counter

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-change-this-in-production'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/pomodoro.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Database Models
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    is_premium = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    sessions = db.relationship('PomodoroSession', backref='user', lazy=True)

class PomodoroSession(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    start_time = db.Column(db.DateTime, nullable=False)
    end_time = db.Column(db.DateTime)
    duration = db.Column(db.Integer)  # in minutes
    session_type = db.Column(db.String(20))  # 'work', 'break', 'long_break'
    completed = db.Column(db.Boolean, default=False)
    notes = db.Column(db.Text)
    tag = db.Column(db.String(32), default='General')  # New: session tag/category

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        data = request.get_json()
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        
        if User.query.filter_by(username=username).first():
            return jsonify({'error': 'Username already exists'}), 400
        
        if User.query.filter_by(email=email).first():
            return jsonify({'error': 'Email already exists'}), 400
        
        user = User(
            username=username,
            email=email,
            password_hash=generate_password_hash(password)
        )
        db.session.add(user)
        db.session.commit()
        
        login_user(user)
        return jsonify({'success': True, 'redirect': '/dashboard'})
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        
        user = User.query.filter_by(username=username).first()
        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            return jsonify({'success': True, 'redirect': '/dashboard'})
        
        return jsonify({'error': 'Invalid username or password'}), 401
    
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('index'))

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html')

@app.route('/api/session', methods=['POST'])
@login_required
def create_session():
    data = request.get_json()
    session_type = data.get('type', 'work')
    duration = data.get('duration', 25)
    
    session = PomodoroSession(
        user_id=current_user.id,
        start_time=datetime.now(timezone.utc),
        session_type=session_type,
        duration=duration
    )
    db.session.add(session)
    db.session.commit()
    
    return jsonify({'session_id': session.id})

@app.route('/api/session/<int:session_id>/complete', methods=['POST'])
@login_required
def complete_session(session_id):
    session = PomodoroSession.query.get_or_404(session_id)
    if session.user_id != current_user.id:
        return jsonify({'error': 'Unauthorized'}), 403
    
    session.end_time = datetime.utcnow()
    session.completed = True
    db.session.commit()
    
    return jsonify({'success': True})

@app.route('/api/analytics')
@login_required
def get_analytics():
    # Get user's sessions for the last 30 days
    thirty_days_ago = datetime.now(timezone.utc) - timedelta(days=30)
    sessions = PomodoroSession.query.filter(
        PomodoroSession.user_id == current_user.id,
        PomodoroSession.start_time >= thirty_days_ago
    ).all()
    
    total_sessions = len(sessions)
    total_minutes = sum(s.duration for s in sessions if s.completed)
    completed_sessions = len([s for s in sessions if s.completed])
    
    # Daily breakdown
    daily_data = {}
    for session in sessions:
        date = session.start_time.date().isoformat()
        if date not in daily_data:
            daily_data[date] = {'sessions': 0, 'minutes': 0}
        daily_data[date]['sessions'] += 1
        if session.completed:
            daily_data[date]['minutes'] += session.duration
    
    return jsonify({
        'total_sessions': total_sessions,
        'completed_sessions': completed_sessions,
        'total_minutes': total_minutes,
        'completion_rate': (completed_sessions / total_sessions * 100) if total_sessions > 0 else 0,
        'daily_data': daily_data
    })

@app.route('/api/premium/upgrade', methods=['POST'])
@login_required
def upgrade_premium():
    # In a real app, you'd integrate with Stripe or another payment processor
    current_user.is_premium = True
    db.session.commit()
    return jsonify({'success': True})

@app.route('/api/export/csv')
@login_required
def export_sessions_csv():
    sessions = PomodoroSession.query.filter_by(user_id=current_user.id).all()
    def generate():
        data = [
            ['id', 'start_time', 'end_time', 'duration', 'session_type', 'completed', 'notes', 'tag']
        ]
        for s in sessions:
            data.append([
                s.id,
                s.start_time.isoformat() if s.start_time else '',
                s.end_time.isoformat() if s.end_time else '',
                s.duration,
                s.session_type,
                s.completed,
                s.notes or '',
                s.tag or ''
            ])
        for row in data:
            yield ','.join(map(str, row)) + '\n'
    return Response(generate(), mimetype='text/csv', headers={
        'Content-Disposition': 'attachment; filename=focusflow_sessions.csv'
    })

# Comment out or stub any analytics endpoints that use pandas or numpy
@app.route('/api/analytics/heatmap')
@login_required
def productivity_heatmap():
    # sessions = PomodoroSession.query.filter_by(user_id=current_user.id, completed=True).all()
    # heatmap = defaultdict(lambda: [0]*24)  # day_of_week: [hour0, hour1, ...]
    # for s in sessions:
    #     if s.start_time:
    #         dow = s.start_time.weekday()
    #         hour = s.start_time.hour
    #         heatmap[dow][hour] += 1
    # return jsonify(heatmap)
    return jsonify({'message': 'Heatmap analytics temporarily disabled (no pandas/numpy).'}), 501

@app.route('/api/analytics/best_hours')
@login_required
def best_focus_hours():
    # sessions = PomodoroSession.query.filter_by(user_id=current_user.id, completed=True).all()
    # hour_counts = Counter()
    # for s in sessions:
    #     if s.start_time:
    #         hour_counts[s.start_time.hour] += 1
    # return jsonify(hour_counts)
    return jsonify({'message': 'Best hours analytics temporarily disabled (no pandas/numpy).'}), 501

@app.route('/api/analytics/longest_streak')
@login_required
def longest_streak():
    # sessions = PomodoroSession.query.filter_by(user_id=current_user.id, completed=True).order_by(PomodoroSession.start_time).all()
    # streak = max_streak = 0
    # last_date = None
    # for s in sessions:
    #     date = s.start_time.date()
    #     if last_date is None or (date - last_date).days == 1:
    #         streak += 1
    #     else:
    #         streak = 1
    #     max_streak = max(max_streak, streak)
    #     last_date = date
    # return jsonify({'longest_streak': max_streak})
    return jsonify({'message': 'Longest streak analytics temporarily disabled (no pandas/numpy).'}), 501

@app.route('/api/analytics/completion_by_tag')
@login_required
def completion_by_tag():
    # sessions = PomodoroSession.query.filter_by(user_id=current_user.id).all()
    # tag_counts = Counter()
    # for s in sessions:
    #     tag_counts[s.tag or 'General'] += int(s.completed)
    # return jsonify(tag_counts)
    return jsonify({'message': 'Completion by tag analytics temporarily disabled (no pandas/numpy).'}), 501

@app.route('/api/analytics/recommendation')
@login_required
def recommendation():
    # sessions = PomodoroSession.query.filter_by(user_id=current_user.id, completed=True).all()
    # hour_counts = Counter()
    # for s in sessions:
    #     if s.start_time:
    #         hour_counts[s.start_time.hour] += 1
    # if hour_counts:
    #     best_hour = hour_counts.most_common(1)[0][0]
    #     return jsonify({'recommendation': f'You focus best around {best_hour}:00. Try scheduling deep work then.'})
    # return jsonify({'recommendation': 'Not enough data yet. Complete more sessions!'})
    return jsonify({'message': 'Recommendation analytics temporarily disabled (no pandas/numpy).'}), 501

@app.route('/api/export/pdf')
@login_required
def export_pdf():
    # Stub for PDF export (would use reportlab in a real implementation)
    return jsonify({'message': 'PDF export coming soon!'}), 501

@app.route('/api/email/weekly_summary')
@login_required
def email_weekly_summary():
    # Stub for weekly email summary (would use Flask-Mail/SendGrid in a real implementation)
    return jsonify({'message': 'Weekly email summary coming soon!'}), 501

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8010)

# Ensure tables are created on every startup (for Render)
with app.app_context():
    db.create_all() 