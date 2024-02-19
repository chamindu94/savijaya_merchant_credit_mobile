import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/income_service.dart';

class PreviousLoans extends StatefulWidget {
  String documentId;
  int loan_numbers;

  PreviousLoans(this.documentId, this.loan_numbers);

  @override
  _PreviousLoansState createState() => _PreviousLoansState();
}

class _PreviousLoansState extends State<PreviousLoans> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Previous Loans"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: getView(),
        ),
      ),
    );
  }

  List<Widget> getView() {
    List<Widget> loans = [];
    for (int i = 1; i < widget.loan_numbers; i++) {
      var loan_view = Container(
        padding: EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Loan $i Details",
                    style: TextStyle(color: Colors.blue[200]),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                  stream: IncomeService.readMemberPayment(
                      loanNo: i.toString(), memberId: widget.documentId),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasData) {
                      return Table(
                        border: TableBorder.all(
                            color: Colors.black26,
                            width: 1,
                            style: BorderStyle.solid),
                        children: getData(snapshot),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      );

      loans.add(loan_view);
    }

    return loans;
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
