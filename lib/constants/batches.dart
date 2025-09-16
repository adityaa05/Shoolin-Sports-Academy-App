import 'package:flutter/material.dart';

// Available batches
const List<String> kBatches = [
  'Morning Yoga (7:00-8:00am Tue/Thu/Sat)',
  'Morning Kickboxing (7:00-8:00am Mon/Wed/Fri)',
  'Evening Karate (6:30-7:30pm Tue/Thu/Sat)',
  'Evening Kickboxing (7:15-8:30pm Mon/Wed/Fri)',
  'Evening Kickboxing (7:30-9:00pm Tue/Thu/Sat)',
];

// Batch time configurations
class BatchTime {
  final String batchName;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> daysOfWeek; // 1=Mon, 7=Sun
  final int attendanceWindowMinutes; // How long after end time students can mark attendance

  const BatchTime({
    required this.batchName,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.attendanceWindowMinutes = 120, // Default 2 hours after end time
  });
}

const List<BatchTime> kBatchTimes = [
  BatchTime(
    batchName: 'Morning Yoga (7:00-8:00am Tue/Thu/Sat)',
    startTime: TimeOfDay(hour: 7, minute: 0),
    endTime: TimeOfDay(hour: 8, minute: 0),
    daysOfWeek: [2, 4, 6], // Tue, Thu, Sat
  ),
  BatchTime(
    batchName: 'Morning Kickboxing (7:00-8:00am Mon/Wed/Fri)',
    startTime: TimeOfDay(hour: 7, minute: 0),
    endTime: TimeOfDay(hour: 8, minute: 0),
    daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
  ),
  BatchTime(
    batchName: 'Evening Karate (6:30-7:30pm Tue/Thu/Sat)',
    startTime: TimeOfDay(hour: 18, minute: 30),
    endTime: TimeOfDay(hour: 19, minute: 30),
    daysOfWeek: [2, 4, 6], // Tue, Thu, Sat
  ),
  BatchTime(
    batchName: 'Evening Kickboxing (7:15-8:30pm Mon/Wed/Fri)',
    startTime: TimeOfDay(hour: 19, minute: 15),
    endTime: TimeOfDay(hour: 20, minute: 30),
    daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
  ),
  BatchTime(
    batchName: 'Evening Kickboxing (7:30-9:00pm Tue/Thu/Sat)',
    startTime: TimeOfDay(hour: 19, minute: 30),
    endTime: TimeOfDay(hour: 21, minute: 0),
    daysOfWeek: [2, 4, 6], // Tue, Thu, Sat
  ),
];

// Helper function to get batch time configuration
BatchTime? getBatchTime(String batchName) {
  try {
    return kBatchTimes.firstWhere((batch) => batch.batchName == batchName);
  } catch (e) {
    return null;
  }
}

// Helper function to check if student can mark attendance now
bool canMarkAttendanceNow(String batchName) {
  final batchTime = getBatchTime(batchName);
  if (batchTime == null) return false;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final startTime = DateTime(
    today.year,
    today.month,
    today.day,
    batchTime.startTime.hour,
    batchTime.startTime.minute,
  );

  final endTime = DateTime(
    today.year,
    today.month,
    today.day,
    batchTime.endTime.hour,
    batchTime.endTime.minute,
  );

  final attendanceWindowEnd = endTime.add(Duration(minutes: batchTime.attendanceWindowMinutes));

  // Check if today is a valid batch day
  if (!batchTime.daysOfWeek.contains(now.weekday)) return false;

  return now.isAfter(startTime) && now.isBefore(attendanceWindowEnd);
}

// Helper function to get next batch time
DateTime? getNextBatchTime(String batchName) {
  final batchTime = getBatchTime(batchName);
  if (batchTime == null) return null;

  final now = DateTime.now();
  for (int addDays = 0; addDays < 7; addDays++) {
    final candidate = now.add(Duration(days: addDays));
    if (batchTime.daysOfWeek.contains(candidate.weekday)) {
      return DateTime(
        candidate.year,
        candidate.month,
        candidate.day,
        batchTime.startTime.hour,
        batchTime.startTime.minute,
      );
    }
  }
  return null;
} 