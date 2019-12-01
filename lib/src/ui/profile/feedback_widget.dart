import 'package:db_course_mobile/src/bloc/navigation_bloc/navigation.dart';
import 'package:db_course_mobile/src/models/entry.dart';
import 'package:db_course_mobile/src/models/feedback.dart' as f;
import 'package:db_course_mobile/src/ui/auth/login_widget.dart';
import 'package:db_course_mobile/src/ui/profile/entry_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedbackWidget extends StatefulWidget {
  final Entry entry;
  final f.Feedback feedback;
  final bool addFeedback;

  FeedbackWidget({
    Key key,
    this.feedback,
    this.addFeedback = false,
    @required this.entry,
  })  : assert(addFeedback && feedback == null ||
            !addFeedback && feedback != null),
        super(key: key);

  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  f.Feedback feedback;

  @override
  void initState() {
    feedback = widget.feedback;
    super.initState();
  }

  final controller = TextEditingController();

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NavigationBloc>(context);
    final user = bloc.user;

    if (widget.addFeedback && feedback == null) {
      return Form(
        key: _key,
        child: Column(
          children: <Widget>[
            Divider(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Добавить отзыв', style: headerStyle),
                  IconButton(
                    icon:
                        Icon(Icons.done_outline, size: 30, color: Colors.green),
                    onPressed: () {
                      if (_key.currentState.validate()) {
                        bloc.database
                            .addFeedback(user.token, user.id, widget.entry.id,
                                controller.text, DateTime.now())
                            .then((f) {
                          feedback = f;
                          widget.entry.feedback = f;
                          setState(() {});
                        });
                      }
                    },
                  ),
                ]),
            TextFormField(
              validator: (val) {
                if (val.isEmpty || val.length > 50)
                  return 'Длина от 1 до 50 символов';
                return null;
              },
              decoration: InputDecoration(labelText: 'Отзыв'),
              controller: controller,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(),
          Text('Отзыв', style: headerStyle),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(feedback.text),
              ),
              Expanded(
                child: Text.rich(
                    TextSpan(children: getDate(feedback.feedbackTime))),
                flex: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
