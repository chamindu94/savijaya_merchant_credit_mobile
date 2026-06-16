import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Income.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('income');

class IncomeService {
  static Stream<QuerySnapshot> readMemberPayment(
      {required String memberId, required String loanNo}) {
    return _Collection.where("loan_member", isEqualTo: memberId)
        .where("loan_no", isEqualTo: loanNo)
        .snapshots();
  }

  static Stream<QuerySnapshot> readCollectionOfDate(
      {required DateTime date, required String userId}) {
    DateTime nextDate = date.add(Duration(days: 1));

    Stream<QuerySnapshot> result = _Collection
        .where("date", isGreaterThan: date)
        .where("date", isLessThan: nextDate)
        .where("added_by", isEqualTo: userId)
        .snapshots();

    return result;
  }

  static Stream<List<Income>> readMemberPaymentAsList(
      {required String memberId, required String loanNo}) {
    return _Collection.where("loan_member", isEqualTo: memberId)
        .where("loan_no", isEqualTo: loanNo)
        .orderBy("date")
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Income.fromFirestore(doc)).toList());
  }
}
