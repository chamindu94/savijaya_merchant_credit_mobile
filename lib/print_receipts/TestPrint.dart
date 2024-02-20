import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import '../constance/Constance.dart';
import '../models/Member.dart';
import '../models/SavingMember.dart';
import 'printerenum.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

///Test printing
class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample() async {
    // ByteData bytesAsset = await rootBundle.load("assets/print_logo.png");
    // Uint8List imageBytesFromAsset = bytesAsset.buffer
    //     .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        // bluetooth.printImageBytes(imageBytesFromAsset);
        bluetooth.printNewLine();
        bluetooth.printCustom(Constance.COMPANY_NAME, Size.boldLarge.val, Align.center.val);
        bluetooth.printCustom(Constance.COMPANY_PHONE, Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("Printer Connected Successfully", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("___________________", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }

  receipt(String branch, String date_time, String payment, String toBePaid, Member member, String clusterName) async {

    var total_paid = int.parse(member.loan_amount) + int.parse(member.interest) - int.parse(toBePaid);

    // ByteData bytesAsset = await rootBundle.load("assets/print_logo.png");
    // Uint8List imageBytesFromAsset = bytesAsset.buffer
    //     .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        // bluetooth.printImageBytes(imageBytesFromAsset);
        bluetooth.printNewLine();
        bluetooth.printCustom(Constance.COMPANY_NAME, Size.boldLarge.val, Align.center.val);
        bluetooth.printCustom(Constance.REG_NO, Size.medium.val, Align.center.val);
        bluetooth.printCustom(Constance.COMPANY_PHONE, Size.medium.val, Align.center.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printLeftRight("Date Time", date_time, Size.medium.val);
        bluetooth.printLeftRight("DDA Code", member.dd_code, Size.medium.val);
        bluetooth.printLeftRight("Center", clusterName, Size.medium.val);
        bluetooth.printLeftRight("Name", generateNameWithIni(member.name), Size.medium.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printCustom("PAYMENT SUMMERY", Size.boldMedium.val, Align.center.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printLeftRight("Loan Amount", member.loan_amount+"/=", Size.medium.val);
        bluetooth.printLeftRight("Loan Balance", toBePaid+"/=", Size.medium.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printLeftRight("Payment", payment+"/=", Size.boldLarge   .val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printCustom("Thank you!", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("___________________", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }

  memberSummery(String branch, material.AsyncSnapshot<QuerySnapshot> snapshot, String timestamp) async {
    ///image from Asset
    // ByteData bytesAsset = await rootBundle.load("assets/rsz_logo.jpg");
    // Uint8List imageBytesFromAsset = bytesAsset.buffer
    //     .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        // bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
        bluetooth.printNewLine();
        bluetooth.printCustom(Constance.COMPANY_NAME, Size.boldLarge.val, Align.center.val);
        bluetooth.printCustom(Constance.REG_NO, Size.medium.val, Align.center.val);
        bluetooth.printCustom(Constance.COMPANY_PHONE, Size.medium.val, Align.center.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.print3Column("Ins#", "Amount", "Date", Size.bold.val, format:
        "%-10s %5s %10s %n");

        if (snapshot.hasData) {
          snapshot.data!.docs.asMap().forEach((index, value) {
            bluetooth.print3Column((index+1).toString(), value.get("amount") + "/=", DateFormat('yyyy-MM-dd kk:mm')
                .format(value.get("date").toDate()), Size.medium.val, format:
            "%-5s %10s %17s %n");
          });
        }

        bluetooth.printNewLine();
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();

        bluetooth.printCustom(timestamp, Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("___________________", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }

  // documentCharges(String branch, String date_time, String dd_code, String cluster, String name, String document_charge) async {
  //   bluetooth.isConnected.then((isConnected) {
  //     if (isConnected == true) {
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom(Constance.COMPANY_NAME, Size.boldLarge.val, Align.center.val);
  //       bluetooth.printCustom("$branch Branch", Size.medium.val, Align.center.val);
  //       bluetooth.printCustom(Constance.COMPANY_PHONE, Size.medium.val, Align.center.val);
  //       bluetooth.printCustom(Constance.COMPANY_MOBILE, Size.medium.val, Align.center.val);
  //       bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
  //       bluetooth.printLeftRight("Date Time", date_time, Size.medium.val);
  //       bluetooth.printLeftRight("DDA Code", dd_code, Size.medium.val);
  //       bluetooth.printLeftRight("Center", cluster, Size.medium.val);
  //       bluetooth.printLeftRight("Name", generateNameWithIni(name), Size.medium.val);
  //       bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
  //       bluetooth.printLeftRight("Doc. Charge", document_charge+"/=", Size.boldLarge   .val);
  //       bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
  //       bluetooth.printCustom("Thank you!", Size.medium.val, Align.center.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom("___________________", Size.medium.val, Align.center.val);
  //       bluetooth.printNewLine();
  //       bluetooth.printNewLine();
  //       bluetooth
  //           .paperCut(); //some printer not supported (sometime making image not centered)
  //       //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
  //     }
  //   });
  // }

  String generateNameWithIni(memberName) {
    var arr = memberName.split(" ");
    if (arr.length > 0) {
      var last_part = arr[arr.length - 1];
      var initials = "";
      for (var i = 0; i < arr.length - 1; i++) {
        initials += arr[i][0] + " ";
      }

      return (initials + last_part);
    } else {
      return "";
    }
  }

  savingsSlip(String date_time, SavingMember member, String status, String amount, String balance) {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        // bluetooth.printImageBytes(imageBytesFromAsset);
        // bluetooth.printNewLine();
        bluetooth.printCustom(Constance.COMPANY_NAME, Size.boldLarge.val, Align.center.val);
        // bluetooth.printCustom("$branch Branch", Size.medium.val, Align.center.val);
        bluetooth.printCustom(Constance.COMPANY_PHONE, Size.medium.val, Align.center.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printLeftRight("Date Time", date_time, Size.medium.val);
        bluetooth.printLeftRight("Member No.", member.memberNumber, Size.medium.val);
        bluetooth.printLeftRight("Name", generateNameWithIni(member.memberName), Size.medium.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printCustom(status.toUpperCase(), Size.boldMedium.val, Align.center.val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printLeftRight("Amount", amount+"/=", Size.boldLarge   .val);
        bluetooth.printLeftRight("Balance", balance+"/=", Size.boldLarge   .val);
        bluetooth.printCustom("----------------------------", Size.medium.val, Align.center.val);
        bluetooth.printCustom("Thank you!", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("___________________", Size.medium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }

}