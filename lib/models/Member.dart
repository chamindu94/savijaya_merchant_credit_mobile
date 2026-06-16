import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String name;
  final String name_with_initials;
  final String mobile;
  final String address;
  final String gur_1_name;
  final String gur_1_mobile;
  final String gur_1_address;
  final String gur_2_name;
  final String gur_2_mobile;
  final String gur_2_address;
  final String gur_3_name;
  final String gur_3_mobile;
  final String gur_3_address;
  final String branch;
  final String nic;
  final String cluster;
  final String dd_code;
  final String toPaid;
  final String loan_no;
  final String loan_amount;
  final String interest;
  final String loanTerm;
  final String group;
  final String loan_date;
  final String document_charges;
  final String schedule;

  Member(
      {required this.id,
      required this.name,
      required this.name_with_initials,
      required this.mobile,
      required this.address,
      required this.gur_1_name,
      required this.gur_1_mobile,
      required this.gur_1_address,
      required this.gur_2_name,
      required this.gur_2_mobile,
      required this.gur_2_address,
      required this.gur_3_name,
      required this.gur_3_mobile,
      required this.gur_3_address,
      required this.branch,
      required this.nic,
      required this.cluster,
      required this.dd_code,
      required this.toPaid,
      required this.loan_no,
      required this.loan_amount,
      required this.interest,
      required this.loanTerm,
      required this.group,
      required this.loan_date,
      required this.document_charges,
      required this.schedule,
      });

  // Factory method to convert a Firestore document to an object
  factory Member.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Member(
      id: doc.id,
        name: data['name'] ?? "",
        name_with_initials: data['name_with_initials'] ?? "",
        mobile: data['mobile'] ?? "",
        address: data['address'] ?? "",
        gur_1_name: data['gur_1_name'] ?? "",
        gur_1_mobile: data['gur_1_mobile'] ?? "",
        gur_1_address: data['gur_1_address'] ?? "",
        gur_2_name: data['gur_2_name'] ?? "",
        gur_2_mobile: data['gur_2_mobile'] ?? "",
        gur_2_address: data['gur_2_address'] ?? "",
        gur_3_name: data['gur_3_name'] ?? "",
        gur_3_mobile: data['gur_3_mobile'] ?? "",
        gur_3_address: data['gur_3_address'] ?? "",
        branch: data['branch'] ?? "",
        nic: data['nic'] ?? "",
        cluster: data['cluster'] ?? "",
        dd_code: data['dd_code'] ?? "",
        toPaid: data['toPaid'] ?? "",
        loan_no: data['loan_no'] ?? "",
        loan_amount: data['loan_amount'] ?? "",
        interest: data['interest'] ?? "",
        loanTerm: data['loanTerm'] ?? "",
        group: data['group'] ?? "",
        loan_date: data['loan_date'] ?? "",
        document_charges: data['document_charges'] ?? "",
        schedule: data['schedule'] ?? "",
    );
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
        id: json['id'] ?? "",
        name: json['name'] ?? "",
        name_with_initials: json['name_with_initials'] ?? "",
        mobile: json['mobile'] ?? "",
        address: json['address'] ?? "",
        gur_1_name: json['gur_1_name'] ?? "",
        gur_1_mobile: json['gur_1_mobile'] ?? "",
        gur_1_address: json['gur_1_address'] ?? "",
        gur_2_name: json['gur_2_name'] ?? "",
        gur_2_mobile: json['gur_2_mobile'] ?? "",
        gur_2_address: json['gur_2_address'] ?? "",
        gur_3_name: json['gur_3_name'] ?? "",
        gur_3_mobile: json['gur_3_mobile'] ?? "",
        gur_3_address: json['gur_3_address'] ?? "",
        branch: json['branch'] ?? "",
        nic: json['nic'] ?? "",
        cluster: json['cluster'] ?? "",
        dd_code: json['dd_code'] ?? "",
        toPaid: json['toPaid'] ?? "",
        loan_no: json['loan_no'] ?? "",
        loan_amount: json['loan_amount'] ?? "",
        interest: json['interest'] ?? "",
        loanTerm: json['loanTerm'] ?? "",
        group: json['group'] ?? "",
        loan_date: json['loan_date'] ?? "",
        document_charges: json['document_charges'] ?? "",
        schedule: json['schedule'] ?? "",
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'name_with_initials': name_with_initials,
      'mobile': mobile,
      'address': address,
      'gur_1_name': gur_1_name,
      'gur_1_mobile': gur_1_mobile,
      'gur_1_address': gur_1_address,
      'gur_2_name': gur_2_name,
      'gur_2_mobile': gur_2_mobile,
      'gur_2_address': gur_2_address,
      'gur_3_name': gur_3_name,
      'gur_3_mobile': gur_3_mobile,
      'gur_3_address': gur_3_address,
      'branch': branch,
      'nic': nic,
      'cluster': cluster,
      'dd_code': dd_code,
      'toPaid': toPaid,
      'loan_no': loan_no,
      'loan_amount': loan_amount,
      'interest': interest,
      'loanTerm': loanTerm,
      'group': group,
      'loan_date': loan_date,
      'document_charges': document_charges,
      'schedule': schedule,
    };
  }
}
