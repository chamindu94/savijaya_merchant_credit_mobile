import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../../models/Member.dart';
import '../../../services/members_service.dart';
import 'print_receipt.dart';

class AddPayment extends StatefulWidget {
  final String groupId;
  final String clusterId;
  final String clusterName;

  AddPayment(
      {required this.groupId,
      required this.clusterId,
      required this.clusterName});

  @override
  _AddPaymentState createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  List<Member>? groupMembers;

  String _searchKeyword = "";
  String _searchBy = 'name';

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    MembersServices.readMemberOfGroup(
            cluster: widget.clusterId, group: widget.groupId)
        .then((value) {
      List<Member> tmp = [];

      value.forEach((element) {
        if (int.parse(element.toPaid) > 0) {
          tmp.add(element);
        }
      });

      setState(() {
        groupMembers = tmp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Add Payment"),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.orange[400],
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  DropdownButton(
                    focusColor: Colors.white,
                    value: _searchBy,
                    items: [
                      DropdownMenuItem(
                        child: Text("Name"),
                        value: "name",
                      ),
                      DropdownMenuItem(
                        child: Text("NIC"),
                        value: "nic",
                      ),
                      DropdownMenuItem(
                        child: Text("DDA"),
                        value: "dd_code",
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        _searchBy = value!;
                      });
                    },
                  ),
                  TextField(
                    autofocus: false,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black45,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Search",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onChanged: (value) {
                      setState(() {
                        _searchKeyword = value;
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
          ),
          groupMembers == null
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: groupMembers!.length,
                  itemBuilder: (buildContext, index) =>
                      MemberRow(groupMembers![index], widget.clusterName),
                )),
        ],
      ),
    );
  }
}

class MemberRow extends StatefulWidget {
  final Member member;
  final String clusterName;

  MemberRow(this.member, this.clusterName);

  @override
  _MemberRowState createState() => _MemberRowState();
}

class _MemberRowState extends State<MemberRow> {
  final databaseReference = FirebaseFirestore.instance;

  TextEditingController amountController = new TextEditingController();

  double installment = 0;
  int loanAmount = 0;
  int amountToPay = 0;
  String payment = "";

  List<String> logs = [];

  late BuildContext dContext;

  late Member _selectedMember;

  late ProgressDialog pr;

  DateTime? today;

  @override
  void initState() {
    super.initState();
    setDateAndTime();
  }

