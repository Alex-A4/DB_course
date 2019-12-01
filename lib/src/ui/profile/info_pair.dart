import 'package:db_course_mobile/src/ui/auth/login_widget.dart';
import 'package:flutter/material.dart';

class InfoPair extends StatelessWidget {
  final TextSpan title;
  final TextSpan content;

  InfoPair({Key key, @required this.title, @required this.content})
      : super(key: key);

  factory InfoPair.text({Key key, String title, String content}) {
    return InfoPair(
      key: key,
      title: TextSpan(text: title, style: headerStyle),
      content: TextSpan(text: content, style: contentStyle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Text.rich(title)),
          Expanded(child: Text.rich(content, textAlign: TextAlign.end,)),
        ],
      ),
    );
  }
}

final titleStyle =
    TextStyle(fontSize: 22, color: Colors.black, fontStyle: FontStyle.italic);

final contentStyle = TextStyle(fontSize: 18, color: Colors.grey[500]);
