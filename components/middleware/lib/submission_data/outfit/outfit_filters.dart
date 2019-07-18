
class OutfitFilters {
  DateTime startDate;
  DateTime endDate;
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

  bool get isEmpty => startDate==null && endDate == null && genderIsMale == null && style == null && countryCode == null;

  bool operator ==(o) {
    return o is OutfitFilters &&
    o.startDate == startDate &&
    o.endDate == endDate &&
    o.genderIsMale == genderIsMale &&
    o.style == style &&
    o.countryCode == countryCode;
  }
 
  OutfitFilters.fromMap(Map<String, dynamic> map) :
    startDate = map['start_date'] == null ? null : DateTime.parse(map['start_date']),
    endDate = map['end_date'] == null ? null : DateTime.parse(map['end_date']),
    style = map['style'],
    genderIsMale = map['gender_is_male'],
    countryCode = map['country_code'];

  Map<String, dynamic> toJson() => {
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'gender_is_male': genderIsMale,
    'style': style,
    'country_code':countryCode,
  };

  
}