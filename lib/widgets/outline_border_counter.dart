import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class OutlineBorderCounter extends StatelessWidget {
  final int numberToShow;
  final String label;

  const OutlineBorderCounter({Key key, @required this.numberToShow, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          label,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          width: MediaQuery.of(context).size.width / 4,
          padding: EdgeInsets.symmetric(
              horizontal: 8.0, vertical: 4.0),
          child: AutoSizeText(
            '$numberToShow',
            style: TextStyle(
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(),
          ),
        ),
      ],
    );
  }
}
