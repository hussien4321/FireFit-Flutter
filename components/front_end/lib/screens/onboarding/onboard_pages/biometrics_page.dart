import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'onboard_details.dart';

class BiometricsPage extends StatelessWidget {
  
  final OnboardUser onboardUser;
  final ValueChanged<OnboardUser> onSave;

  BiometricsPage({
    this.onboardUser,
    this.onSave
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OnboardDetails(
        icon: FontAwesomeIcons.birthdayCake,
        title: "When is your birthday?",
        children: <Widget>[
          dateOfBirthSelector(context),
          genderSelector(context),
        ],
      ),
    );
  }

  Widget dateOfBirthSelector(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Date of birth',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: GestureDetector(
              child: Text(
                !hasDob ? 'Please select' : '${dob.day}/${dob.month}/${dob.year}',
                style: Theme.of(context).textTheme.subhead.apply(color: !hasDob ? Theme.of(context).disabledColor : Theme.of(context).accentColor),
                textAlign: TextAlign.end,
              ),
              onTap: () {
                _selectDate(context);
              },
            ),
          ),
        ],
      )
    );
  }

  DateTime get dob => onboardUser.dateOfBirth;
  
  bool get hasDob => dob != null;


  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDatePickerMode: DatePickerMode.year,
        initialDate: hasDob ? dob : DateTime(1995),
        firstDate: DateTime(1900, 1),
        lastDate: new DateTime.now());
    if (picked != null){
      onboardUser.dateOfBirth = picked;
      onSave(onboardUser);
    }
  }

  Widget genderSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              'Gender:',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.0), 
                bottomLeft: Radius.circular(5.0), 
                topRight: Radius.circular(0.0), 
                bottomRight: Radius.circular(0.0), 
              ),
            ),
            color: Theme.of(context).disabledColor,
            disabledColor: Theme.of(context).accentColor,
            child: Icon(
              FontAwesomeIcons.male,
              color: Colors.white,
            ),
            onPressed: hasGenderSelected && isMale ? null : () => _switchGender(newGenderIsMale: true)
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0.0), 
                bottomLeft: Radius.circular(0.0), 
                topRight: Radius.circular(5.0), 
                bottomRight: Radius.circular(5.0), 
              ),
            ),
            color: Theme.of(context).disabledColor,
            disabledColor: Theme.of(context).accentColor,
            child: Icon(
              FontAwesomeIcons.female,
              color: Colors.white,
            ),
            onPressed:  hasGenderSelected && !isMale ? null : () => _switchGender(newGenderIsMale: false)
          ),
        ],
      ),
    );
  }

  bool get hasGenderSelected => onboardUser.genderIsMale != null;

  bool get isMale => onboardUser.genderIsMale;
  
  void _switchGender({bool newGenderIsMale}){
    onboardUser.genderIsMale =newGenderIsMale;
    onSave(onboardUser);
  }


}