import 'package:flutter/material.dart';

class PersonalDetailsSketch extends StatelessWidget {
  String title;
  String content;

  PersonalDetailsSketch(
      this.title,
      this.content
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 130,
          child: Text(
            title,
            style: TextStyle(color: Colors.black38),
          ),
        ),
        Expanded(
          child: Container(
            child: Text(
              content,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        )
      ],
    );
  }
}
