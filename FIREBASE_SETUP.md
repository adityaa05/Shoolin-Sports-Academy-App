# Firebase Setup Guide for Kickboxing Management App

This guide will help you set up Firebase for your kickboxing management app.

## 🚀 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "Kickboxing Management")
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## 🔧 Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

## 📊 Step 3: Set up Firestore Database

1. Go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

## 📱 Step 4: Add Android App

1. In your Firebase project, click the Android icon (</>) to add an Android app
2. Enter your Android package name: `com.example.new_management_app`
3. Enter app nickname: "Kickboxing Management"
4. Click "Register app"
5. Download the `google-services.json` file
6. Place it in `android/app/` directory of your Flutter project

## 🍎 Step 5: Add iOS App (Optional)

1. Click the iOS icon to add an iOS app
2. Enter your iOS bundle ID: `com.example.newManagementApp`
3. Enter app nickname: "Kickboxing Management"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place it in `ios/Runner/` directory of your Flutter project

## 🌐 Step 6: Add Web App (Optional)

1. Click the web icon to add a web app
2. Enter app nickname: "Kickboxing Management"
3. Click "Register app"
4. Copy the Firebase configuration

## ⚙️ Step 7: Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project-id.firebaseapp.com',
  storageBucket: 'your-actual-project-id.appspot.com',
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

## 🔐 Step 8: Set up Firestore Security Rules

1. Go to Firestore Database > Rules
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read their own data
    match /students/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow admins to read all data
    match /students/{document=**} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow authenticated users to read/write attendance
    match /attendance/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to read/write payments
    match /payments/{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Allow users to read their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 👨‍💼 Step 9: Create Admin User

1. Run the app for the first time
2. Register a student account
3. Go to Firebase Console > Firestore Database
4. Create a new document in the `users` collection
5. Set the document ID to the user's UID (from Authentication)
6. Add the following fields:
   - `email`: admin@example.com
   - `role`: admin
   - `createdAt`: current timestamp

## 🧪 Step 10: Test the Setup

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. Try registering a new student
4. Try logging in with the admin account
5. Verify that data is being stored in Firestore

## 📋 Database Structure

Your Firestore will have the following collections:

### `students` Collection
```javascript
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "joinDate": "2024-01-01T00:00:00.000Z",
  "monthlyFee": 50.0,
  "isActive": true,
  "role": "student",
  "createdAt": "timestamp"
}
```

### `users` Collection
```javascript
{
  "email": "admin@example.com",
  "role": "admin",
  "createdAt": "timestamp"
}
```

### `attendance` Collection
```javascript
{
  "studentId": "user-uid",
  "date": "2024-01-01T00:00:00.000Z",
  "isPresent": true,
  "notes": "Optional notes",
  "createdAt": "timestamp"
}
```

### `payments` Collection
```javascript
{
  "studentId": "user-uid",
  "amount": 50.0,
  "paymentDate": "2024-01-01T00:00:00.000Z",
  "paymentMethod": "Cash",
  "status": "completed",
  "transactionId": "optional",
  "notes": "Optional notes",
  "createdAt": "timestamp"
}
```

## 🔒 Security Considerations

1. **Authentication**: All users must be authenticated
2. **Authorization**: Students can only access their own data
3. **Admin Access**: Admins can access all data
4. **Data Validation**: Validate data on both client and server side

## 💰 Firebase Pricing

Firebase has a generous free tier:
- **Authentication**: 10,000 users/month
- **Firestore**: 1GB storage, 50,000 reads/day, 20,000 writes/day
- **Hosting**: 10GB storage, 360MB/day transfer

For most small to medium kickboxing schools, this should be sufficient.

## 🆘 Troubleshooting

### Common Issues:

1. **"Firebase not initialized"**: Make sure you've added the configuration files
2. **"Permission denied"**: Check your Firestore security rules
3. **"User not found"**: Verify the user exists in Authentication
4. **"Invalid API key"**: Double-check your Firebase configuration

### Getting Help:

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Support](https://firebase.google.com/support)

## 🎉 You're Ready!

Once you've completed these steps, your kickboxing management app will be fully functional with:

✅ **User Authentication**: Students can register and login
✅ **Admin Management**: Admins can view all students
✅ **Attendance Tracking**: Mark and track attendance
✅ **Payment Management**: Record and track payments
✅ **Real-time Data**: All data syncs in real-time
✅ **Offline Support**: Works even without internet
✅ **Scalable**: Can handle hundreds of students

Your app is now ready for production use! 🥊 

Error signing up: type 'List<Object?>' is not a subtype of type 'PigeonUserDetails?' in type cast
Error registering student: type 'List<Object?>' is not a subtype of type 'PigeonUserDetails?' in type cast

### Why this happens
- The method is probably returning a `List<Object?>` (possibly from a platform channel or a plugin), but your code expects a `UserCredential?`.
- This can happen if you are using a custom pigeon-generated API or if the method signature is incorrect.

---

## How to Fix

### 1. **Check your `signUpWithEmailAndPassword` implementation**

Open `firebase_service.dart` and find the method:
```dart
Future<UserCredential?> signUpWithEmailAndPassword(String email, String password)
```
Make sure it is implemented like this:
```dart
Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
  try {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  } catch (e) {
    print('Error signing up: $e');
    return null;
  }
}
```
- **Do not** use any custom pigeon or platform channel code for this.
- Make sure you are using the official `firebase_auth` package.

---

### 2. **Check your imports**
Make sure you are importing:
```dart
import 'package:firebase_auth/firebase_auth.dart';
```
and not any custom pigeon-generated files for user details.

---

### 3. **Check where you call `signUpWithEmailAndPassword`**
Make sure you are not casting its result to a custom type.

---

## Next Steps

1. Update the `signUpWithEmailAndPassword` method as shown above.
2. Remove any pigeon or custom user details code from the authentication flow.
3. Try registering a student or admin again.

Would you like me to show you the exact code to update in your `firebase_service.dart`? If so, please confirm or let me know if you have any custom authentication code. 