// PWA Service Worker Registration
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/static/sw.js')
      .then((registration) => {
        console.log('SW registered: ', registration);
      })
      .catch((registrationError) => {
        console.log('SW registration failed: ', registrationError);
      });
  });
}

// PWA Install Prompt
let deferredPrompt;
const installButton = document.getElementById('install-button');

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  
  if (installButton) {
    installButton.style.display = 'block';
    installButton.addEventListener('click', () => {
      deferredPrompt.prompt();
      deferredPrompt.userChoice.then((choiceResult) => {
        if (choiceResult.outcome === 'accepted') {
          console.log('User accepted the install prompt');
        } else {
          console.log('User dismissed the install prompt');
        }
        deferredPrompt = null;
        installButton.style.display = 'none';
      });
    });
  }
});

// Offline/Online Status
window.addEventListener('online', () => {
  showNotification('You are back online!', 'success');
  syncOfflineData();
});

window.addEventListener('offline', () => {
  showNotification('You are offline. Some features may be limited.', 'warning');
});

// Local Storage for Offline Data
const OFFLINE_STORAGE_KEY = 'focusflow_offline_data';

function saveOfflineData(data) {
  try {
    const existingData = JSON.parse(localStorage.getItem(OFFLINE_STORAGE_KEY) || '[]');
    existingData.push({
      ...data,
      timestamp: Date.now()
    });
    localStorage.setItem(OFFLINE_STORAGE_KEY, JSON.stringify(existingData));
  } catch (error) {
    console.error('Error saving offline data:', error);
  }
}

function getOfflineData() {
  try {
    return JSON.parse(localStorage.getItem(OFFLINE_STORAGE_KEY) || '[]');
  } catch (error) {
    console.error('Error getting offline data:', error);
    return [];
  }
}

function clearOfflineData() {
  localStorage.removeItem(OFFLINE_STORAGE_KEY);
}

async function syncOfflineData() {
  const offlineData = getOfflineData();
  if (offlineData.length === 0) return;

  for (const data of offlineData) {
    try {
      // Sync session data
      if (data.type === 'session') {
        await fetch('/api/session', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(data.session)
        });
      }
    } catch (error) {
      console.error('Failed to sync offline data:', error);
    }
  }
  
  clearOfflineData();
  showNotification('Offline data synced successfully!', 'success');
}

// Enhanced Notification System
function showNotification(message, type = 'info') {
  const notification = document.createElement('div');
  notification.className = `notification ${type}`;
  notification.innerHTML = `
    <div class="flex items-center">
      <i class="fas fa-${getNotificationIcon(type)} mr-2"></i>
      <span>${message}</span>
    </div>
  `;
  
  document.body.appendChild(notification);
  
  // Show notification
  setTimeout(() => {
    notification.classList.add('show');
  }, 100);
  
  // Hide notification
  setTimeout(() => {
    notification.classList.remove('show');
    setTimeout(() => {
      document.body.removeChild(notification);
    }, 300);
  }, 3000);
}

function getNotificationIcon(type) {
  switch (type) {
    case 'success': return 'check-circle';
    case 'error': return 'exclamation-circle';
    case 'warning': return 'exclamation-triangle';
    default: return 'info-circle';
  }
}

// Enhanced Timer with Offline Support
class PomodoroTimer {
  constructor() {
    this.timer = null;
    this.timeLeft = 25 * 60;
    this.totalTime = 25 * 60;
    this.isRunning = false;
    this.currentSessionId = null;
    this.offlineMode = false;
    
    this.initializeElements();
    this.bindEvents();
    this.loadAnalytics();
  }
  
  initializeElements() {
    this.timerDisplay = document.getElementById('timer-display');
    this.progressBar = document.getElementById('progress-bar');
    this.startBtn = document.getElementById('start-btn');
    this.pauseBtn = document.getElementById('pause-btn');
    this.resetBtn = document.getElementById('reset-btn');
    this.sessionStatus = document.getElementById('session-status');
    this.sessionTypeBtns = document.querySelectorAll('.session-type-btn');
  }
  
