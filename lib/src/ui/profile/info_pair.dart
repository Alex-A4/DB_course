import 'package:flutter/material.dart';

class InfoPair extends StatelessWidget {
  final String title;
  final String content;

  InfoPair({Key key, @required this.title, @required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: titleStyle),
          Text(content, style: contentStyle),
        ],
      ),
    );
  }
}

final titleStyle =
    TextStyle(fontSize: 22, color: Colors.black, fontStyle: FontStyle.italic);

final contentStyle = TextStyle(fontSize: 20, color: Colors.grey[500]);
