import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'add_payment.dart';

class PaymentGroups extends StatefulWidget {
  String clusterId;
  String clusterName;

  PaymentGroups(this.clusterId, this.clusterName);

  @override
  _PaymentGroupsState createState() => _PaymentGroupsState();
}

class _PaymentGroupsState extends State<PaymentGroups> {
  List<DocumentSnapshot> list = [];

  String _searchKeyword = "";

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Groups"),
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
                  TextField(
                    autofocus: false,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black45,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Search Center",
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("clusters")
                    .doc(widget.clusterId)
                    .collection("groups")
                    .orderBy("name")
                    .snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.length == 0) {
                        return new Column(
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.black26,
                            ),
                            Center(
                                child: Text(
                              "No records found yet!",
                              style: TextStyle(fontSize: 16),
                            )),
                          ],
                        );
                      } else {
                        list = [];
                        snapshot.data!.docs.forEach((element) {
                          if (_searchKeyword == "") {
                            list.add(element);
                          } else {
                            if (element
                                .get("name")
                                .toString()
                                .toLowerCase()
                                .contains(_searchKeyword.toLowerCase())) {
                              list.add(element);
                            }
                          }
                        });

                        return ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: list.length,
                          itemBuilder: (buildContext, index) =>
                              MemberRow(list[index], widget.clusterId, widget.clusterName),
                        );
                      }
                  }
                }),
          ),
        ],
      ),
    );
  }
}

class MemberRow extends StatefulWidget {
  final DocumentSnapshot group;
  String clusterId;
  String clusterName;

  MemberRow(this.group, this.clusterId, this.clusterName);

  @override
  _MemberRowState createState() => _MemberRowState();
}

class _MemberRowState extends State<MemberRow> {
  final databaseReference = FirebaseFirestore.instance;

  TextEditingController deleteController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Slidable(
          key: const ValueKey(0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPayment(
                          groupId: widget.group.id,
                          clusterId: widget.clusterId,
                        clusterName: widget.clusterName)));
            },
            child: Container(
              color: Colors.white,
              child: new ListTile(
                leading: new CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: new Icon(Icons.group),
                  foregroundColor: Colors.white,
                ),
                title: Text(widget.group.get("name")),
                subtitle: StreamBuilder<QuerySnapshot>(
                    stream: databaseReference
                        .collection("members")
                        .where("cluster", isEqualTo: widget.clusterId)
                        .where("group", isEqualTo: widget.group.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Center(
                              child: CircularProgressIndicator());
                        default:
                          if (snapshot.hasData) {
                            int count = 0;
                            snapshot.data!.docs.forEach((element) {
                              if (int.parse(element.get("toPaid")) > 0) {
                                count++;
                              }
                            });
                            return Text("Members : " + count.toString());
                          } else {
                            return Text("Members : 0");
                          }
                      }
                    }),
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 0.7,
          color: Colors.black12,
        )
      ],
    );
  }
}
