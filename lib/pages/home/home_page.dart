import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constance/Constance.dart';
import '../../main.dart';
import '../login/login_page.dart';
import '../login/logout.dart';

import '../micro_finance/home/micro_finance_home_page.dart';
import '../profile/change_password.dart';
import '../settings/CheckPrint.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final storage = new FlutterSecureStorage();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    getUserLoginStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getUserLoginStatus();
    }
  }

  getUserLoginStatus() {
    storage.read(key: "userId").then((value) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(value)
          .get()
          .then((value) {
        if (value.exists) {
          if (value.get("loginStatus") == 0) {
            goToLogin();
          }
        } else {
          goToLogin();
        }

        checkVersion();
      });
    });
  }

  Future<void> saveSessionData() async {
    await storage.deleteAll();
  }

  Future<String?> getUsername() {
    return storage.read(key: "username");
  }

  void goToLogin() {
    saveSessionData().then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  void checkVersion() {
    storage.read(key: "userId").then((userId) {
      FirebaseFirestore.instance.collection("users").doc(userId).get().then((userData) {
        if (userData.get("versionCode") != Constance.version_code) showNewVersionDialog();
      });
    });
  }

  void showNewVersionDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Old Version"),
          content: new Text(
              "You are using an old version of app. Please install new version."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Download"),
              onPressed: () async {
                final Uri _url = Uri.parse(Constance.drive_url);
                if (!await launchUrl(_url,
                    mode: LaunchMode.externalApplication)) {
                  debugPrint('Could not launch $_url');
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      goToLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    var welcomeText = FutureBuilder(
      builder: (context, snapshot) {
        // Checking if future is resolved or not
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Text("Welcome User",
                style: TextStyle(
                    fontSize: 24.0,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white));

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            final data = snapshot.data as String;
            return Text("Welcome $data,",
                style: TextStyle(
                    fontSize: 24.0,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white));
          }
        }
        // Displaying LoadingSpinner to indicate waiting state
        return Center(
          child: CircularProgressIndicator(),
        );
      },
      future: getUsername(),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text("Dashboard"),
        actions: [
          Logout()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100.0,
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
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MicroFinanceHome()));
                },
                child: DepartmentCard(
                  name: "Micro Finance",
                  imageUrl:
                      "https://digitalmarketingdeal.com/blog/wp-content/uploads/2021/04/Micro-finance-companies-in-Sri-Lanka-1.jpg",
                )),
            // const SizedBox(
            //   height: 10,
            // ),
            // GestureDetector(
            //     onTap: () {
            //       Navigator.push(
            //           context, MaterialPageRoute(builder: (context) => SavingsHome()));
            //     },
            //     child: DepartmentCard(
            //       name: "Savings",
            //       imageUrl:
            //           "https://www.idfcfirstbank.com/content/dam/idfcfirstbank/images/blog/importance-of-having-savings-717x404.jpg",
            //     )),
            const SizedBox(
              height: 40,
            ),
            Divider(color: Colors.black12),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: const Text(
                "You may check these settings",
                style: TextStyle(fontSize: 16.0, color: Colors.black38),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OtherSettingButton(
                  icon: Icons.print,
                  title: "Check Printer",
                  to: CheckPrint(),
                ),
                SizedBox(
                  width: 20.0,
                ),
                OtherSettingButton(
                  icon: Icons.settings,
                  title: "Change Password",
                  to: ChangePassword(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DepartmentCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const DepartmentCard({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      child: Card(
        elevation: 10,
        child: Container(
          height: 100,
          child: Row(
            children: [
              Image(
                image: NetworkImage(imageUrl),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OtherSettingButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget to;

  const OtherSettingButton(
      {super.key, required this.icon, required this.title, required this.to});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // background
            foregroundColor: Colors.black, // foreground
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => to));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40.0,
                color: Colors.white,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
