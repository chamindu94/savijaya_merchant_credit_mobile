import 'package:cloud_firestore/cloud_firestore.dart';

class Cluster {
  final String id;
  final String name;
  final String branch;
  final String center_manager;

  Cluster(
      {required this.id,
      required this.name,
      required this.branch,
      required this.center_manager});

  // Factory method to convert a Firestore document to an object
  factory Cluster.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Cluster(
      id: doc.id,
      name: data['name'] ?? '',
      branch: data['branch'] ?? '',
      center_manager: data['center_manager'] ?? '',
    );
  }
}
