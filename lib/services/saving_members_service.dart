import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/SavingMember.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('saving_members');

class SavingMembersServices {
  static Stream<DocumentSnapshot> readMember({required String id}) {
    return _Collection.doc(id).snapshots();
  }

  static Future<List<SavingMember>> readMembers() async {
    List<SavingMember> list = [];

    QuerySnapshot snapshot = await _Collection.get();

    if (snapshot.docs.isNotEmpty) {
      list = snapshot.docs.map((doc) => SavingMember.fromFirestore(doc)).toList();
    }

    return list;
  }
}
