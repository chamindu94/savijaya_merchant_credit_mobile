import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

import '../models/Income.dart';
import '../models/Member.dart';
import '../models/PaymentStatus.dart';

double calculateArrears({required Member member}) {
  double arrears_amount = 0;

  var installment =
      (int.parse(member.loan_amount) + int.parse(member.interest)) /
          int.parse(member.loanTerm);

  var actualPaymentWeeks = (member.schedule == "Weekly")
      ? DateTime.now().difference(DateTime.parse(member.loan_date)).inDays ~/ 7
      : DateTime.now().difference(DateTime.parse(member.loan_date)).inDays;

  var actualPaymentAmount = actualPaymentWeeks * installment;

  var memberPaidAmount = int.parse(member.loan_amount) +
      int.parse(member.interest) -
      int.parse(member.toPaid);

  if (memberPaidAmount < actualPaymentAmount) {
    arrears_amount = actualPaymentAmount - memberPaidAmount;
  }

  return arrears_amount;
}

Future<PaymentStatus> calculatePaymentStatus(
    {required Member member, required List<Income> installments}) async {
  //Monday to Sunday
  var today = await NTP.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  int currentWeekDay = today.weekday;

  var _firstDayOfTheweek =
      today.subtract(new Duration(days: currentWeekDay - 1));
  var _lastDayOfTheweek = _firstDayOfTheweek.add(new Duration(days: 6));

  var _firstDayOfTheWeekTimestamp =
      DateTime.parse(formatter.format(_firstDayOfTheweek))
          .millisecondsSinceEpoch;
  var _lastDayOfTheWeekTimestamp =
      DateTime.parse(formatter.format(_lastDayOfTheweek.add(Duration(days: 1))))
          .subtract(Duration(milliseconds: 1))
          .millisecondsSinceEpoch;
  var _dateToCheckTimestamp = installments[installments.length - 1]
      .date
      .toDate()
      .millisecondsSinceEpoch;

  String statusText = "";
  Color color = Colors.green;

  if (member.schedule == "Weekly") {
    if (_firstDayOfTheWeekTimestamp <= _dateToCheckTimestamp &&
        _lastDayOfTheWeekTimestamp >= _dateToCheckTimestamp) {
      statusText = "Done";
      color = Colors.green;
    } else {
      statusText = "Pending";
      color = Colors.red;
    }
  } else {
    DateTime checkDate = installments[installments.length - 1].date.toDate();
    DateTime now = DateTime.now();

    if (checkDate.day == now.day &&
        checkDate.month == now.month &&
        checkDate.year == now.year) {
      statusText = "Done";
      color = Colors.green;
    } else {
      statusText = "Pending";
      color = Colors.red;
    }
  }

  return PaymentStatus(statusText: statusText, color: color);
}
