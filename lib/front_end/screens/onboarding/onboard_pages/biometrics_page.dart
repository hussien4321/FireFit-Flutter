import 'package:flutter/material.dart';
import '../../../../../middleware/middleware.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'onboard_details.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import '../../../../../front_end/helper_widgets.dart';
import '../../../../../helpers/helpers.dart';

class BiometricsPage extends StatelessWidget {
  final OnboardUser onboardUser;
  final ValueChanged<OnboardUser> onSave;

  BiometricsPage({this.onboardUser, this.onSave});

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
        child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Date of birth',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: GestureDetector(
                child: Text(
                  !hasDob
                      ? 'Please select'
                      : DateFormatter.dateToLongFormat(
                          dob), //'${dob.day}/${dob.month}/${dob.year}',
                  style: Theme.of(context).textTheme.subtitle1.apply(
                      color: !hasDob
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).accentColor),
                  textAlign: TextAlign.end,
                ),
                onTap: () {
                  _selectDate(context);
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    'I hereby confirm that I am\n over 13 years of age',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.grey),
                  ),
                ),
                Checkbox(
                  value: onboardUser.hasConfirmedAge,
                  onChanged: (newVal) {
                    onboardUser.hasConfirmedAge = newVal;
                    onSave(onboardUser);
                  },
                  activeColor: Colors.blue,
                )
              ]),
        ),
      ],
    ));
  }

  DateTime get dob => onboardUser.dateOfBirth;

  bool get hasDob => dob != null;

  Future<Null> _selectDate(BuildContext context) async {
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime(1900, 1),
      maxDateTime:
          new DateTime.now().subtract(Duration(days: (365.25 * 13).ceil())),
      initialDateTime: hasDob ? dob : DateTime(1995),
      pickerMode: DateTimePickerMode.date,
      locale: DateTimePickerLocale.en_us,
      onChange: (date, i) => _updateDate(date),
      onConfirm: (date, i) => _updateDate(date),
    );
  }

  _updateDate(DateTime newDateTime) {
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
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          InkWell(
            onTap: () => _switchGender(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    isMale ? FontAwesomeIcons.male : FontAwesomeIcons.female,
                    color: Colors.blue,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Text(isMale ? 'Male' : 'Female',
                        style: TextStyle(inherit: true, color: Colors.blue)),
                  ),
                  Icon(Icons.compare_arrows),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get hasGenderSelected => onboardUser.genderIsMale != null;

  bool get isMale => onboardUser.genderIsMale;

  void _switchGender({bool newGenderIsMale}) {
    onboardUser.genderIsMale = !onboardUser.genderIsMale;
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
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          CountryCodePicker(
            onChanged: (cc) {
              onboardUser.countryCode = cc.code;
              onSave(onboardUser);
            },
            showOnlyCountryWhenClosed: true,
            showCountryOnly: true,
            alignLeft: false,
            favorite: [
              "US",
              "CA",
              "GB",
            ],
            initialSelection: onboardUser.countryCode,
            textStyle: TextStyle(inherit: true, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
