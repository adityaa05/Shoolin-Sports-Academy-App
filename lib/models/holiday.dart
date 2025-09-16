import 'package:cloud_firestore/cloud_firestore.dart';

class Holiday {
  final String? id;
  final DateTime date;
  final String? batch; // null means all batches
  final String reason;
  final String createdBy;
  final DateTime createdAt;

  Holiday({
    this.id,
    required this.date,
    this.batch,
    required this.reason,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'batch': batch,
      'reason': reason,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Holiday.fromMap(Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else {
        return DateTime.now();
      }
    }

    return Holiday(
      id: map['id'],
      date: parseTimestamp(map['date']),
      batch: map['batch'],
      reason: map['reason'],
      createdBy: map['createdBy'],
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
} 