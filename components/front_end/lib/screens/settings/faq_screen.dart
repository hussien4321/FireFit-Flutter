import 'package:flutter/material.dart';
import 'package:front_end/helper_widgets.dart';
import 'package:flutter/gestures.dart';

class FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'FAQ',
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            children: <Widget>[
              SettingsHeader('Outfits'),
              QuestionAndAnswer(
                question: "What is the difference between the 'Inspiration' and 'Fashion Circle' pages",
                answer: "The inspiration page contains the latest and newest outfits from ALL FireFit users, which you can filter as you wish.\n\nYour fashion circle however, is your personalized feed of outfits from ONLY the people you are following.",
              ),
              QuestionAndAnswer(
                question: 'What are lookbooks',
                answer: "Lookbooks are your custom fashion galleries for specific styles you want to create.\n\nDecide your criteria for a lookbook and only save matching outfits to it.\n\nThis helps users create multiple looks, showcasing different styles for each mood/occasion.",
              ),
              SettingsHeader('Users'),
              QuestionAndAnswer(
                question: "How can I DM users",
                answer: "As we are focused on helping people improve their fashion, we decided not include DMs at this moment.\n\nIf you would like to connect with users outside the app however, then feel free to leave your contact info in the Bio section of your profile.",
              ),
              SettingsHeader('FireFit+'),
              QuestionAndAnswer(
                question: 'How can I restore my purchases',
                answer: "You can do this by selecting the restore purchases icon in the top right corner of the FireFit+ page.",
              ),
              QuestionAndAnswer(
                question: 'How can I cancel my subscription',
                answer: "You can do this by going to your app store and finding your 'subscriptions' page, where you can cancel any active subscriptions you have, including FireFit+.",
              ),
              _feedbackPrompt(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackPrompt(BuildContext context){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 32),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.body2.copyWith(color: Colors.grey),
          children: [
            TextSpan(
              text: "Can't see your question here?\nThen feel free to ",
            ),
            TextSpan(
              text: "ask us directly",
              style: TextStyle(
                inherit: true,
                color: Colors.blue,
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () => CustomNavigator.goToFeedbackScreen(context),
            ),
          ]
        )
      ),
    );
  }
}