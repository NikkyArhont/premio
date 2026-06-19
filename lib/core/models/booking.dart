import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class Booking {
  final String id;
  final String saunaId;
  final String saunaName;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.saunaId,
    required this.saunaName,
    required this.userId,
    required this.userName,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String documentId) {
    BookingStatus parsedStatus;
    switch (map['status']) {
      case 'confirmed':
        parsedStatus = BookingStatus.confirmed;
        break;
      case 'cancelled':
        parsedStatus = BookingStatus.cancelled;
        break;
      case 'completed':
        parsedStatus = BookingStatus.completed;
        break;
      case 'pending':
      default:
        parsedStatus = BookingStatus.pending;
        break;
    }

    return Booking(
      id: documentId,
      saunaId: map['saunaId'] ?? '',
      saunaName: map['saunaName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: parsedStatus,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'saunaId': saunaId,
      'saunaName': saunaName,
      'userId': userId,
      'userName': userName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
