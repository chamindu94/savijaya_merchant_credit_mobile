import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../constance/Constance.dart';
import '../../constance/loadingIndicator.dart';
import '../../constance/toastMessages.dart';
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final databaseReference = FirebaseFirestore.instance;

  String _errorText = "", _versionCode = Constance.version_code;

  late ProgressDialog pr;

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                  child: Image.asset(
                "assets/logo.jpg",
                width: MediaQuery.of(context).size.width / 1.7,
              )),
              SizedBox(
                height: 30,
              ),
              Text(
                _errorText,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_circle),
                          labelText: "Username",
                          hintText: "Username",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          hintText: "Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    checkLogin();
                  },
                  child: Text(
                    "LOGIN",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Column(
                children: [
                  Text("v $_versionCode"),
                  Text(
                    "Powered By Code Room IT",
                    style: TextStyle(fontSize: 9),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void checkLogin() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      showLoadingDialog(context);

      databaseReference
          .collection("users")
          .where("username",
              isEqualTo: usernameController.text.toString().trim())
          .where("password",
              isEqualTo: passwordController.text.toString().trim())
          .get()
          .then((QuerySnapshot snapshot) {
        if (snapshot.size > 0) {
          var userDocument = snapshot.docs[0];

          saveSessionData(userDocument.id, userDocument.get("role"),
                  userDocument.get("branch"))
              .then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          });
        } else {
          Navigator.of(context).pop();
          showErrorMsg(context, 'Invalid username or password.');
        }
      });
    } else {
      showErrorMsg(context, 'Username & Password is required');
    }
  }

  Future<void> saveSessionData(String id, String role, String branch) async {
    final storage = new FlutterSecureStorage();

    await storage.write(key: "isLogin", value: "true");
    await storage.write(key: "username", value: usernameController.text);
    await storage.write(key: "userId", value: id);
    await storage.write(key: "role", value: role);
    await storage.write(key: "branch", value: branch);
  }
}
