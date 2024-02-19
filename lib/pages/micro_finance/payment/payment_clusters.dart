import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loanprocessingapp/models/Cluster.dart';

import '../../../services/cluster_service.dart';
import 'payment_groups.dart';

class PaymentClusters extends StatefulWidget {
  final String username;

  PaymentClusters({required this.username});

  @override
  _PaymentClustersState createState() => _PaymentClustersState();
}

class _PaymentClustersState extends State<PaymentClusters> {
  List<DocumentSnapshot> list = [];
  List<Cluster>? clustersList;
  List<Cluster>? filteredClustersList;

  String _searchKeyword = "";

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    storage.read(key: "branch").then((branch) {
      ClusterService.readClusterOfBranch(branch: branch!).then((value) {
        setState(() {
          clustersList = value;
          filteredClustersList = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Centers"),
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
                        filterClusters();
                      });
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
          ),
          (clustersList == null)
              ? Center(child: CircularProgressIndicator())
              : (clustersList!.length == 0)
                  ? Column(
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
                  )
                  : Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: filteredClustersList?.length,
                        itemBuilder: (buildContext, index) =>
                            MemberRow(filteredClustersList![index]),
                      ),
                  )
        ],
      ),
    );
  }

  filterClusters() {
    filteredClustersList = [];

    clustersList?.forEach((element) {
      if (_searchKeyword == "") {
        filteredClustersList = clustersList;
      } else {
        if (element.name
            .toLowerCase()
            .contains(_searchKeyword.toString().toLowerCase())) {
          filteredClustersList?.add(element);
        }
      }
    });
  }
}

class MemberRow extends StatefulWidget {
  final Cluster cluster;

  MemberRow(this.cluster);

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
                      builder: (context) => PaymentGroups(
                          widget.cluster.id, widget.cluster.name)));
            },
            child: Container(
              color: Colors.white,
              child: new ListTile(
                leading: new CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: new Icon(Icons.place),
                  foregroundColor: Colors.white,
                ),
                title: Text(widget.cluster.name),
                subtitle: StreamBuilder<QuerySnapshot>(
                    stream: databaseReference
                        .collection("clusters")
                        .doc(widget.cluster.id)
                        .collection("groups")
                        .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: Image.asset(
                              "assets/loader.gif",
                              height: 35.0,
                              width: 35.0,
                            ),
                          );
                        default:
                          if (snapshot.hasData) {
                            return Text("Groups : " +
                                snapshot.data!.docs.length.toString());
                          } else {
                            return Text("Groups : 0");
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
