import 'package:cloud_firestore/cloud_firestore.dart';

class Instructor {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final List<String> assignedBatches;
  final DateTime createdAt;

  Instructor({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.assignedBatches,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'assignedBatches': assignedBatches,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Instructor.fromMap(Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else {
        return DateTime.now();
      }
    }

    return Instructor(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
      isActive: map['isActive'] ?? true,
      assignedBatches: List<String>.from(map['assignedBatches'] ?? []),
      createdAt: parseTimestamp(map['createdAt']),
    );
  }

  Instructor copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    List<String>? assignedBatches,
    DateTime? createdAt,
  }) {
    return Instructor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      assignedBatches: assignedBatches ?? this.assignedBatches,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 