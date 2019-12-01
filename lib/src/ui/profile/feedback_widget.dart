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
  bool update = false;

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

    if (widget.addFeedback && feedback == null || update) {
      if (update) {
        controller.text = feedback.text;
      }
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
                        if (update) {
                          bloc.database
                              .updateFeedback(user.token, user.id,
                                  widget.entry.id, controller.text)
                              .then((f) {
                            feedback = f;
                            widget.entry.feedback = f;
                            update = false;
                            setState(() {});
                          });
                        } else
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
          Row(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Отзыв', style: headerStyle),
                          Text(feedback.text),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: getDate(feedback.feedbackTime)),
                ),
                flex: 2,
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(60),
                  child: Icon(Icons.update),
                  onTap: () => setState(() => update = true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
