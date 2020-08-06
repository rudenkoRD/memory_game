import 'package:flutter/material.dart';

class CounterWidget extends StatelessWidget {
  final numberToShow;

  const CounterWidget({Key key, @required this.numberToShow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(2),
          child: Text(
              '${numberToShow
                  .toString()
                  .length == 4 ? numberToShow
                  .toString()[numberToShow
                  .toString()
                  .length - 4] : 0}'),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white),
              bottom: BorderSide(color: Colors.white),
              left: BorderSide(color: Colors.white),
              right: BorderSide(color: Colors.white),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(2),
          child: Text(
              '${numberToShow
                  .toString()
                  .length >= 3 ? numberToShow
                  .toString()[numberToShow
                  .toString()
                  .length - 3] : 0}'),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white),
              bottom: BorderSide(color: Colors.white),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(2),
          child: Text(
              '${numberToShow
                  .toString()
                  .length >= 2 ? numberToShow
                  .toString()[numberToShow
                  .toString()
                  .length - 2] : 0}'),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white),
              left: BorderSide(color: Colors.white),
              bottom: BorderSide(color: Colors.white),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(2),
          child: Text(
              '${numberToShow
                  .toString()
                  .length >= 1 ? numberToShow
                  .toString()[numberToShow
                  .toString()
                  .length - 1] : 0}'),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white),
              bottom: BorderSide(color: Colors.white),
              right: BorderSide(color: Colors.white),
              left: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
