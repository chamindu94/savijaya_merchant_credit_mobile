import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loanprocessingapp/helpers/helpers.dart';
import 'package:loanprocessingapp/main.dart';
import 'package:loanprocessingapp/pages/micro_finance/collection/my_collections.dart';
import 'package:loanprocessingapp/services/income_service.dart';

import '../../home/home_button.dart';
import '../../login/logout.dart';
import '../member/find_member.dart';
import '../payment/payment_clusters.dart';

class MicroFinanceHome extends StatefulWidget {
  const MicroFinanceHome({super.key});

  @override
  State<MicroFinanceHome> createState() => _MicroFinanceHomeState();
}

class _MicroFinanceHomeState extends State<MicroFinanceHome> {
  final storage = new FlutterSecureStorage();
  String _userName = "";
  String _userId = "";

  @override
  void initState() {
    super.initState();

    storage.read(key: "username").then((value) {
      setState(() {
        _userName = value!;
      });
    });

    storage.read(key: "userId").then((value) {
      setState(() {
        _userId = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var welcomeText = Text("Hi $_userName,",
        style: TextStyle(
            fontSize: 24.0,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: Colors.white));

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text("Micro Finance"),
        actions: [Logout()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200.0,
                  decoration: const BoxDecoration(
                      color: MyApp.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      welcomeText,
                      const SizedBox(height: 10.0),
                      const Text("Explore your today collections",
                          style:
                              TextStyle(fontSize: 16.0, color: Colors.white)),
                      const SizedBox(height: 60.0),
                      TodayCollection(userId: _userId,),
                      const SizedBox(
                        height: 50.0,
                      ),
                      Center(
                        child: Column(
                          children: [
                            HomeButton(FindMember(), Colors.lightBlue, "Find Member",
                                Icons.supervised_user_circle),
                            const SizedBox(
                              height: 10,
                            ),
                            HomeButton(PaymentClusters(username: _userName,), Colors.orange,
                                "Add Payment", Icons.payment),
                            const SizedBox(
                              height: 10,
                            ),
                            HomeButton(MyCollections(userName: _userName, userId: _userId,), Colors.green, "Collection",
                                Icons.collections_bookmark),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TodayCollection extends StatefulWidget {
  final String userId;

  const TodayCollection({super.key, required this.userId});

  @override
  State<TodayCollection> createState() => _TodayCollectionState();
}

class _TodayCollectionState extends State<TodayCollection> {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime _today = new DateTime(now.year, now.month, now.day);

    return Container(
      height: 100.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Card(
          elevation: 20,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image(
                  image: NetworkImage(
                      "https://thumbs.dreamstime.com/b/money-bag-icon-badge-style-one-casino-collection-icon-can-be-used-ui-ux-white-background-money-bag-icon-badge-126563211.jpg"),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Today Collection Amount",
                      style: TextStyle(fontSize: 15.0, color: Colors.black38),
                    ),
                    StreamBuilder(
                      stream: IncomeService.readCollectionOfDate(date: _today, userId: widget.userId),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        double totalCollection = 0;

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasData) {
                          snapshot.data!.docs.forEach((element) {
                            print(element.data());
                            totalCollection += double.parse(element.get("amount"));
                          });
                        }

                        String formttedNumber = MyHelpers.formatNumber(totalCollection);
                        return Text(
                          "Rs $formttedNumber",
                          style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        );
                      }
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
