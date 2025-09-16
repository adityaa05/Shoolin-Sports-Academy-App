import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum SessionType {
  regular,
  makeup,
  compulsory,
}

enum SessionStatus {
  scheduled,
  completed,
  cancelled,
  holiday,
}

class ClassSession {
  final String? id;
  final String batchName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final SessionType sessionType;
  final SessionStatus status;
  final String? instructorId;
  final String? instructorName;
  final List<String> expectedStudents; // Student IDs who should attend
  final List<String> attendedStudents; // Student IDs who actually attended
  final String? notes;
  final DateTime createdAt;

  ClassSession({
    this.id,
    required this.batchName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.sessionType = SessionType.regular,
    this.status = SessionStatus.scheduled,
    this.instructorId,
    this.instructorName,
    this.expectedStudents = const [],
    this.attendedStudents = const [],
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchName': batchName,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'sessionType': sessionType.name,
      'status': status.name,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'expectedStudents': expectedStudents,
      'attendedStudents': attendedStudents,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassSession.fromMap(Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else {
        return DateTime.now();
      }
    }

    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return ClassSession(
      id: map['id'],
      batchName: map['batchName'],
      date: parseTimestamp(map['date']),
      startTime: parseTime(map['startTime']),
      endTime: parseTime(map['endTime']),
      sessionType: SessionType.values.firstWhere(
        (e) => e.name == (map['sessionType'] ?? 'regular'),
        orElse: () => SessionType.regular,
      ),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'scheduled'),
        orElse: () => SessionStatus.scheduled,
      ),
      instructorId: map['instructorId'],
      instructorName: map['instructorName'],
      expectedStudents: List<String>.from(map['expectedStudents'] ?? []),
      attendedStudents: List<String>.from(map['attendedStudents'] ?? []),
      notes: map['notes'],
      createdAt: parseTimestamp(map['createdAt']),
    );
  }

  ClassSession copyWith({
    String? id,
    String? batchName,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    SessionType? sessionType,
    SessionStatus? status,
    String? instructorId,
    String? instructorName,
    List<String>? expectedStudents,
    List<String>? attendedStudents,
    String? notes,
    DateTime? createdAt,
  }) {
    return ClassSession(
      id: id ?? this.id,
      batchName: batchName ?? this.batchName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      expectedStudents: expectedStudents ?? this.expectedStudents,
      attendedStudents: attendedStudents ?? this.attendedStudents,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  bool get isCompulsory => sessionType == SessionType.compulsory;
  bool get isMakeup => sessionType == SessionType.makeup;
  bool get isRegular => sessionType == SessionType.regular;
  bool get isCompleted => status == SessionStatus.completed;
  bool get isCancelled => status == SessionStatus.cancelled;
  bool get isHoliday => status == SessionStatus.holiday;

  // Get session type display text
  String get sessionTypeText {
    switch (sessionType) {
      case SessionType.regular:
        return 'Regular';
      case SessionType.makeup:
        return 'Make-up';
      case SessionType.compulsory:
        return 'Compulsory';
    }
  }

  // Get status display text
  String get statusText {
    switch (status) {
      case SessionStatus.scheduled:
        return 'Scheduled';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.holiday:
        return 'Holiday';
    }
  }
} 