import 'package:cloud_firestore/cloud_firestore.dart';

class SavingTransaction {
  String? id;
  String amount;
  DateTime dateTime;
  String? memberId;
  String status;

  SavingTransaction(
      {this.id,
      required this.amount,
      required this.dateTime,
      this.memberId,
      required this.status});

  // Factory method to convert a Firestore document to an object
  factory SavingTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavingTransaction(
      id: doc.id,
      amount: data['amount'] ?? '',
      dateTime: data['dateTime'].toDate() ?? '',
      memberId: data['memberId'] ?? '',
      status: data['status'] ?? '',
    );
  }

  // Convert object to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'dateTime': dateTime,
      'status': status,
    };
  }
}
