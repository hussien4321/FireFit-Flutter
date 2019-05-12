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
}