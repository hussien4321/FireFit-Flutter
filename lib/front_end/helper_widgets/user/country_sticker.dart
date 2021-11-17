import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_codes.dart';
import 'package:meta/meta.dart';

class CountrySticker extends StatelessWidget {

  final String countryCode;
  final Color color;

  CountrySticker({
    @required this.countryCode,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    List<Map> jsonList = codes;
    List<CountryCode> elements = jsonList
        .map((s) => CountryCode(
              name: s['name'],
              code: s['code'],
              dialCode: s['dial_code'],
              flagUri: 'flags/${s['code'].toLowerCase()}.png',
            ))
        .toList();
    final selectedItem = elements.firstWhere((e) => (e.code.toUpperCase() == countryCode.toUpperCase()), orElse: () => elements[0]);

    return Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              selectedItem.flagUri,
              package: 'country_code_picker',
              width: 32.0,
            ),
          ),
          Text(
            selectedItem.code,
            style: Theme.of(context).textTheme.button.apply(
              color: color == null ? Colors.black : color,
            ),
          ),
        ],
      ),
    );
  }
}