import 'package:cloud_firestore/cloud_firestore.dart';

class SavingMember {
  final String id;
  final String memberNumber;
  final String memberName;
  final String nic;
  final String mobile;

  SavingMember(
      {required this.id,
      required this.memberNumber,
      required this.memberName,
      required this.nic,
      required this.mobile});

  // Factory method to convert a Firestore document to an object
  factory SavingMember.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavingMember(
      id: doc.id,
      memberNumber: data['memberNumber'] ?? '',
      memberName: data['memberName'] ?? '',
      nic: data['nic'] ?? '',
      mobile: data['mobile'] ?? '',
    );
  }
}
