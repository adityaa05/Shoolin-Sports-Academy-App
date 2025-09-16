import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/instructor_dashboard.dart';
import 'screens/admin_signup_screen.dart';
import 'screens/student_registration_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/connectivity_service.dart';
import 'screens/instructor_login.dart';
import 'screens/role_selection_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message: \\${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SessionManager();
  }
}

class SessionManager extends StatefulWidget {
  const SessionManager({super.key});
  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> {
  User? _user;
  late Stream<User?> _authStream;
  Timer? _inactivityTimer;
  static const Duration _timeout = Duration(minutes: 30);
  late ConnectivityService _connectivityService;
  bool _isOnline = true;
  late StreamSubscription<bool> _subscription;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream.listen((user) {
      setState(() {
        _user = user;
      });
      if (user == null) {
        _cancelInactivityTimer();
      } else {
        _resetInactivityTimer();
      }
    });
    _connectivityService = ConnectivityService();
    _subscription = _connectivityService.connectionChange.listen((online) {
      setState(() {
        _isOnline = online;
      });
    });
    // Start real-time listeners for all app data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.startRealtimeListeners();
    });
  }

  void _resetInactivityTimer() {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(_timeout, () async {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out due to inactivity.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  void dispose() {
    _cancelInactivityTimer();
    _subscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  // Listen for any user interaction to reset inactivity timer
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoolin Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF13131A),
        scaffoldBackgroundColor: const Color(0xFF13131A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF13131A),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF13131A),
          secondary: const Color(0xFF1976D2),
          error: const Color(0xFFEF4444),
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF13131A),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          headlineSmall: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          titleMedium: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          bodyMedium: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
          bodySmall: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB2FF00),
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white70),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF13131A),
          contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        dividerColor: Colors.white24,
        useMaterial3: true,
      ),
      home: Listener(
        onPointerDown: (_) => _resetInactivityTimer(),
        onPointerMove: (_) => _resetInactivityTimer(),
        onPointerUp: (_) => _resetInactivityTimer(),
        child: _user == null
            ? const RoleSelectionScreen()
            : FutureBuilder<String>(
                future: _getUserRole(_user!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final role = snapshot.data!;
                  if (role == 'admin') {
                    return const AdminDashboard();
                  } else if (role == 'instructor') {
                    return const InstructorDashboard();
                  } else {
                    return const StudentDashboard();
                  }
                },
              ),
      ),
      routes: {
        '/login': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          String role = 'student';
          if (args is String) role = args;
          return LoginScreen(selectedRole: role);
        },
        '/register': (context) => StudentRegistrationScreen(),
        '/admin-signup': (context) => AdminSignupScreen(),
        '/instructor-login': (context) => InstructorLoginScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/student': (context) => const StudentDashboard(),
        '/instructor': (context) => const InstructorDashboard(),
      },
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (!_isOnline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: MaterialBanner(
                  content: const Text('No internet connection'),
                  backgroundColor: Colors.red,
                  actions: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<String> _getUserRole(User user) async {
    try {
      print('Session manager debug: Checking role for user ${user.uid}');
      
      // Check admin
      final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
      if (adminDoc.exists) {
        print('Session manager debug: User is admin');
        return 'admin';
      }
      
      // Check instructor
      final instructorDoc = await FirebaseFirestore.instance.collection('instructors').doc(user.uid).get();
      if (instructorDoc.exists) {
        print('Session manager debug: User is instructor');
        return 'instructor';
      }
      
      print('Session manager debug: User is student (default)');
      // Default to student
      return 'student';
    } catch (e) {
      print('Error getting user role: $e');
      return 'student';
    }
  }
}
