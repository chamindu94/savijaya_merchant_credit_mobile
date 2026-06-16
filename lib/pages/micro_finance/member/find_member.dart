import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../constance/customSnackbar.dart';
import '../../../constance/loadingIndicator.dart';
import '../../../main.dart';
import '../../../services/members_service.dart';
import '../../login/logout.dart';
import 'member_details.dart';

class FindMember extends StatefulWidget {
  FindMember({super.key});

  @override
  State<FindMember> createState() => _FindMemberState();
}

class _FindMemberState extends State<FindMember> {
  final _ddaCodeController = TextEditingController();

  final storage = new FlutterSecureStorage();

  int? membersAmount;

  checkMember() async {
    showLoadingDialog(context);
    await FirebaseFirestore.instance
        .collection("members")
        .where("dd_code", isEqualTo: _ddaCodeController.text.toString().trim())
        .get()
        .then((snapshot) {
      Navigator.of(context).pop();

      if (snapshot.size > 0) {
        var memberDocument = snapshot.docs[0];

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MemberDetails(memberDocument.id)));
      } else {
        showMsg('No member found with this DDA Code.');
      }
    });
  }

  showMsg(errorText) {
    ScaffoldMessenger.of(context)
        .showSnackBar(customSnackBar(Colors.red, 'Error Occurred!', errorText));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    storage.read(key: "branch").then((branch) {
      MembersServices.readActiveMemberOfBranch(branch: branch!).then((
          membersList) {
        int total = 0;
        membersList.forEach((element) {
          if (int.parse(element.toPaid) > 0) total++;
        });

        setState(() {
          membersAmount = total;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersAmountTxt = Column(
      children: [
        Text(
          "Active Members Count",
          style: TextStyle(fontSize: 16),
        ),
        (membersAmount == null)
            ? CircularProgressIndicator()
            : Text(
          membersAmount.toString(),
          style: TextStyle(
              fontSize: 25,
              color: Colors.green,
              fontWeight: FontWeight.bold),
        )
      ],
    );

    final ddaCodeField = Container(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        margin: EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextFormField(
          autofocus: false,
          controller: _ddaCodeController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: "Enter Member Number",
              border: InputBorder.none),
        ));

    final btnSearch = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(15),
        color: MyApp.primaryColor,
        child: MaterialButton(
          onPressed: () {
            if (_ddaCodeController.text.isNotEmpty) {
              checkMember();
            }
          },
          child: const Text(
            "Search",
            style: TextStyle(color: Colors.white),
          ),
        ));

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text("Find Member"),
        actions: [Logout()],
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              membersAmountTxt,
              const SizedBox(
                height: 50.0,
              ),
              ddaCodeField,
              const SizedBox(
                height: 20.0,
              ),
              btnSearch
            ],
          ),
        ),
      ),
    );
  }
}
