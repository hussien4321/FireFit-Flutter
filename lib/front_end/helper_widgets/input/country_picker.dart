import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../../helpers/helpers.dart';
import 'package:country_code_picker/selection_dialog.dart';
import 'package:meta/meta.dart';

class CountryPicker {

  final ValueChanged<String> onSelected;

  CountryPicker({
    @required this.onSelected
  });

  static List<String> countriesWithTheInFrontOfName() => [
    "US", "GB",
  ];
  static CountryCode getCountry(String countryCode){
    List<Map> jsonList = codes;
    List<CountryCode> elements = jsonList
        .map((s) => CountryCode(
              name: s['name'],
              code: s['code'],
              dialCode: s['dial_code'],
              flagUri: 'flags/${s['code'].toLowerCase()}.png',
            ))
        .toList();
    return elements.firstWhere((country)=>country.code==countryCode);
  }

  static launch(BuildContext context,) {
    List<Map> jsonList = codes;
    List<CountryCode> elements = jsonList
        .map((s) => CountryCode(
              name: s['name'],
              code: s['code'],
              dialCode: s['dial_code'],
              flagUri: 'flags/${s['code'].toLowerCase()}.png',
            ))
        .toList();
    // List<String> targetCountryCodes = ["US", "CA", "GB",];
    return showDialog(
      context: context,
      builder: (_) => SelectionDialog(
        elements,
        [],
        showCountryOnly: true,
        showFlag: true,
        searchStyle: TextStyle(
          inherit: true,
          color: Colors.blue
        )
      ),
    ).then((e){
      if(e is CountryCode){
        return e.code;
      }
      return null;
    });
  }
}