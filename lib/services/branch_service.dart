import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Branch.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('branches');

class BranchServices {
  static Future<Branch> readBranch({required String id}) async {
    DocumentSnapshot doc = await _Collection.doc(id).get();

    if (doc.exists) {
      return Branch.fromFirestore(doc);
    } else {
      throw Exception("Branch not found");
    }
  }
}
