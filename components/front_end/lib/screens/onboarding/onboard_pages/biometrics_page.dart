import 'package:flutter/material.dart';
import 'package:middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'onboard_details.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:helpers/helpers.dart';

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
          countrySelector(context),
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
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: GestureDetector(
              child: Text(
                !hasDob ? 'Please select' : DateFormatter.dateToLongFormat(dob),//'${dob.day}/${dob.month}/${dob.year}',
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
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime(1900, 1),
      maxDateTime: new DateTime.now(),
      initialDateTime: hasDob ? dob : DateTime(1995),
      pickerMode: DateTimePickerMode.date,
      locale: DateTimePickerLocale.en_us,
      onChange: (date, i) => _updateDate(date),
      onConfirm: (date, i) => _updateDate(date),
    );
  }

  _updateDate(DateTime newDateTime) {
    print('selected date: $newDateTime');
    onboardUser.dateOfBirth = newDateTime;
    onSave(onboardUser);
  }

  Widget genderSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              'Gender',
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Icon(
            isMale? FontAwesomeIcons.male : FontAwesomeIcons.female,
            color: Colors.blue,
          ),
          Text(
            isMale ? 'Male' : 'Female',
            style: TextStyle(
              inherit: true,
              color: Colors.blue
            )
          ),
          IconButton(
            icon: Icon(Icons.compare_arrows),
            onPressed: () => _switchGender(),
          ),
          // RaisedButton(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(5.0), 
          //       bottomLeft: Radius.circular(5.0), 
          //       topRight: Radius.circular(0.0), 
          //       bottomRight: Radius.circular(0.0), 
          //     ),
          //   ),
          //   color: Theme.of(context).disabledColor,
          //   disabledColor: Theme.of(context).accentColor,
          //   child: Icon(
          //     FontAwesomeIcons.male,
          //     color: Colors.white,
          //   ),
          //   onPressed: hasGenderSelected && isMale ? null : () => _switchGender(newGenderIsMale: true)
          // ),
          // RaisedButton(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(0.0), 
          //       bottomLeft: Radius.circular(0.0), 
          //       topRight: Radius.circular(5.0), 
          //       bottomRight: Radius.circular(5.0), 
          //     ),
          //   ),
          //   color: Theme.of(context).disabledColor,
          //   disabledColor: Theme.of(context).accentColor,
          //   child: Icon(
          //     FontAwesomeIcons.female,
          //     color: Colors.white,
          //   ),
          //   onPressed:  hasGenderSelected && !isMale ? null : () => _switchGender(newGenderIsMale: false)
          // ),
        ],
      ),
    );
  }

  bool get hasGenderSelected => onboardUser.genderIsMale != null;

  bool get isMale => onboardUser.genderIsMale;
  
  void _switchGender({bool newGenderIsMale}){
    onboardUser.genderIsMale=!onboardUser.genderIsMale;
    onSave(onboardUser);
  }

  Widget countrySelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              'Country',
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          GestureDetector(
            onTap: () => print('override'),
            child: CountryCodePicker(
              onChanged: (cc) {
                onboardUser.countryCode=cc.code;
                onSave(onboardUser);
              },
              showOnlyCountryWhenClosed: true,
              showCountryOnly: true,
              alignLeft: false,
              initialSelection: onboardUser.countryCode,
              textStyle: TextStyle(
                inherit: true,
                color: Colors.blue
              ),
            ),
          ),
        ],
      ),
    );
  }


}