  setDateAndTime() async {
    var currentTime = await NTP.now();
    setState(() {
      today = currentTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context);
    return Card(
      child: InkWell(
        onTap: () {
          int amount = int.parse(widget.member.loan_amount);
          int interest = int.parse(widget.member.interest);
          int terms = int.parse(widget.member.loanTerm);
          String loan_no = widget.member.loan_no;

          installment = (amount + interest) / terms;
          loanAmount = amount + interest;

          amountController =
              new TextEditingController(text: installment.toStringAsFixed(0));

          //to avoid data change after. When get directly, member name changed on receipt and log
          _selectedMember = widget.member;

          displayDialog(context, loan_no);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.person_pin,
                  size: 40,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(widget.member.dd_code),
                    SizedBox(height: 5),
                    (today == null)
                        ? CircularProgressIndicator()
                        : StreamBuilder<QuerySnapshot>(
                            stream: databaseReference
                                .collection("income")
                                .where("loan_member",
                                    isEqualTo: widget.member.id)
                                .where("loan_no",
                                    isEqualTo: widget.member.loan_no)
                                .snapshots(),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return const Center(
                                      child: CircularProgressIndicator());

                                default:
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.length > 0) {
                                    var formatter =
                                        new DateFormat('yyyy-MM-dd');
                                    var _firstDayOfTheweek = today!.subtract(
                                        new Duration(days: today!.weekday - 1));
                                    var _lastDayOfTheweek = today!.add(
                                        new Duration(
                                            days: DateTime.daysPerWeek -
                                                today!.weekday));

                                    var _firstDayOfTheWeekTimestamp =
                                        DateTime.parse(formatter
                                                .format(_firstDayOfTheweek))
                                            .millisecondsSinceEpoch;
                                    var _lastDayOfTheWeekTimestamp =
                                        DateTime.parse(formatter
                                                .format(_lastDayOfTheweek))
                                            .millisecondsSinceEpoch;
                                    var _dateToCheckTimestamp = snapshot.data!
                                        .docs[snapshot.data!.docs.length - 1]
                                        .get("date")
                                        .toDate()
                                        .millisecondsSinceEpoch;

                                    String statusText = "";
                                    Color color = Colors.green;

                                    if (_firstDayOfTheWeekTimestamp <=
                                            _dateToCheckTimestamp &&
                                        _lastDayOfTheWeekTimestamp >=
                                            _dateToCheckTimestamp) {
                                      statusText = "Done";
                                      color = Colors.green;
                                    } else {
                                      statusText = "Pending";
                                      color = Colors.red;
                                    }

                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          statusText +
                                              " - " +
                                              DateFormat('yyyy-MM-dd kk:mm')
                                                  .format(snapshot
                                                      .data!
                                                      .docs[snapshot.data!.docs
                                                              .length -
                                                          1]
                                                      .get("date")
                                                      .toDate()),
                                          style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Text("No Payment Yet");
                                  }
                              }
                            }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  displayDialog(BuildContext context, loan_no) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: new Text("Mark Installment"),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Amount"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new TextButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          new TextButton(
            child: new Text("Add"),
            onPressed: () async {
              pr.show();
              try {
                final result = await InternetAddress.lookup('google.com');
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  databaseReference
                      .collection("members")
                      .doc(widget.member.id)
                      .get()
                      .then((memberDetails) {
                    int to_paid = int.parse(memberDetails.data()!["toPaid"]);
                    int amount = int.parse(amountController.text);

                    if (amount > to_paid) {
                      pr.hide();

                      Fluttertoast.showToast(
                          msg: "Balance exceeded. Only $to_paid to pay",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      amountToPay = to_paid - int.parse(amountController.text);
                      payment = amountController.text;

                      dContext = dialogContext;

                      createRecord();
                    }
                  });
                }
              } on SocketException catch (_) {
                pr.hide();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text("Error"),
                      content: new Text("No internet connection..!"),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        new TextButton(
                          child: new Text("Close"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void createRecord() async {
    final storage = new FlutterSecureStorage();

    DateTime now = await NTP.now();

    var batch = databaseReference.batch();

    await storage.read(key: "userId").then((userId) {
      storage.read(key: "branch").then((branch) {
        //set today income
        var todIncRef = databaseReference
            .collection("income")
            .doc(now.millisecondsSinceEpoch.toString());
        batch.set(todIncRef, {
          'amount': payment,
          'added_by': userId,
          'loan_member': widget.member.id,
          'cluster': widget.member.cluster,
          'date': now,
          'branch': branch,
          'loan_no': widget.member.loan_no,
          'toPaid': amountToPay,
          'installment': installment
        });

        //update to paid amount
        var toPaidRef =
            databaseReference.collection("members").doc(widget.member.id);
        batch.update(toPaidRef, {'toPaid': amountToPay.toString()});

        //set log
        var logRef = databaseReference
            .collection("logs")
            .doc(now.millisecondsSinceEpoch.toString());
        batch.set(logRef, {
          'log': _selectedMember.name +
              " 's installment of Rs." +
              payment +
              "/= added successfully. Balance - " +
              amountToPay.toString(),
          'date': now,
          'operator': userId,
          'type': "payment_log",
          'branch': branch
        });

        //commit batch
        batch.commit().then((value) {
          pr.hide();

          Navigator.of(dContext).pop();

          Navigator.push(
              dContext,
              MaterialPageRoute(
                  builder: (context) => PrintReceipt(
                      payment.toString(),
                      amountToPay.toString(),
                      _selectedMember,
                      widget.clusterName)));
        }).catchError((onError) {
          pr.hide();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Error"),
                content: new Text("Network error occurred. Please try again."),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new TextButton(
                    child: new Text("Try Again"),
                    onPressed: () {
                      createRecord();
                    },
                  ),
                ],
              );
            },
          );
        });
      });
    });
  }
}
