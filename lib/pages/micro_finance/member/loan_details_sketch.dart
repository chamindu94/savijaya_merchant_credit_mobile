import 'package:flutter/material.dart';

class LoanDetailsSketch extends StatelessWidget {
  String title;
  String content;

  LoanDetailsSketch(
      this.title,
      this.content
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(color: Colors.black38),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            content,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
