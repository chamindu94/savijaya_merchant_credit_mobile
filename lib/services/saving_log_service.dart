import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection =
_firestore.collection('saving_logs');

class SavingLogsService {
  static Future<Response> addLog(data) async {
    Response response = Response();
    DocumentReference documentReferencer =
    _Collection.doc(DateTime.now().millisecondsSinceEpoch.toString());

    var result = await documentReferencer.set(data).whenComplete(() {
      response.code = 200;
      response.message = "Transaction added successfully";
    }).catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }
}