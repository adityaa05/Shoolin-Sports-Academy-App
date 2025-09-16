import 'package:flutter/material.dart';
import '../constants/batches.dart';

/// Checks if a user can mark attendance for a student in a batch at the current time.
///
/// [userRole]: 'admin', 'instructor', or 'student'
/// [userId]: The current user's ID
/// [studentId]: The student whose attendance is being marked
/// [batchName]: The batch name (must match BatchTime.batchName)
/// [now]: The current DateTime (for testability; defaults to DateTime.now())
/// [instructorBatchNames]: List of batch names the instructor is assigned to (if role is instructor)
bool canMarkAttendance({
  required String userRole,
  required String userId,
  required String studentId,
  required String batchName,
  DateTime? now,
  List<String>? instructorBatchNames,
}) {
  now = now ?? DateTime.now();
  if (userRole == 'admin') return true;
  final batchTime = getBatchTime(batchName);
  if (batchTime == null) return false;

  // Helper to check if now is within batch time window
  bool isWithinBatchTime() => canMarkAttendanceNow(batchName);

  if (userRole == 'student') {
    // Student can only mark their own attendance during batch time
    return userId == studentId && isWithinBatchTime();
  }
  if (userRole == 'instructor') {
    // Instructor can only mark for their batches, during batch time
    return (instructorBatchNames?.contains(batchName) ?? false) && isWithinBatchTime();
  }
  return false;
} 