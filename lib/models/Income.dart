import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  Income(
      {required this.id,
      required this.added_by,
      required this.amount,
      required this.branch,
      required this.cluster,
      required this.date,
      required this.loan_member,
      required this.loan_no});

  final String id;
  final String added_by;
  final String amount;
  final String branch;
  final String cluster;
  final Timestamp date;
  final String loan_member;
  final String loan_no;

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
        id: json['id'],
        added_by: json['added_by'],
        amount: json['amount'],
        branch: json['branch'],
        cluster: json['cluster'],
        date: json['date'],
        loan_member: json['loan_member'],
        loan_no: json['loan_no'],);
  }

  toJson() {
    return {
      'id': id,
      'added_by': added_by,
      'amount': amount,
      'branch': branch,
      'cluster': cluster,
      'date': date,
      'loan_member': loan_member,
      'loan_no': loan_no,
    };
  }
}
