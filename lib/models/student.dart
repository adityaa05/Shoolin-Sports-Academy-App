import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final List<String> batches; // Changed from single batch to multiple batches
  final bool isActive;
  final DateTime createdAt;
  final String classType; // 'karate', 'kickboxing', 'yoga'
  final double monthlyFee;
  final int? preferredPaymentDay; // New: preferred day of month for payment reminder
  final int paymentDurationMonths; // New: how many months the payment covers
  final DateTime lastPaymentDate; // New: when the last payment was made

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.batches, // Changed from batch to batches
    required this.isActive,
    required this.createdAt,
    required this.classType,
    required this.monthlyFee,
    this.preferredPaymentDay, // New
    this.paymentDurationMonths = 1, // New, default to 1 month
    DateTime? lastPaymentDate, // New
  }) : lastPaymentDate = lastPaymentDate ?? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'batches': batches, // Changed from batch to batches
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'classType': classType,
      'monthlyFee': monthlyFee,
      'preferredPaymentDay': preferredPaymentDay, // New
      'paymentDurationMonths': paymentDurationMonths, // New
      'lastPaymentDate': lastPaymentDate.toIso8601String(), // New
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    // Handle both old format (single batch) and new format (multiple batches)
    List<String> studentBatches = [];
    if (map['batches'] != null) {
      // New format: multiple batches
      studentBatches = List<String>.from(map['batches']);
    } else if (map['batch'] != null) {
      // Old format: single batch - migrate to new format
      studentBatches = [map['batch']];
    }

    // Handle createdAt field - could be Timestamp or String
    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAt = DateTime.parse(map['createdAt']);
    } else {
      createdAt = DateTime.now(); // fallback
    }

    double fee = 1000.0;
    if (map['monthlyFee'] != null) {
      if (map['monthlyFee'] is int) {
        fee = (map['monthlyFee'] as int).toDouble();
      } else if (map['monthlyFee'] is double) {
        fee = map['monthlyFee'];
      } else if (map['monthlyFee'] is String) {
        fee = double.tryParse(map['monthlyFee']) ?? 1000.0;
      }
    }
    // New: preferredPaymentDay
    int? preferredDay;
    if (map['preferredPaymentDay'] != null) {
      if (map['preferredPaymentDay'] is int) {
        preferredDay = map['preferredPaymentDay'];
      } else if (map['preferredPaymentDay'] is String) {
        preferredDay = int.tryParse(map['preferredPaymentDay']);
      }
    }
    preferredDay ??= 1; // Default to 1 if not set

    // New: paymentDurationMonths
    int duration = 1;
    if (map['paymentDurationMonths'] != null) {
      if (map['paymentDurationMonths'] is int) {
        duration = map['paymentDurationMonths'];
      } else if (map['paymentDurationMonths'] is String) {
        duration = int.tryParse(map['paymentDurationMonths']) ?? 1;
      }
    }
    // New: lastPaymentDate
    DateTime lastPaymentDate = createdAt;
    if (map['lastPaymentDate'] != null) {
      if (map['lastPaymentDate'] is Timestamp) {
        lastPaymentDate = (map['lastPaymentDate'] as Timestamp).toDate();
      } else if (map['lastPaymentDate'] is String) {
        lastPaymentDate = DateTime.tryParse(map['lastPaymentDate']) ?? createdAt;
      }
    }
    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      batches: studentBatches, // Changed from batch to batches
      isActive: map['isActive'] == 1,
      createdAt: createdAt,
      classType: map['classType'] ?? 'kickboxing', // default to kickboxing if missing
      monthlyFee: fee,
      preferredPaymentDay: preferredDay, // New
      paymentDurationMonths: duration, // New
      lastPaymentDate: lastPaymentDate, // New
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    List<String>? batches, // Changed from batch to batches
    bool? isActive,
    DateTime? createdAt,
    String? classType,
    double? monthlyFee,
    int? preferredPaymentDay, // New
    int? paymentDurationMonths, // New
    DateTime? lastPaymentDate, // New
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      batches: batches ?? this.batches, // Changed from batch to batches
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      classType: classType ?? this.classType,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      preferredPaymentDay: preferredPaymentDay ?? this.preferredPaymentDay, // New
      paymentDurationMonths: paymentDurationMonths ?? this.paymentDurationMonths, // New
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate, // New
    );
  }

  // Helper method to check if student is in a specific batch
  bool isInBatch(String batch) {
    return batches.contains(batch);
  }

  // Helper method to get primary batch (first one)
  String? get primaryBatch => batches.isNotEmpty ? batches.first : null;
} 