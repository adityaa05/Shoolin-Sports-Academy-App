import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String? id;
  final String studentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String status; // 'pending', 'completed', 'failed'
  final String batch;
  final String? transactionId;
  final String? notes;
  final bool isActive;
  final DateTime? deactivatedAt;

  Payment({
    this.id,
    required this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    required this.batch,
    this.transactionId,
    this.notes,
    this.isActive = true,
    this.deactivatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
      'batch': batch,
      'transactionId': transactionId,
      'notes': notes,
      'isActive': isActive ? 1 : 0,
      'deactivatedAt': deactivatedAt?.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> data) {
    // Handle paymentDate field - could be Timestamp or String
    DateTime paymentDate;
    if (data['paymentDate'] is Timestamp) {
      paymentDate = (data['paymentDate'] as Timestamp).toDate();
    } else if (data['paymentDate'] is String) {
      paymentDate = DateTime.parse(data['paymentDate']);
    } else {
      paymentDate = DateTime.now(); // fallback
    }

    return Payment(
      id: data['id'],
      studentId: data['studentId'],
      amount: data['amount'],
      paymentDate: paymentDate,
      paymentMethod: data['paymentMethod'],
      status: data['status'],
      batch: data['batch'],
      transactionId: data['transactionId'],
      notes: data['notes'],
      isActive: data['isActive'] == null ? true : (data['isActive'] == 1 || data['isActive'] == true),
      deactivatedAt: data['deactivatedAt'] != null ? DateTime.parse(data['deactivatedAt']) : null,
    );
  }

  Payment copyWith({
    String? id,
    String? studentId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? status,
    String? batch,
    String? transactionId,
    String? notes,
    bool? isActive,
    DateTime? deactivatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      batch: batch ?? this.batch,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }
} 