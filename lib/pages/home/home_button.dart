import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  Widget _to;
  Color _color;
  String _title;
  IconData _icon;

  HomeButton(
      this._to,
      this._color,
      this._title,
      this._icon
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _color, // background
            foregroundColor: Colors.white, // foreground
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        _to));
          },
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _icon,
                size: 40.0,
                color: Colors.white,
              ),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
