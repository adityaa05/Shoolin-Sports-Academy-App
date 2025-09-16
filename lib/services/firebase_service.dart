import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/class_session.dart';
import '../models/holiday.dart';
import '../models/instructor.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Student registration
  Future<void> registerStudent(Student student, String email, String password) async {
    try {
      UserCredential? userCredential = await signUpWithEmailAndPassword(email, password);
      final user = userCredential?.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }
      
      await _firestore.collection('students').doc(user.uid).set({
        'name': student.name,
        'email': student.email,
        'phone': student.phone,
        'batches': student.batches,
        'isActive': student.isActive ? 1 : 0,
        'createdAt': student.createdAt.toIso8601String(),
        'classType': student.classType,
        'monthlyFee': student.monthlyFee,
      });
    } catch (e) {
      print('Error registering student: $e');
      rethrow;
    }
  }

  // Get student data
  Future<Student?> getStudentById(String studentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('students').doc(studentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Student.fromMap({...data, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting student by ID: $e');
      return null;
    }
  }

  Future<List<Student>> getAllStudents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('students').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Student.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting all students: $e');
      return [];
    }
  }

  // Attendance methods
  Future<void> markAttendance(Attendance attendance) async {
    try {
      // Check for existing attendance for this student, batch, and date
      final startOfDay = DateTime(attendance.date.year, attendance.date.month, attendance.date.day, 0, 0, 0, 0);
      final endOfDay = DateTime(attendance.date.year, attendance.date.month, attendance.date.day, 23, 59, 59, 999);
      Query query = _firestore.collection('attendance')
        .where('studentId', isEqualTo: attendance.studentId)
        .where('batch', isEqualTo: attendance.batch)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay);
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        // Update the first found record
        final doc = querySnapshot.docs.first;
        final updatedAttendance = attendance.copyWith(id: doc.id);
        await updateAttendance(updatedAttendance);
      } else {
        // Add new record
        await _firestore.collection('attendance').add({
          'studentId': attendance.studentId,
          'date': Timestamp.fromDate(attendance.date),
          'isPresent': attendance.isPresent,
          'notes': attendance.notes,
          'batch': attendance.batch,
          'markedBy': attendance.markedBy,
          'status': attendance.status.name,
          'markedByType': attendance.markedByType.name,
          'markedAt': attendance.markedAt != null ? Timestamp.fromDate(attendance.markedAt!) : null,
          'markedByUserId': attendance.markedByUserId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error marking attendance: $e');
      rethrow;
    }
  }

  // Update attendance record by document ID
  Future<void> updateAttendance(Attendance attendance) async {
    if (attendance.id == null) {
      throw Exception('Attendance ID is required for update');
    }
    try {
      await _firestore.collection('attendance').doc(attendance.id).update({
        'studentId': attendance.studentId,
        'date': Timestamp.fromDate(attendance.date),
        'isPresent': attendance.isPresent,
        'notes': attendance.notes,
        'batch': attendance.batch,
        'markedBy': attendance.markedBy,
        'status': attendance.status.name,
        'markedByType': attendance.markedByType.name,
        'markedAt': attendance.markedAt != null ? Timestamp.fromDate(attendance.markedAt!) : null,
        'markedByUserId': attendance.markedByUserId,
      });
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }

  Future<List<Attendance>> getAttendanceByStudent(String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Attendance.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting attendance by student: $e');
      return <Attendance>[];
    }
  }

  Future<List<Attendance>> getAttendanceByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      QuerySnapshot querySnapshot = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Attendance.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting attendance by date: $e');
      return <Attendance>[];
    }
  }

  Future<List<Attendance>> getAttendanceByMonth({required int year, required int month, String? batch}) async {
    try {
      final startOfMonth = DateTime(year, month, 1, 0, 0, 0, 0);
      final startOfNextMonth = (month == 12)
        ? DateTime(year + 1, 1, 1, 0, 0, 0, 0)
        : DateTime(year, month + 1, 1, 0, 0, 0, 0);
      Query query = _firestore.collection('attendance')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThan: startOfNextMonth);
      if (batch != null && batch.isNotEmpty) {
        query = query.where('batch', isEqualTo: batch);
      }
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Attendance.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting attendance by month: $e');
      return <Attendance>[];
    }
  }

  // Get all attendance records (for admin view)
  Future<List<Attendance>> getAllAttendance() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('attendance')
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Attendance.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting all attendance: $e');
      return <Attendance>[];
    }
  }

  Future<bool> isAttendanceMarkedToday(String studentId, {String? batch}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      
      Query query = _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay);
      
      if (batch != null) {
        query = query.where('batch', isEqualTo: batch);
      }
      
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking attendance marked today: $e');
      return false;
    }
  }

  // Payment methods
  Future<void> addPayment(Payment payment) async {
    try {
      await _firestore.collection('payments').add({
        'studentId': payment.studentId,
        'amount': payment.amount,
        'paymentDate': payment.paymentDate.toIso8601String(),
        'paymentMethod': payment.paymentMethod,
        'status': payment.status,
        'batch': payment.batch,
        'transactionId': payment.transactionId,
        'notes': payment.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding payment: $e');
      rethrow;
    }
  }

  Future<List<Payment>> getPaymentsByStudent(String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('payments')
          .where('studentId', isEqualTo: studentId)
          .orderBy('paymentDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Payment.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting payments by student: $e');
      return <Payment>[];
    }
  }

  Future<List<Payment>> getAllPayments() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('payments')
          .orderBy('paymentDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Payment.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting all payments: $e');
      return [];
    }
  }

  // Update a payment record by document ID
  Future<void> updatePayment(Payment payment) async {
    if (payment.id == null) {
      throw Exception('Payment ID is required for update');
    }
    try {
      await _firestore.collection('payments').doc(payment.id).update({
        'studentId': payment.studentId,
        'amount': payment.amount,
        'paymentDate': payment.paymentDate.toIso8601String(),
        'paymentMethod': payment.paymentMethod,
        'status': payment.status,
        'batch': payment.batch,
        'transactionId': payment.transactionId,
        'notes': payment.notes,
        'isActive': payment.isActive ? 1 : 0,
        'deactivatedAt': payment.deactivatedAt?.toIso8601String(),
      });
    } catch (e) {
      print('Error updating payment: $e');
      rethrow;
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getStudentStats(String studentId) async {
    try {
      // Get attendance stats
      List<Attendance> attendance = await getAttendanceByStudent(studentId);
      int totalClasses = attendance.length;
      int classesAttended = attendance.where((a) => a.isPresent).length;

      // Get payment stats
      List<Payment> payments = await getPaymentsByStudent(studentId);
      int totalPayments = payments.where((p) => p.status == 'completed').length;
      double totalAmountPaid = payments
          .where((p) => p.status == 'completed')
          .fold(0.0, (sum, payment) => sum + payment.amount);

      return {
        'totalClasses': totalClasses,
        'classesAttended': classesAttended,
        'totalPayments': totalPayments,
        'totalAmountPaid': totalAmountPaid,
      };
    } catch (e) {
      print('Error getting student stats: $e');
      return {
        'totalClasses': 0,
        'classesAttended': 0,
        'totalPayments': 0,
        'totalAmountPaid': 0.0,
      };
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('admins').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'admin';
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Check if user is instructor
  Future<bool> isInstructor(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('instructors').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'instructor';
      }
      return false;
    } catch (e) {
      print('Error checking instructor status: $e');
      return false;
    }
  }

  // Get instructor details
  Future<Map<String, dynamic>?> getInstructorDetails(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('instructors').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting instructor details: $e');
      return null;
    }
  }

  // Ensure instructor document exists (for login persistence)
  Future<void> ensureInstructorDocument(String userId, Map<String, dynamic> instructorData) async {
    try {
      await _firestore.collection('instructors').doc(userId).set({
        ...instructorData,
        'role': 'instructor',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error ensuring instructor document: $e');
    }
  }

  // Create admin user (call this once to set up admin)
  Future<void> createAdminUser(String email, String password) async {
    try {
      UserCredential? userCredential = await signUpWithEmailAndPassword(email, password);
      final user = userCredential?.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating admin user: $e');
      rethrow;
    }
  }

  // Admin registration
  Future<void> registerAdmin({required String name, required String email, required String password}) async {
    try {
      print('Starting admin registration for: $email');
      
      // Create user account
      UserCredential? userCredential = await signUpWithEmailAndPassword(email, password);
      final user = userCredential?.user;
      if (user == null) {
        throw Exception('Failed to create admin user account');
      }
      
      print('Admin user account created with UID: ${user.uid}');
      
      // Create admin document in Firestore
      await _firestore.collection('admins').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('Admin document created in Firestore successfully');
    } catch (e) {
      print('Error registering admin: $e');
      rethrow;
    }
  }

  // Instructor registration
  Future<void> registerInstructor({required String name, required String email, required String password, String? phone}) async {
    try {
      // Create user account
      UserCredential? userCredential = await signUpWithEmailAndPassword(email, password);
      final user = userCredential?.user;
      if (user == null) {
        throw Exception('Failed to create instructor user account');
      }
      // Create instructor document in Firestore
      await _firestore.collection('instructors').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'instructor',
        'isActive': true,
        'assignedBatches': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error registering instructor: $e');
      rethrow;
    }
  }

  Future<void> saveDeviceToken(String userId) async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('students').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  // Class Session methods
  Future<void> createClassSession(ClassSession session) async {
    try {
      await _firestore.collection('class_sessions').add(session.toMap());
    } catch (e) {
      print('Error creating class session: $e');
      rethrow;
    }
  }

  Future<void> updateClassSession(ClassSession session) async {
    try {
      await _firestore.collection('class_sessions').doc(session.id).update(session.toMap());
    } catch (e) {
      print('Error updating class session: $e');
      rethrow;
    }
  }

  Future<void> deleteClassSession(String sessionId) async {
    try {
      await _firestore.collection('class_sessions').doc(sessionId).delete();
    } catch (e) {
      print('Error deleting class session: $e');
      rethrow;
    }
  }

  Future<List<ClassSession>> getClassSessions({DateTime? from, DateTime? to, String? batch}) async {
    try {
      Query query = _firestore.collection('class_sessions');
      
      if (from != null) {
        query = query.where('date', isGreaterThanOrEqualTo: from.toIso8601String());
      }
      
      if (to != null) {
        query = query.where('date', isLessThanOrEqualTo: to.toIso8601String());
      }
      
      if (batch != null) {
        query = query.where('batchName', isEqualTo: batch);
      }
      
      QuerySnapshot querySnapshot = await query.orderBy('date').get();
      
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ClassSession.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting class sessions: $e');
      return [];
    }
  }

  Future<List<ClassSession>> getSessionsByStudent(String studentId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('class_sessions')
          .where('expectedStudents', arrayContains: studentId)
          .orderBy('date')
          .get();
      
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ClassSession.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting sessions by student: $e');
      return [];
    }
  }

  Future<void> markSessionAttendance(String sessionId, String studentId, bool attended) async {
    try {
      final sessionRef = _firestore.collection('class_sessions').doc(sessionId);
      
      if (attended) {
        await sessionRef.update({
          'attendedStudents': FieldValue.arrayUnion([studentId])
        });
      } else {
        await sessionRef.update({
          'attendedStudents': FieldValue.arrayRemove([studentId])
        });
      }
    } catch (e) {
      print('Error marking session attendance: $e');
      rethrow;
    }
  }

  Future<void> updateSessionStatus(String sessionId, SessionStatus status) async {
    try {
      await _firestore.collection('class_sessions').doc(sessionId).update({
        'status': status.name,
      });
    } catch (e) {
      print('Error updating session status: $e');
      rethrow;
    }
  }

  // Holiday methods
  Future<void> createHoliday(Holiday holiday) async {
    try {
      // Check for duplicate/overlapping holiday
      final startOfDay = DateTime(holiday.date.year, holiday.date.month, holiday.date.day, 0, 0, 0, 0);
      final endOfDay = DateTime(holiday.date.year, holiday.date.month, holiday.date.day, 23, 59, 59, 999);
      Query query = _firestore.collection('holidays')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String());
      QuerySnapshot querySnapshot = await query.get();
      final overlap = querySnapshot.docs.any((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Overlap if batch is null (all batches) or matches the new holiday's batch
        return data['batch'] == null || data['batch'] == holiday.batch;
      });
      if (overlap) {
        throw Exception('A holiday already exists for this batch or all batches on this date.');
      }
      await _firestore.collection('holidays').add(holiday.toMap());
    } catch (e) {
      print('Error creating holiday: $e');
      rethrow;
    }
  }

  Future<void> deleteHoliday(String holidayId) async {
    try {
      await _firestore.collection('holidays').doc(holidayId).delete();
    } catch (e) {
      print('Error deleting holiday: $e');
      rethrow;
    }
  }

  Future<List<Holiday>> getHolidays({String? batch, DateTime? from, DateTime? to}) async {
    try {
      Query query = _firestore.collection('holidays');
      if (batch != null) {
        query = query.where('batch', isEqualTo: batch);
      }
      if (from != null) {
        query = query.where('date', isGreaterThanOrEqualTo: from.toIso8601String());
      }
      if (to != null) {
        query = query.where('date', isLessThanOrEqualTo: to.toIso8601String());
      }
      QuerySnapshot querySnapshot = await query.orderBy('date').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Holiday.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching holidays: $e');
      return [];
    }
  }

  // Instructor CRUD operations
  Future<void> createInstructor(Instructor instructor) async {
    try {
      await _firestore.collection('instructors').doc(instructor.id).set(instructor.toMap());
    } catch (e) {
      print('Error creating instructor: $e');
      rethrow;
    }
  }

  Future<void> updateInstructor(Instructor instructor) async {
    try {
      await _firestore.collection('instructors').doc(instructor.id).update(instructor.toMap());
    } catch (e) {
      print('Error updating instructor: $e');
      rethrow;
    }
  }

  Future<void> deleteInstructor(String instructorId) async {
    try {
      await _firestore.collection('instructors').doc(instructorId).delete();
    } catch (e) {
      print('Error deleting instructor: $e');
      rethrow;
    }
  }

  Future<List<Instructor>> getAllInstructors() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('instructors').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Instructor.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching instructors: $e');
      return [];
    }
  }

  Future<Instructor?> getInstructorById(String instructorId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('instructors').doc(instructorId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Instructor.fromMap({...data, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching instructor: $e');
      return null;
    }
  }

  // Get instructors by assigned batch
  Future<List<Instructor>> getInstructorsByBatch(String batch) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('instructors')
          .where('assignedBatches', arrayContains: batch)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Instructor.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching instructors by batch: $e');
      return [];
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _firestore.collection('students').doc(student.id).set(student.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error updating student: $e');
      rethrow;
    }
  }

  Future<void> createStudent(Student student) async {
    try {
      final docRef = await _firestore.collection('students').add(student.toMap());
      // Optionally update the student with the generated id
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error creating student: $e');
      rethrow;
    }
  }

  /// Mark all attendance records for a student and batch as inactive
  Future<void> deactivateAttendanceForStudentBatch(String studentId, String batch) async {
    final now = DateTime.now();
    final query = await _firestore.collection('attendance')
      .where('studentId', isEqualTo: studentId)
      .where('batch', isEqualTo: batch)
      .where('isActive', isEqualTo: 1)
      .get();
    for (final doc in query.docs) {
      await doc.reference.update({
        'isActive': 0,
        'deactivatedAt': now.toIso8601String(),
      });
    }
  }

  /// Mark all payment records for a student and batch as inactive
  Future<void> deactivatePaymentsForStudentBatch(String studentId, String batch) async {
    final now = DateTime.now();
    final query = await _firestore.collection('payments')
      .where('studentId', isEqualTo: studentId)
      .where('batch', isEqualTo: batch)
      .where('isActive', isEqualTo: 1)
      .get();
    for (final doc in query.docs) {
      await doc.reference.update({
        'isActive': 0,
        'deactivatedAt': now.toIso8601String(),
      });
    }
  }

  /// Delete a student by document ID
  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore.collection('students').doc(studentId).delete();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  /// Delete an attendance record by document ID
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore.collection('attendance').doc(attendanceId).delete();
    } catch (e) {
      print('Error deleting attendance: $e');
      rethrow;
    }
  }

  /// Delete a payment record by document ID
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).delete();
    } catch (e) {
      print('Error deleting payment: $e');
      rethrow;
    }
  }

  /// Real-time stream of all students
  Stream<List<Student>> studentsStream() {
    return _firestore.collection('students').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Student.fromMap({...data, 'id': doc.id});
      }).toList()
    );
  }

  /// Real-time stream of all attendance records
  Stream<List<Attendance>> attendanceStream() {
    return _firestore.collection('attendance').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Attendance.fromMap(data, doc.id);
      }).toList()
    );
  }

  /// Real-time stream of all holidays
  Stream<List<Holiday>> holidaysStream() {
    return _firestore.collection('holidays').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Holiday.fromMap({...data, 'id': doc.id});
      }).toList()
    );
  }
} 