import 'package:cloud_firestore/cloud_firestore.dart';

class Branch {
  Branch({required this.id, required this.name, required this.address, required this.phone});

  final String id;
  final String name;
  final String address;
  final String phone;

  // Factory method to convert a Firestore document to an object
  factory Branch.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Branch(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}