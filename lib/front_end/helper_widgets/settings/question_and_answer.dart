import 'package:flutter/material.dart';
import '../../../../front_end/helper_widgets.dart';

class QuestionAndAnswer extends StatefulWidget {

  final String question, answer;

  QuestionAndAnswer({this.question, this.answer});

  @override
  _QuestionAndAnswerState createState() => _QuestionAndAnswerState();
}

class _QuestionAndAnswerState extends State<QuestionAndAnswer> {

  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SettingsOption(
          name: '${widget.question}?',
          action: Icon(
            isOpen ? Icons.expand_less : Icons.expand_more,
            color: isOpen ? Colors.grey : Colors.blue,
          ),
          onTap: () => setState(() => isOpen = !isOpen),
        ),
        isOpen ? _answer() : Container(),
      ],
    );
  }
  Widget _answer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      color: Colors.grey[100],
      child: Text(
        widget.answer,
        style: Theme.of(context).textTheme.headline5.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.blue
        ),
      ),
    );
  }
}