import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
}

enum AttendanceMarkedBy {
  student,
  instructor,
  admin,
}

class Attendance {
  final String? id;
  final String studentId;
  final DateTime date;
  final bool isPresent;
  final String batch;
  final String? notes;
  final String? markedBy;
  final AttendanceStatus status;
  final AttendanceMarkedBy markedByType;
  final DateTime? markedAt;
  final String? markedByUserId; // User ID of who marked it
  final bool isActive;
  final DateTime? deactivatedAt;

  Attendance({
    this.id,
    required this.studentId,
    required this.date,
    required this.isPresent,
    required this.batch,
    this.notes,
    this.markedBy,
    this.status = AttendanceStatus.present,
    this.markedByType = AttendanceMarkedBy.instructor,
    this.markedAt,
    this.markedByUserId,
    this.isActive = true,
    this.deactivatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'isPresent': isPresent ? 1 : 0,
      'batch': batch,
      'notes': notes,
      'markedBy': markedBy,
      'status': status.name,
      'markedByType': markedByType.name,
      'markedAt': markedAt?.toIso8601String(),
      'markedByUserId': markedByUserId,
      'isActive': isActive ? 1 : 0,
      'deactivatedAt': deactivatedAt?.toIso8601String(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      throw Exception('Invalid date type');
    }
    return Attendance(
      id: id,
      studentId: data['studentId'],
      date: parseDate(data['date']),
      isPresent: data['isPresent'] == 1 || data['isPresent'] == true,
      batch: data['batch'],
      notes: data['notes'],
      markedBy: data['markedBy'],
      status: data['status'] != null ? AttendanceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AttendanceStatus.present,
      ) : AttendanceStatus.present,
      markedByType: data['markedByType'] != null ? AttendanceMarkedBy.values.firstWhere(
        (e) => e.name == data['markedByType'],
        orElse: () => AttendanceMarkedBy.instructor,
      ) : AttendanceMarkedBy.instructor,
      markedAt: data['markedAt'] != null ? parseDate(data['markedAt']) : null,
      markedByUserId: data['markedByUserId'],
      isActive: data['isActive'] == null ? true : (data['isActive'] == 1 || data['isActive'] == true),
      deactivatedAt: data['deactivatedAt'] != null ? parseDate(data['deactivatedAt']) : null,
    );
  }

  Attendance copyWith({
    String? id,
    String? studentId,
    DateTime? date,
    bool? isPresent,
    String? batch,
    String? notes,
    String? markedBy,
    AttendanceStatus? status,
    AttendanceMarkedBy? markedByType,
    DateTime? markedAt,
    String? markedByUserId,
    bool? isActive,
    DateTime? deactivatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      isPresent: isPresent ?? this.isPresent,
      batch: batch ?? this.batch,
      notes: notes ?? this.notes,
      markedBy: markedBy ?? this.markedBy,
      status: status ?? this.status,
      markedByType: markedByType ?? this.markedByType,
      markedAt: markedAt ?? this.markedAt,
      markedByUserId: markedByUserId ?? this.markedByUserId,
      isActive: isActive ?? this.isActive,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }

  // Helper method to get status color
  Color getStatusColor() {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  // Helper method to get status text
  String getStatusText() {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  // Helper method to get marked by text
  String getMarkedByText() {
    switch (markedByType) {
      case AttendanceMarkedBy.student:
        return 'Self';
      case AttendanceMarkedBy.instructor:
        return 'Instructor';
      case AttendanceMarkedBy.admin:
        return 'Admin';
    }
  }
} 