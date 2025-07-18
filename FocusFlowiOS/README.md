# FocusFlow iOS App

A native iOS app for the FocusFlow productivity timer, built with SwiftUI and designed to work with your existing Flask backend.

## Features

- **Authentication**: Login/Register with secure session management
- **Timer Management**: Pomodoro (25min) and Deep Work (90min) sessions
- **Break Options**: Short (5min) and Medium (10min) breaks
- **Session Tracking**: Automatic session creation and completion
- **Analytics**: View detailed statistics and progress
- **Premium Features**: Upgrade to premium subscription
- **Session Reviews**: Add comments after completing sessions

## Project Structure

```
FocusFlowiOS/
├── FocusFlowiOS/
│   ├── Models/
│   │   ├── AuthModels.swift          # Authentication data models
│   │   └── SessionModels.swift       # Session and timer models
│   ├── Views/
│   │   ├── LoginView.swift           # Login screen
│   │   ├── RegisterView.swift        # Registration screen
│   │   ├── DashboardView.swift       # Main timer interface
│   │   ├── AnalyticsView.swift       # Statistics and analytics
│   │   ├── PremiumView.swift         # Premium upgrade screen
│   │   └── SessionReviewView.swift   # Session completion review
│   ├── Networking/
│   │   └── APIService.swift          # HTTP client and API calls
│   ├── Helpers/
│   │   ├── TimerManager.swift        # Timer logic and state management
│   │   └── AuthManager.swift         # Authentication state management
│   └── FocusFlowiOSApp.swift         # Main app entry point
└── README.md
```

## Setup Instructions

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Your Flask backend running at `https://focusflow-449l.onrender.com`

### Installation

1. **Clone or download** the FocusFlowiOS folder
2. **Open in Xcode**:
   ```bash
   cd FocusFlowiOS
   open FocusFlowiOS.xcodeproj
   ```

3. **Configure the project**:
   - Set your Team ID in Signing & Capabilities
   - Update Bundle Identifier if needed
   - Ensure iOS 17.0+ deployment target

4. **Update API URL** (if needed):
   - Open `APIService.swift`
   - Update `baseURL` to point to your backend

5. **Build and run** on simulator or device

### Backend Requirements

Your Flask backend should have these endpoints:

#### Authentication
- `POST /login` - User login
- `POST /register` - User registration  
- `GET /logout` - User logout

#### Sessions
- `POST /api/session` - Create new session
- `POST /api/session/<id>/complete` - Complete session

#### Analytics
- `GET /api/analytics` - Get user statistics

#### Premium
- `POST /api/premium/upgrade` - Upgrade to premium

## Key Components

### TimerManager
- Handles countdown logic
- Manages session state
- Integrates with backend API
- Auto-completes sessions

### AuthManager
- Secure login state persistence
- Session restoration
- Premium status tracking

### APIService
- Async/await HTTP client
- JSON encoding/decoding
- Error handling
- Type-safe API calls

## Architecture

- **MVVM Pattern**: Models, Views, and ViewModels
- **Async/Await**: Modern Swift concurrency
- **Combine**: Reactive state management
- **@AppStorage**: Secure local storage
- **Codable**: Type-safe JSON handling

## Customization

### Colors and Styling
- Update colors in individual views
- Modify `SessionType.color` for session colors
- Customize button styles and layouts

### API Integration
- Add new endpoints in `APIService.swift`
- Create corresponding models in `Models/`
- Update views to use new data

### Features
- Add new session types in `SessionType` enum
- Extend analytics with new metrics
- Implement additional premium features

## Testing

The app includes preview providers for all views. Test on:
- iPhone simulator (various sizes)
- iPad simulator
- Physical devices

## Deployment

### App Store Preparation
1. **App Icon**: Create 1024x1024 icon
2. **Screenshots**: Capture for all device sizes
3. **App Store Connect**: Set up listing
4. **Privacy Policy**: Required for App Store
5. **TestFlight**: Beta testing

### Build Settings
- Set appropriate deployment target
- Configure code signing
- Enable necessary capabilities

## Troubleshooting

### Common Issues
- **Network errors**: Check backend URL and connectivity
- **Build errors**: Ensure iOS 17.0+ deployment target
- **Signing issues**: Verify Team ID and provisioning profiles

### Debug Tips
- Check Xcode console for API errors
- Verify backend endpoints are accessible
- Test authentication flow step by step

## Support

For issues or questions:
1. Check the backend API is running
2. Verify network connectivity
3. Review Xcode console logs
4. Test individual API endpoints

## License

This iOS app is designed to work with your FocusFlow Flask backend. Ensure you have proper licensing for any third-party dependencies. 