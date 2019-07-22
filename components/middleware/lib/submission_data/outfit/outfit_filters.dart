enum DateRanges {
  PAST_DAY,
  PAST_WEEK,
  PAST_MONTH,
  PAST_YEAR,
  // CUSTOM,
}

String dateRangeToString(DateRanges dateRange) {
  switch (dateRange) {
    case DateRanges.PAST_DAY:
      return 'Past day';
    case DateRanges.PAST_WEEK:
      return 'Past week';
    case DateRanges.PAST_MONTH:
      return 'Past month';
    case DateRanges.PAST_YEAR:
      return 'Past year';
    // case DateRanges.CUSTOM:
    //   return 'Custom';
    default:
      return null;
  }
}

DateRanges dateRangeFromString(String stringVal) {
  switch (stringVal) {
    case 'Past day':
      return DateRanges.PAST_DAY;
    case 'Past week':
      return DateRanges.PAST_WEEK;
    case 'Past month':
      return DateRanges.PAST_MONTH;
    case 'Past year':
      return DateRanges.PAST_YEAR;
    // case 'Custom':
    //   return DateRanges.CUSTOM;
    default:
      return null;
  }
}

class OutfitFilters {
  DateTime startDate;
  DateTime endDate;
  DateRanges dateRange;
  bool genderIsMale;
  String style;
  String countryCode;

  OutfitFilters({
    this.startDate,
    this.endDate,
    this.genderIsMale,
    this.style,
    this.countryCode,
  });

  bool get isEmpty => startDate==null && endDate == null && dateRange ==null && genderIsMale == null && style == null && countryCode == null;

  bool operator ==(o) {
    return o is OutfitFilters &&
    o.startDate == startDate &&
    o.endDate == endDate &&
    o.genderIsMale == genderIsMale &&
    o.dateRange == dateRange &&
    o.style == style &&
    o.countryCode == countryCode;
  }
 
  OutfitFilters.fromMap(Map<String, dynamic> map) :
    startDate = map['start_date'] == null ? null : DateTime.parse(map['start_date']),
    endDate = map['end_date'] == null ? null : DateTime.parse(map['end_date']),
    style = map['style'],
    dateRange = dateRangeFromString(map['date_range']),
    genderIsMale = map['gender_is_male'],
    countryCode = map['country_code'];

  Map<String, dynamic> toJson() {
    if([DateRanges.PAST_DAY, DateRanges.PAST_WEEK, DateRanges.PAST_MONTH, DateRanges.PAST_YEAR].contains(dateRange)){
      endDate =DateTime.now();
      DateTime placeHolder =DateTime.now();
      switch (dateRange) {
        case DateRanges.PAST_DAY:
          startDate = placeHolder.subtract(Duration(days: 1));
          break;
        case DateRanges.PAST_WEEK:
          startDate = placeHolder.subtract(Duration(days: 7));
          break;
        case DateRanges.PAST_MONTH:
          startDate = placeHolder.subtract(Duration(days: 31));
          break;
        case DateRanges.PAST_YEAR:
          startDate = placeHolder.subtract(Duration(days: 365));
          break;
        default:
          break;
      }
    }
    return {
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'gender_is_male': genderIsMale,
      'date_range': dateRangeToString(dateRange),
      'style': style,
      'country_code':countryCode,
    };
  }

  
}