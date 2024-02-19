import 'package:cloud_firestore/cloud_firestore.dart';

class Installment {
  String id;
  String amount;
  Timestamp date;
  String loan_no;

  Installment(
      this.id,
      this.amount,
      this.date,
      this.loan_no
      );
}