  bindEvents() {
    if (this.startBtn) this.startBtn.addEventListener('click', () => this.startTimer());
    if (this.pauseBtn) this.pauseBtn.addEventListener('click', () => this.pauseTimer());
    if (this.resetBtn) this.resetBtn.addEventListener('click', () => this.resetTimer());
    
    this.sessionTypeBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        this.sessionTypeBtns.forEach(b => b.classList.remove('ring-2', 'ring-purple-300'));
        btn.classList.add('ring-2', 'ring-purple-300');
        
        const duration = parseInt(btn.dataset.duration);
        const type = btn.dataset.type;
        this.setSessionType(duration, type);
      });
    });
    
    // Set initial session type
    const workBtn = document.querySelector('[data-type="work"]');
    if (workBtn) workBtn.classList.add('ring-2', 'ring-purple-300');
  }
  
  setSessionType(duration, type) {
    this.timeLeft = duration * 60;
    this.totalTime = duration * 60;
    this.updateTimerDisplay();
    this.updateProgressBar();
    this.sessionStatus.textContent = `Ready to start ${type} session`;
  }
  
  startTimer() {
    if (!this.isRunning) {
      this.isRunning = true;
      this.startBtn.classList.add('hidden');
      this.pauseBtn.classList.remove('hidden');
      
      this.createSession();
      
      this.timer = setInterval(() => {
        this.timeLeft--;
        this.updateTimerDisplay();
        this.updateProgressBar();
        
        if (this.timeLeft <= 0) {
          this.completeTimer();
        }
      }, 1000);
    }
  }
  
  pauseTimer() {
    if (this.isRunning) {
      this.isRunning = false;
      this.startBtn.classList.remove('hidden');
      this.pauseBtn.classList.add('hidden');
      clearInterval(this.timer);
    }
  }
  
  resetTimer() {
    this.pauseTimer();
    this.timeLeft = this.totalTime;
    this.updateTimerDisplay();
    this.updateProgressBar();
    this.sessionStatus.textContent = 'Timer reset';
  }
  
  completeTimer() {
    this.pauseTimer();
    this.timeLeft = 0;
    this.updateTimerDisplay();
    this.updateProgressBar();
    this.sessionStatus.textContent = 'Session completed!';
    
    this.completeSession();
    this.showCompletionNotification();
    this.playNotificationSound();
  }
  
  updateTimerDisplay() {
    if (!this.timerDisplay) return;
    const minutes = Math.floor(this.timeLeft / 60);
    const seconds = this.timeLeft % 60;
    this.timerDisplay.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }
  
  updateProgressBar() {
    if (!this.progressBar) return;
    const progress = ((this.totalTime - this.timeLeft) / this.totalTime) * 100;
    this.progressBar.style.width = `${progress}%`;
  }
  
  async createSession() {
    const sessionData = {
      type: 'work',
      duration: Math.floor(this.totalTime / 60)
    };
    
    if (navigator.onLine) {
      try {
        const response = await fetch('/api/session', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(sessionData)
        });
        const data = await response.json();
        this.currentSessionId = data.session_id;
      } catch (error) {
        console.error('Error creating session:', error);
        this.saveOfflineSession(sessionData);
      }
    } else {
      this.saveOfflineSession(sessionData);
    }
  }
  
  saveOfflineSession(sessionData) {
    this.offlineMode = true;
    saveOfflineData({
      type: 'session',
      session: sessionData
    });
    showNotification('Session saved offline', 'info');
  }
  
  async completeSession() {
    if (this.currentSessionId && navigator.onLine) {
      try {
        await fetch(`/api/session/${this.currentSessionId}/complete`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          }
        });
        this.loadAnalytics();
      } catch (error) {
        console.error('Error completing session:', error);
      }
    }
  }
  
  showCompletionNotification() {
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification('FocusFlow', {
        body: 'Your session is complete!',
        icon: '/static/icons/icon-192x192.png',
        badge: '/static/icons/icon-72x72.png',
        vibrate: [100, 50, 100]
      });
    }
  }
  
  playNotificationSound() {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
    oscillator.frequency.setValueAtTime(600, audioContext.currentTime + 0.1);
    
    gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.2);
    
    oscillator.start(audioContext.currentTime);
    oscillator.stop(audioContext.currentTime + 0.2);
  }
  
  async loadAnalytics() {
    if (!navigator.onLine) return;
    
    try {
      const response = await fetch('/api/analytics');
      const data = await response.json();
      
      this.updateAnalyticsDisplay(data);
    } catch (error) {
      console.error('Error loading analytics:', error);
    }
  }
  
  updateAnalyticsDisplay(data) {
    const todaySessions = document.getElementById('today-sessions');
    const todayMinutes = document.getElementById('today-minutes');
    const completionRate = document.getElementById('completion-rate');
    
    if (todaySessions) todaySessions.textContent = data.total_sessions;
    if (todayMinutes) todayMinutes.textContent = data.total_minutes;
    if (completionRate) completionRate.textContent = `${data.completion_rate.toFixed(1)}%`;
    
    this.updateRecentSessions(data.daily_data);
  }
  
  updateRecentSessions(dailyData) {
    const recentSessionsDiv = document.getElementById('recent-sessions');
    if (!recentSessionsDiv) return;
    
    const today = new Date().toISOString().split('T')[0];
    
    if (dailyData[today]) {
      const sessions = dailyData[today];
      recentSessionsDiv.innerHTML = `
        <div class="text-sm">
          <div class="flex justify-between">
            <span>Today</span>
            <span>${sessions.sessions} sessions</span>
          </div>
          <div class="flex justify-between">
            <span>Total time</span>
            <span>${sessions.minutes} min</span>
          </div>
        </div>
      `;
    }
  }
}

// Initialize PWA features when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Request notification permission
  if ('Notification' in window && Notification.permission === 'default') {
    Notification.requestPermission();
  }
  
  // Handle premium upgrade
  const upgradeBtn = document.getElementById('upgrade-btn');
  if (upgradeBtn) {
    upgradeBtn.addEventListener('click', async () => {
      try {
        const response = await fetch('/api/premium/upgrade', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          }
        });
        if (response.ok) {
          location.reload();
        }
      } catch (error) {
        console.error('Error upgrading:', error);
        showNotification('Upgrade failed. Please try again.', 'error');
      }
    });
  }
  
  // Add install prompt to landing page
  if (window.location.pathname === '/') {
    const installSection = document.createElement('div');
    installSection.className = 'mt-8 text-center';
    installSection.innerHTML = `
      <button id="install-button" class="bg-green-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors hidden">
        <i class="fas fa-download mr-2"></i>Install FocusFlow App
      </button>
      <p class="text-sm text-gray-600 mt-2">Add to home screen for the best experience</p>
    `;
    
    const mainContent = document.querySelector('main');
    if (mainContent) {
      mainContent.appendChild(installSection);
    }
  }
}); 