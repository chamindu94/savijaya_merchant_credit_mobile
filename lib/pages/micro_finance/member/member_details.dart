import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../helpers/helpers.dart';
import '../../../models/Branch.dart';
import '../../../models/Cluster.dart';
import '../../../models/Member.dart';
import '../../../services/branch_service.dart';
import '../../../services/cluster_service.dart';
import '../../../services/income_service.dart';
import '../../../services/members_service.dart';
import 'loan_details_sketch.dart';
import 'previous_loans.dart';
import 'print_details.dart';
import 'personal_details_sketch.dart';

class MemberDetails extends StatefulWidget {
  String documentId;

  MemberDetails(this.documentId);

  @override
  _MemberDetailsState createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  final databaseReference = FirebaseFirestore.instance;
  late AsyncSnapshot<QuerySnapshot> loanDetailsSnapshot;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Member Details"),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.print),
        //     onPressed: () {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) => PrintDetails(loanDetailsSnapshot)));
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: MembersServices.readMember(id: widget.documentId),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return new Text("No Data");
            } else {
              Member member = Member.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>);

              int amount = int.parse(member.loan_amount);
              int interest = int.parse(member.interest);
              int terms = int.parse(member.loanTerm);

              String installment =
                  ((amount + interest) / terms).toStringAsFixed(0);

              String loan_no = member.loan_no;

              String doc_charges = member.document_charges;

              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Personal Details",
                              style: TextStyle(color: Colors.blue[200]),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          PersonalDetailsSketch("Name", member.name),
                          SizedBox(
                            height: 30,
                          ),
                          PersonalDetailsSketch("Mobile Number", member.mobile),
                          SizedBox(
                            height: 30,
                          ),
                          PersonalDetailsSketch("Address", member.address),
                          SizedBox(
                            height: 30,
                          ),
                          FutureBuilder<Cluster>(
                              future: ClusterService.readCluster(
                                  id: member.cluster),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return new Container();
                                }
                                if (!snapshot.hasData) {
                                  return new Container();
                                } else {
                                  return PersonalDetailsSketch(
                                      "Center", snapshot.data!.name);
                                }
                              }),
                          SizedBox(
                            height: 30,
                          ),
                          FutureBuilder<String>(
                              future: ClusterService.readGroupName(
                                  clusterId: member.cluster,
                                  groupId: member.group),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return new Container();
                                }
                                if (!snapshot.hasData) {
                                  return new Container();
                                } else {
                                  return PersonalDetailsSketch(
                                      "Group", snapshot.data!);
                                }
                              }),
                          SizedBox(
                            height: 30,
                          ),
                          PersonalDetailsSketch("NIC Number", member.nic),
                          SizedBox(
                            height: 30,
                          ),
                          PersonalDetailsSketch("DDA Code", member.dd_code),
                          SizedBox(
                            height: 30,
                          ),
                          FutureBuilder<Branch>(
                            future: BranchServices.readBranch(id: member.branch),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return new Container();
                              }
                              if (!snapshot.hasData) {
                                return new Container();
                              } else {
                                return PersonalDetailsSketch("Branch",
                                    MyHelpers.capitalizefirst(snapshot.data!.name));
                              }

                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Wrap(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Loan $loan_no Details",
                              style: TextStyle(color: Colors.blue[200]),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            children: <Widget>[
                              LoanDetailsSketch(
                                  "Amount", member.loan_amount + "/="),
                              LoanDetailsSketch(
                                  "Interest", member.interest + "/="),
                              LoanDetailsSketch("Terms", member.loanTerm),
                              LoanDetailsSketch("Issue Date", member.loan_date),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0),
                            child: StreamBuilder(
                                stream: IncomeService.readMemberPayment(
                                    loanNo: loan_no,
                                    memberId: widget.documentId),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  loanDetailsSnapshot = snapshot;

                                  int total = 0;
                                  int toBePaid = 0;

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (snapshot.hasData) {
                                    snapshot.data!.docs.forEach((element) {
                                      total += int.parse(element.get("amount"));
                                    });

                                    toBePaid = (amount + interest) - total;
                                  }

                                  return Row(
                                    children: [
                                      LoanDetailsSketch(
                                          "Installment", installment + "/="),
                                      LoanDetailsSketch("Total Paid",
                                          total.toString() + "/="),
                                      LoanDetailsSketch("Balance",
                                          toBePaid.toString() + "/="),
                                      LoanDetailsSketch(
                                          "Doc. Charges", doc_charges + "/="),
                                    ],
                                  );
                                }),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 0.7,
                              color: Colors.black12,
                            ),
                          ),
                          Container(
                            child: StreamBuilder(
                                stream: IncomeService.readMemberPayment(
                                    loanNo: loan_no,
                                    memberId: widget.documentId),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.length > 0) {
                                    return Table(
                                      border: TableBorder.all(
                                          color: Colors.black26,
                                          width: 1,
                                          style: BorderStyle.solid),
                                      children: getData(snapshot),
                                    );
                                  } else {
                                    return Align(
                                        alignment: Alignment.center,
                                        child: Text("No Payments Yet"));
                                  }
                                }),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 0.7,
                              color: Colors.black12,
                            ),
                          ),
                          int.parse(loan_no) > 1
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20),
                                    child: ButtonTheme(
                                      minWidth:
                                          MediaQuery.of(context).size.width,
                                      height: 50.0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PreviousLoans(
                                                          widget.documentId,
                                                          int.parse(loan_no))));
                                        },
                                        child: Text(
                                          "VIEW PREVIOUS LOANS",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  getData(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<TableRow> list = [];
    snapshot.data!.docs.asMap().forEach((index, element) {
      var tableRow = TableRow(children: [
        TableCell(
            child: Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Center(
            child: Text(
              (index + 1).toString(),
            ),
          ),
        )),
        TableCell(
            child: Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Center(
            child: Text(
              element.get("amount") + "/=",
            ),
          ),
        )),
        TableCell(
            child: Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Center(
            child: Text(
              DateFormat('yyyy-MM-dd kk:mm')
                  .format(element.get("date").toDate()),
            ),
          ),
        )),
      ]);
      list.add(tableRow);
    });

    list.insert(
      0,
      TableRow(children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                "Installment #",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                "Amount",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                "Date & Time",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ]),
    );

    return list;
  }
}
