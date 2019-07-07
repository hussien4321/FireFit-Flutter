class DateFormatter {

  static String dateToRecentFormat(DateTime dateTime){
    DateTime current = DateTime.now();
    Duration diff = current.difference(dateTime);
    if(diff.inDays!=0){
      return '${dateTime.day}/${dateTime.month}';
    }
    else if(diff.inHours!=0){
      return '${diff.inHours}h ago';
    }
    else if(diff.inMinutes!=0){
      return '${diff.inMinutes}m ago';
    }
    else{
      return 'now';
    }
  }

  static String dateToSimpleFormat(DateTime dateTime){
    DateTime current = DateTime.now();
    if(_isSameDay(current, dateTime)){
      return 'Today';
    }
    String dateString = "";
    dateString += "${_monthToString(dateTime.month)} ${dateTime.day}${_daySuffix(dateTime)}";
    if(!_isSameYear(current, dateTime)){
      dateString += ' ${dateTime.year}';
    }
    return dateString;
  }

  static bool _isSameDay(DateTime time1, DateTime time2,) => time1.day == time2.day && time1.month == time2.month && time1.year == time2.year;

  static bool _isSameYear(DateTime time1, DateTime time2) => time1.year == time2.year;

  static String _monthToString(int month){
    switch (month) {
      case DateTime.january:
        return 'Jan';
        break;
      case DateTime.february:
        return 'Feb';
        break;
      case DateTime.march:
        return 'Mar';
        break;
      case DateTime.april:
        return 'Apr';
        break;
      case DateTime.may:
        return 'May';
        break;
      case DateTime.june:
        return 'June';
        break;
      case DateTime.july:
        return 'Jul';
        break;
      case DateTime.august:
        return 'Aug';
        break;
      case DateTime.september:
        return 'Sep';
        break;
      case DateTime.october:
        return 'Oct';
        break;
      case DateTime.november:
        return 'Nov';
        break;
      case DateTime.december:
        return 'Dec';
        break;
      default:
        return null;
    }
  }

  static String _daySuffix(DateTime dateTime) {
    switch (dateTime.day) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  } 
}