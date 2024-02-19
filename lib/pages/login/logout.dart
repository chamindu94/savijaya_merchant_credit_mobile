import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_page.dart';

class Logout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            saveSessionData().then((value) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            });
          },
        ),
      ),
    );
  }

  Future<void> saveSessionData() async {
    final storage = new FlutterSecureStorage();

    await storage.deleteAll();
  }
}
