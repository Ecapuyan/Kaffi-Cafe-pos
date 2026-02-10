import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String code;
  final double discount;
  final String discountType; // 'percentage' or 'fixed'
  final Timestamp expiryDate;
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.discount,
    required this.discountType,
    required this.expiryDate,
    required this.isActive,
  });

  // Factory constructor to create a Voucher from a Firestore document
  factory Voucher.fromMap(Map<String, dynamic> data, String documentId) {
    return Voucher(
      id: documentId,
      code: data['code'] ?? '',
      discount: (data['discount'] ?? 0).toDouble(),
      discountType: data['discountType'] ?? 'fixed',
      expiryDate: data['expiryDate'] ?? Timestamp.now(),
      isActive: data['isActive'] ?? false,
    );
  }

  // Method to convert a Voucher object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discount': discount,
      'discountType': discountType,
      'expiryDate': expiryDate,
      'isActive': isActive,
    };
  }
}
