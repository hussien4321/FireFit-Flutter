// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:helpers/src/localizations/messages_all.dart';
import 'package:intl/intl.dart';

class ArchSampleLocalizations {
  ArchSampleLocalizations(this.locale);

  final Locale locale;

  static Future<ArchSampleLocalizations> load(Locale locale) {
    return initializeMessages(locale.toString()).then((_) {
      return ArchSampleLocalizations(locale);
    });
  }

  static ArchSampleLocalizations of(BuildContext context) {
    return Localizations.of<ArchSampleLocalizations>(
        context, ArchSampleLocalizations);
  }

  String get appTitle => Intl.message(
        'Sharedrobe',
        name: 'appTitle',
        args: [],
        locale: locale.toString(),
      );


  String get discoverClothes => Intl.message(
        'Discover clothes',
        name: 'discoverClothes',
        args: [],
        locale: locale.toString(),
      );

  String get livePosts => Intl.message(
        'Live Posts',
        name: 'livePosts',
        args: [],
        locale: locale.toString(),
      );

  String get yourDeals => Intl.message(
        'Your deals',
        name: 'yourDeals',
        args: [],
        locale: locale.toString(),
      );

  String get yourProfile => Intl.message(
        'Your profile',
        name: 'yourProfile',
        args: [],
        locale: locale.toString(),
      );
}

class ArchSampleLocalizationsDelegate
    extends LocalizationsDelegate<ArchSampleLocalizations> {
  @override
  Future<ArchSampleLocalizations> load(Locale locale) =>
      ArchSampleLocalizations.load(locale);

  @override
  bool shouldReload(ArchSampleLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode.toLowerCase().contains("en");
}
