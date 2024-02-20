import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Cluster.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('clusters');

class ClusterService {

  static Future<List<Cluster>> readClusterOfBranch({required String branch}) async {
    List<Cluster> list = [];

    QuerySnapshot snapshot = await _Collection.where("branch", isEqualTo: branch).orderBy("name").get();

    if (snapshot.docs.isNotEmpty) {
      list = snapshot.docs.map((doc) => Cluster.fromFirestore(doc)).toList();
    }

    return list;
  }

  static Future<Cluster> readCluster({required String id}) async {
    DocumentSnapshot doc = await _Collection.doc(id).get();

    if (doc.exists) {
      return Cluster.fromFirestore(doc);
    } else {
      throw Exception("Center not found");
    }
  }

  static Future<String> readGroupName({required String clusterId, required String groupId}) async {
    DocumentSnapshot doc = await _Collection.doc(clusterId).collection("groups").doc(groupId).get();

    if (doc.exists) {
      return doc["name"];
    } else {
      throw Exception("Center not found");
    }
  }
}
