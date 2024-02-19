import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loanprocessingapp/pages/login/login_page.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  var passwordController = new TextEditingController();
  var cpasswordController = new TextEditingController();

  late ProgressDialog pr;

  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {

    pr = ProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _form,
            child: Column(
              children: [
                SizedBox(height: 20,),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: "New Password",
                      hintText: "New Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: cpasswordController,
                  decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Confirm password cannot be empty';
                    } else if (value != passwordController.text) {
                      return 'Passwords not matched';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_form.currentState!.validate()) {
                          pr.show();
                          createRecord();
                        }
                      },
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createRecord() {
    // FlutterSession().get("userId").then((value) {
    storage.read( key: "userId" ).then((value) {
      FirebaseFirestore
          .instance
          .collection("users")
          .doc(value)
          .update({
        'password': passwordController.text
      }).then((value) {

        pr.hide();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Successfully"),
              content: new Text("User updated successfully"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new TextButton(
                  child: new Text("Log Out"),
                  onPressed: () {
                    saveSessionData().then((value) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    });
                  },
                ),
              ],
            );
          },
        );
      });
    });
  }

  Future<void> saveSessionData() async {
    await storage.deleteAll();
  }
}
