import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import '../models/holiday.dart';
import '../models/instructor.dart';
import 'firebase_service.dart';
import '../constants/batches.dart';
import 'dart:async'; // Added for StreamSubscription

class AppProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Student> _students = [];
  List<Attendance> _attendance = [];
  List<Payment> _payments = [];
  bool _isLoading = false;
  bool _isAdmin = false;
  bool _isInstructor = false;
  String? _currentUserId;
  Instructor? _currentInstructor;

  // Getters
  List<Student> get students => _students;
  List<Attendance> get attendance => _attendance;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  bool get isInstructor => _isInstructor;
  String? get currentUserId => _currentUserId;
  Instructor? get currentInstructor => _currentInstructor;

  // Holiday state
  List<Holiday> _holidays = [];
  List<Holiday> get holidays => _holidays;

  // Instructor state
  List<Instructor> _instructors = [];
  List<Instructor> get instructors => _instructors;

  StreamSubscription? _studentsSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _holidaysSub;

  // Initialize data
  Future<void> initializeData() async {
    _setLoading(true);
    await Future.wait([
      loadStudents(),
      loadPayments(),
      loadHolidays(),
      loadInstructors(),
    ]);
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setAdminMode(bool isAdmin) {
    _isAdmin = isAdmin;
    notifyListeners();
  }

  void setInstructorMode(bool isInstructor) {
    _isInstructor = isInstructor;
    notifyListeners();
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void setCurrentInstructor(Instructor? instructor) {
    _currentInstructor = instructor;
    notifyListeners();
  }

  // Load current instructor data
  Future<void> loadCurrentInstructor(String userId) async {
    try {
      final instructorData = await _firebaseService.getInstructorDetails(userId);
      if (instructorData != null) {
        _currentInstructor = Instructor.fromMap({...instructorData, 'id': userId});
        _isInstructor = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading current instructor: $e');
    }
  }

  // Student operations
  Future<void> loadStudents() async {
    try {
      _students = await _firebaseService.getAllStudents();
      notifyListeners();
    } catch (e) {
      print('Error loading students: $e');
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      await _firebaseService.createStudent(student);
      await loadStudents();
    } catch (e) {
      print('Error adding student: $e');
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      // Find removed batches
      final oldStudent = getStudentById(student.id!);
      final oldBatches = oldStudent?.batches ?? [];
      final newBatches = student.batches;
      final removedBatches = oldBatches.where((b) => !newBatches.contains(b));
      // Update student in Firestore
      await _firebaseService.updateStudent(student);
      // Mark related records as inactive for removed batches
      for (final batch in removedBatches) {
        await _firebaseService.deactivateAttendanceForStudentBatch(student.id!, batch);
        await _firebaseService.deactivatePaymentsForStudentBatch(student.id!, batch);
      }
      await loadStudents();
    } catch (e) {
      print('Error updating student: $e');
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _firebaseService.deleteStudent(id);
      await loadStudents();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  // Attendance operations
  Future<void> markAttendance(Attendance attendance) async {
    try {
      await _firebaseService.markAttendance(attendance);
      await loadAttendanceForStudent(attendance.studentId);
      await loadAttendanceByDate(attendance.date);
    } catch (e) {
      print('Error marking attendance: $e');
      rethrow;
    }
  }

  Future<void> loadAttendanceForStudent(String studentId) async {
    try {
      _attendance = await _firebaseService.getAttendanceByStudent(studentId);
      notifyListeners();
    } catch (e) {
      print('Error loading attendance: $e');
    }
  }

  Future<void> loadAttendanceByDate(DateTime date) async {
    try {
      _attendance = await _firebaseService.getAttendanceByDate(date);
      notifyListeners();
    } catch (e) {
      print('Error loading attendance by date: $e');
    }
  }

  Future<void> updateAttendance(Attendance attendance) async {
    try {
      await _firebaseService.updateAttendance(attendance);
      await loadAttendanceForStudent(attendance.studentId);
    } catch (e) {
      print('Error updating attendance: $e');
      rethrow;
    }
  }

  Future<void> loadAttendanceForAllStudents() async {
    try {
      // Load attendance for all students (this will be used in admin view)
      _attendance = await _firebaseService.getAllAttendance();
      notifyListeners();
    } catch (e) {
      print('Error loading attendance for all students: $e');
    }
  }

  Future<void> deleteAttendance(String id) async {
    try {
      await _firebaseService.deleteAttendance(id);
      await loadAttendanceForAllStudents();
    } catch (e) {
      print('Error deleting attendance: $e');
      rethrow;
    }
  }

  Future<void> loadAttendanceByMonth({required int year, required int month, String? batch}) async {
    try {
      _attendance = await _firebaseService.getAttendanceByMonth(year: year, month: month, batch: batch);
      notifyListeners();
    } catch (e) {
      print('Error loading attendance by month: $e');
    }
  }

  // Payment operations
  Future<void> loadPayments() async {
    try {
      _payments = await _firebaseService.getAllPayments();
      notifyListeners();
    } catch (e) {
      print('Error loading payments: $e');
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      await _firebaseService.addPayment(payment);
      await loadPayments();
    } catch (e) {
      print('Error adding payment: $e');
      rethrow;
    }
  }

  Future<List<Payment>> getPaymentsByStudent(String studentId) async {
    try {
      return await _firebaseService.getPaymentsByStudent(studentId);
    } catch (e) {
      print('Error getting payments by student: $e');
      return [];
    }
  }

  Future<void> updatePayment(Payment payment) async {
    try {
      await _firebaseService.updatePayment(payment);
      await loadPayments();
    } catch (e) {
      print('Error updating payment: $e');
      rethrow;
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _firebaseService.deletePayment(id);
      await loadPayments();
    } catch (e) {
      print('Error deleting payment: $e');
      rethrow;
    }
  }

  // Holiday operations
  Future<void> loadHolidays({String? batch, DateTime? from, DateTime? to}) async {
    try {
      _holidays = await _firebaseService.getHolidays(batch: batch, from: from, to: to);
      notifyListeners();
    } catch (e) {
      print('Error loading holidays: $e');
    }
  }

  Future<void> addHoliday(Holiday holiday) async {
    try {
      await _firebaseService.createHoliday(holiday);
      await loadHolidays();
    } catch (e) {
      print('Error adding holiday: $e');
      rethrow;
    }
  }

  Future<void> deleteHoliday(String holidayId) async {
    try {
      await _firebaseService.deleteHoliday(holidayId);
      await loadHolidays();
    } catch (e) {
      print('Error deleting holiday: $e');
      rethrow;
    }
  }

  // Instructor operations
  Future<void> loadInstructors() async {
    try {
      _instructors = await _firebaseService.getAllInstructors();
      notifyListeners();
    } catch (e) {
      print('Error loading instructors: $e');
    }
  }

  Future<void> addInstructor(Instructor instructor) async {
    try {
      await _firebaseService.createInstructor(instructor);
      await loadInstructors();
    } catch (e) {
      print('Error adding instructor: $e');
      rethrow;
    }
  }

  Future<void> updateInstructor(Instructor instructor) async {
    try {
      await _firebaseService.updateInstructor(instructor);
      await loadInstructors();
    } catch (e) {
      print('Error updating instructor: $e');
      rethrow;
    }
  }

  Future<void> deleteInstructor(String instructorId) async {
    try {
      await _firebaseService.deleteInstructor(instructorId);
      await loadInstructors();
    } catch (e) {
      print('Error deleting instructor: $e');
      rethrow;
    }
  }

  // Helper methods
  Student? getStudentById(String id) {
    try {
      return students.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Student> getActiveStudents() {
    return _students.where((student) => student.isActive).toList();
  }

  List<Payment> getCompletedPayments() {
    return _payments.where((payment) => payment.status == 'completed').toList();
  }

  List<Payment> getPendingPayments() {
    return _payments.where((payment) => payment.status == 'pending').toList();
  }

  /// Returns true if the student has a completed payment for the given batch and month.
  bool hasPaidForMonth(String studentId, String batch, {DateTime? forMonth}) {
    final now = forMonth ?? DateTime.now();
    return _payments.any((p) =>
      p.studentId == studentId &&
      p.batch == batch &&
      p.status == 'completed' &&
      p.paymentDate.year == now.year &&
      p.paymentDate.month == now.month
    );
  }

  /// Returns true if the student is overdue for the given batch and month.
  bool isPaymentOverdue(String studentId, String batch, {DateTime? forMonth}) {
    final now = forMonth ?? DateTime.now();
    // Overdue if not paid and today is after the 5th of the next month
    final dueDate = DateTime(now.year, now.month + 1, 5);
    final unpaid = !hasPaidForMonth(studentId, batch, forMonth: now);
    return unpaid && DateTime.now().isAfter(dueDate);
  }

  /// Returns a list of students (with batch info) who are overdue for payment for the given month.
  List<Map<String, dynamic>> getOverdueStudents({DateTime? forMonth}) {
    final now = forMonth ?? DateTime.now();
    final List<Map<String, dynamic>> overdue = [];
    for (final student in _students) {
      for (final batch in student.batches) {
        if (isPaymentOverdue(student.id!, batch, forMonth: now)) {
          overdue.add({'student': student, 'batch': batch});
        }
      }
    }
    return overdue;
  }

  /// Returns a list of students who should be reminded for payment on [today].
  List<Student> getStudentsToRemindForPayment(DateTime today) {
    final List<Student> toRemind = [];
    for (final student in _students) {
      final int day = student.preferredPaymentDay ?? 1;
      final reminderStart = DateTime(today.year, today.month, day).subtract(const Duration(days: 10));
      final dueDate = DateTime(today.year, today.month, day);
      final hasPaid = _payments.any((p) =>
        p.studentId == student.id &&
        p.status == 'completed' &&
        p.paymentDate.year == today.year &&
        p.paymentDate.month == today.month
      );
      print('[ReminderDebug] Student: ${student.name}, preferredDay: $day, reminderStart: $reminderStart, dueDate: $dueDate, today: $today, hasPaid: $hasPaid');
      if (today.isAfter(reminderStart.subtract(const Duration(days: 1))) &&
          today.isBefore(dueDate.add(const Duration(days: 1))) &&
          !hasPaid) {
        toRemind.add(student);
      }
    }
    print('[ReminderDebug] Students to remind: ${toRemind.map((s) => s.name).toList()}');
    return toRemind;
  }

  // Attendance-based helpers:
  List<Attendance> getTodayAttendance(String studentId) {
    final now = DateTime.now();
    final student = getStudentById(studentId);
    if (student == null) return [];
    // For each batch the student is in, check if today is a session day and not a holiday
    final List<Attendance> todayAttendance = [];
    for (final batch in student.batches) {
      final batchTime = getBatchTime(batch);
      final isSessionDay = batchTime != null && batchTime.daysOfWeek.contains(now.weekday);
      final isHoliday = holidays.any((h) =>
        h.date.year == now.year &&
        h.date.month == now.month &&
        h.date.day == now.day &&
        (h.batch == null || h.batch == batch)
      );
      if (isSessionDay && !isHoliday) {
        todayAttendance.addAll(_attendance.where((a) =>
          a.studentId == studentId &&
          a.batch == batch &&
          a.date.year == now.year &&
          a.date.month == now.month &&
          a.date.day == now.day
        ));
      }
    }
    return todayAttendance;
  }

  Attendance? getNextAttendance(String studentId) {
    final now = DateTime.now();
    return _attendance
      .where((a) => a.studentId == studentId && a.date.isAfter(now))
      .toList()
      .fold<Attendance?>(null, (prev, curr) => prev == null || curr.date.isBefore(prev.date) ? curr : prev);
  }

  // Attendance-based stats for a student
  Map<String, dynamic> getStudentStats(String studentId) {
    final studentAttendance = _attendance.where((a) => a.studentId == studentId).toList();
    final classesAttended = studentAttendance.where((a) => a.isPresent).length;
    final studentPayments = _payments.where((p) => p.studentId == studentId && p.status == 'completed').toList();
    final totalPayments = studentPayments.length;
    final totalAmountPaid = studentPayments.fold(0.0, (sum, p) => sum + p.amount);
    
    // Calculate total classes based on rolling 30-day periods from join date
    final student = getStudentById(studentId);
    int totalClasses = 18; // Default for first month
    if (student != null) {
      final now = DateTime.now();
      final enrollmentDate = student.createdAt;
      final daysEnrolled = now.difference(enrollmentDate).inDays;
      final monthsEnrolled = (daysEnrolled / 30).ceil().clamp(1, 1000); // at least 1 month
      totalClasses = monthsEnrolled * 18;
    }
    
    return {
      'totalClasses': totalClasses,
      'classesAttended': classesAttended,
      'totalPayments': totalPayments,
      'totalAmountPaid': totalAmountPaid,
    };
  }

  /// Returns true if today is a holiday for the given batch
  bool isTodayHolidayForBatch(String batch) {
    final now = DateTime.now();
    return _holidays.any((h) =>
      h.date.year == now.year &&
      h.date.month == now.month &&
      h.date.day == now.day &&
      (h.batch == null || h.batch == batch)
    );
  }

  /// Returns true if today is a session day for the given batch
  bool isTodaySessionDayForBatch(String batch) {
    final now = DateTime.now();
    final batchTime = getBatchTime(batch);
    if (batchTime == null) return false;
    return batchTime.daysOfWeek.contains(now.weekday);
  }

  void startRealtimeListeners() {
    _studentsSub?.cancel();
    _attendanceSub?.cancel();
    _holidaysSub?.cancel();
    _studentsSub = _firebaseService.studentsStream().listen((students) {
      _students = students;
      notifyListeners();
    });
    _attendanceSub = _firebaseService.attendanceStream().listen((attendance) {
      _attendance = attendance;
      notifyListeners();
    });
    _holidaysSub = _firebaseService.holidaysStream().listen((holidays) {
      _holidays = holidays;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    _attendanceSub?.cancel();
    _holidaysSub?.cancel();
    super.dispose();
  }
} 