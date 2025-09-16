# Kickboxing Management App

A comprehensive Flutter application for managing kickboxing classes, student attendance, and fee payments.

## Features

### 🥊 Core Functionality
- **Student Management**: Add, edit, and manage student information
- **Attendance Tracking**: Mark and track student attendance for each class
- **Payment Management**: Record and track monthly fee payments
- **Admin Dashboard**: Comprehensive overview with statistics and reports
- **Student Portal**: Students can mark their own attendance and make payments

### 👨‍💼 Admin Features
- **Dashboard Overview**: View key metrics and statistics
- **Student Management**: Full CRUD operations for student records
- **Attendance Management**: Mark attendance for all students
- **Payment Tracking**: Monitor payment status and history
- **Reports & Analytics**: Generate reports and view business insights
- **Quick Actions**: Fast access to common tasks

### 👨‍🎓 Student Features
- **Personal Dashboard**: View attendance history and payment status
- **Self-Service Attendance**: Mark attendance for current class
- **Payment Portal**: Make monthly fee payments
- **Profile Management**: View personal information and statistics

## Technology Stack

- **Framework**: Flutter 3.5.4
- **Language**: Dart
- **State Management**: Provider
- **Backend**: Firebase (Firestore + Authentication)
- **UI Components**: Material Design 3
- **Fonts**: Google Fonts (Poppins)
- **Date/Time**: intl package

## Getting Started

### Prerequisites
- Flutter SDK (3.5.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device
- Firebase Account (free)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd new_management_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (see FIREBASE_SETUP.md for detailed instructions)
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Add your app configuration
   - Update `lib/firebase_options.dart` with your Firebase config

4. **Run the app**
   ```bash
   flutter run
   ```

## App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── student.dart         # Student model
│   ├── attendance.dart      # Attendance model
│   └── payment.dart         # Payment model
├── screens/                  # UI screens
│   ├── login_screen.dart    # Login/role selection
│   ├── admin_dashboard.dart # Admin main dashboard
│   ├── student_dashboard.dart # Student main dashboard
│   ├── admin_students_screen.dart # Student management
│   ├── admin_attendance_screen.dart # Attendance management
│   ├── admin_payments_screen.dart # Payment management
│   └── admin_reports_screen.dart # Reports & analytics
├── services/                 # Business logic
│   ├── firebase_service.dart # Firebase operations
│   └── app_provider.dart    # State management
└── widgets/                  # Reusable UI components
```

## Firebase Collections

### Students Collection
- `id` (Document ID - Firebase UID)
- `name` (String)
- `email` (String)
- `phone` (String)
- `joinDate` (Timestamp)
- `monthlyFee` (Number)
- `isActive` (Boolean)
- `profileImage` (String, optional)
- `role` (String - "student")
- `createdAt` (Timestamp)

### Users Collection (Admin)
- `id` (Document ID - Firebase UID)
- `email` (String)
- `role` (String - "admin")
- `createdAt` (Timestamp)

### Attendance Collection
- `id` (Auto-generated Document ID)
- `studentId` (String - Firebase UID)
- `date` (Timestamp)
- `isPresent` (Boolean)
- `notes` (String, optional)
- `createdAt` (Timestamp)

### Payments Collection
- `id` (Auto-generated Document ID)
- `studentId` (String - Firebase UID)
- `amount` (Number)
- `paymentDate` (Timestamp)
- `paymentMethod` (String)
- `status` (String - "completed", "pending", "failed")
- `transactionId` (String, optional)
- `notes` (String, optional)
- `createdAt` (Timestamp)

## Usage Guide

### For Administrators

1. **Login as Admin**
   - Use the admin email and password you set up in Firebase
   - Admin accounts are created manually in Firebase Console

2. **Manage Students**
   - Navigate to "Students" tab
   - Add new students with complete information
   - Edit existing student details
   - View student statistics and history

3. **Track Attendance**
   - Go to "Attendance" tab
   - Select date and mark attendance for students
   - View attendance history by date

4. **Handle Payments**
   - Access "Payments" tab
   - Record new payments
   - Track payment status (completed, pending, failed)
   - View payment history

5. **Generate Reports**
   - Visit "Reports" tab
   - View key metrics and analytics
   - Export reports (feature coming soon)

### For Students

1. **Register as Student**
   - Click "Register as Student" on the login screen
   - Fill in your details and create an account
   - Or login with existing credentials if already registered

2. **Mark Attendance**
   - Tap "Mark Attendance" on home screen
   - Confirm attendance for current class

3. **Make Payments**
   - Tap "Make Payment" on home screen
   - Enter payment amount and method
   - Submit payment

4. **View History**
   - Check attendance history in "Attendance" tab
   - Review payment history in "Payments" tab
   - View personal statistics in "Profile" tab

## Key Features

### 📊 Analytics Dashboard
- Real-time statistics
- Revenue tracking
- Attendance rates
- Student performance metrics

### 🔄 Real-time Updates
- Live data synchronization with Firebase
- Instant UI updates
- Offline capability with Firestore

### 🎨 Modern UI/UX
- Material Design 3
- Responsive layout
- Intuitive navigation
- Beautiful color scheme

### 🔒 Data Security
- Firebase Authentication for secure login
- Firestore security rules for data protection
- Role-based access control
- Encrypted data transmission

## Future Enhancements

- [ ] Cloud synchronization
- [ ] Push notifications
- [ ] Advanced reporting
- [ ] Payment gateway integration
- [ ] Student photo upload
- [ ] Class scheduling
- [ ] Instructor management
- [ ] Multi-location support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Built with ❤️ using Flutter**
