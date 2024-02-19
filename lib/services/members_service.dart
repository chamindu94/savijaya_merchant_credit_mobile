import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loanprocessingapp/models/Member.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('members');

class MembersServices {
  static Stream<DocumentSnapshot> readMember({required String id}) {
    return _Collection.doc(id).snapshots();
  }

  static Stream<QuerySnapshot> readMemberOfCenter(
      {required List<String> clusters}) {
    return _Collection.where("cluster", isEqualTo: clusters).snapshots();
  }

  static Future<List<Member>> readMemberOfGroup(
      {required String cluster, required String group}) async {
    List<Member> list = [];

    QuerySnapshot snapshot =
        await _Collection.where("cluster", isEqualTo: cluster)
            .where("group", isEqualTo: group)
            .get();

    if (snapshot.docs.isNotEmpty) {
      list = snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();
    }

    return list;
  }

  static Future<List<Member>> readActiveMemberOfBranch(
      {required String branch}) async {
    List<Member> list = [];

    QuerySnapshot snapshot =
    await _Collection.where("branch", isEqualTo: branch)
        .get();

    if (snapshot.docs.isNotEmpty) {
      list = snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();
    }

    return list;
  }
}
