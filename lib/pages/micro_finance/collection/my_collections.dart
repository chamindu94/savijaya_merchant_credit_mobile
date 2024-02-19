import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:loanprocessingapp/services/members_service.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

import '../../../models/Cluster.dart';
import '../../../services/cluster_service.dart';
import '../../../services/income_service.dart';

class MyCollections extends StatefulWidget {
  final String userName;
  final String userId;

  MyCollections({required this.userName, required this.userId});

  @override
  _MyCollectionsState createState() => _MyCollectionsState();
}

class _MyCollectionsState extends State<MyCollections> {
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  String _cluster = "0";
  String _clusterName = "";

  List<Cluster>? clusterSuggessions;

  final storage = new FlutterSecureStorage();

  GlobalKey<AutoCompleteTextFieldState<Cluster>> keyCluster = new GlobalKey();

  TextEditingController cluster = new TextEditingController(text: "All");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    storage.read(key: "branch").then((branch) {
      ClusterService.readClusterOfBranch(branch: branch!).then((clustersList) {
        clustersList.add(
            Cluster(id: '0', name: 'All', branch: 'a', center_manager: 'a'));
        setState(() {
          clusterSuggessions = clustersList;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var clusterDropDown = (clusterSuggessions == null)
        ? CircularProgressIndicator()
        : SizedBox(
            width: 220,
            child: AutoCompleteTextField<Cluster>(
              key: keyCluster,
              decoration: InputDecoration(
                  labelText: "Center",
                  hintText: "Center",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
              itemSubmitted: (item) {
                setState(() {
                  _cluster = item.id;
                  cluster.text = item.name;
                });
              },
              itemBuilder: (context, suggestion) {
                return Padding(
                    child: ListTile(title: Text(suggestion.name)),
                    padding: EdgeInsets.all(8.0));
              },
              itemSorter: (a, b) => 0,
              itemFilter: (suggestion, input) =>
                  suggestion.name.toLowerCase().startsWith(input.toLowerCase()),
              controller: cluster,
              suggestions: clusterSuggessions!,
              clearOnSubmit: false,
            ),
          );

    var date_picker = TextButton(
        onPressed: () {
          picker.DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: DateTime(2019, 3, 5),
              maxTime: DateTime(2100, 12, 31),
              theme: picker.DatePickerTheme(
                  headerColor: Colors.orange,
                  backgroundColor: Colors.blue,
                  itemStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
              onChanged: (date) {
            print('change $date in time zone ' +
                date.timeZoneOffset.inHours.toString());
          }, onConfirm: (date) {
            setState(() {
              _selectedDate = date;
            });
            print('confirm $date');
          }, currentTime: _selectedDate, locale: picker.LocaleType.en);
        },
        child: Text(
          DateFormat('yyyy-MM-dd').format(_selectedDate),
          style: TextStyle(color: Colors.blue),
        ));

    var collectionWidget = StreamBuilder(
      stream: IncomeService.readCollectionOfDate(
          date: _selectedDate, userId: widget.userId),
      builder: (context, snapshot) {
        int collection = 0;
        if (snapshot.hasData) {
          snapshot.data!.docs.forEach((income) {
            if (_cluster != "0") {
              if (_cluster == income.get("cluster")) {
                collection += int.parse(income.get("amount"));
              }
            } else {
              collection += int.parse(income.get("amount"));
            }
          });
        }

        return Container(
            alignment: Alignment.center,
            child: Column(children: [
              Text(
                "Collection",
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Rs." + collection.toString() + "/=",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              )
            ]));
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Collections"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            date_picker,
            Divider(
              color: Colors.black38,
              thickness: 0.5,
              height: 25,
            ),
            clusterDropDown,
            Divider(
              color: Colors.black38,
              thickness: 0.5,
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("User - " + widget.userName),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Center - " + cluster.text),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            collectionWidget,
            SizedBox(
              height: 30,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: IncomeService.readCollectionOfDate(
                  date: _selectedDate, userId: widget.userId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasData) {
                      return Table(
                        columnWidths: {
                          0: FlexColumnWidth(0.6),
                          1: FlexColumnWidth(0.7),
                          3: FlexColumnWidth(0.4)
                        },
                        border: TableBorder.all(
                            color: Colors.black26,
                            width: 1,
                            style: BorderStyle.solid),
                        children: setTableRows(snapshot),
                      );
                    } else {
                      return Container();
                    }
                }
              },
            )
          ],
        ),
      ),
    );
  }

  TableRow tableRow(element) {
    return TableRow(children: [
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
          child: StreamBuilder<DocumentSnapshot>(
              stream:
                  MembersServices.readMember(id: element.get("loan_member")),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  return Text(
                    snapshot.data!.get("name"),
                  );
                } else {
                  return Text("Member deleted");
                }
              }),
        ),
      )),
      TableCell(
          child: Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Center(
          child: StreamBuilder<DocumentSnapshot>(
              stream:
                  MembersServices.readMember(id: element.get("loan_member")),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  return Text(
                    snapshot.data!.get("dd_code"),
                  );
                } else {
                  return Text("Member deleted");
                }
              }),
        ),
      )),
    ]);
  }

  List<TableRow> setTableRows(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<TableRow> list = [];
    snapshot.data!.docs.forEach((element) {
      if (widget.userId == element.get("added_by")) {
        if (_cluster != "o") {
          if (_cluster == element.get("cluster")) {
            list.add(tableRow(element));
          }
        } else {
          list.add(tableRow(element));
        }
      }
    });

    list.insert(
      0,
      TableRow(children: [
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
                "Loan Member",
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
                "DDA Code",
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
