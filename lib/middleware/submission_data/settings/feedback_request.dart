import '../../../middleware/entities.dart';

enum FeedbackType {
  SUGGESTION,
  BUG,
  PAYMENT,
  OTHER,
}

String feedbackTypeToString(FeedbackType type){
  switch (type) {
    case FeedbackType.BUG:
      return 'Bug';
    case FeedbackType.SUGGESTION:
      return 'Suggestion';
    case FeedbackType.PAYMENT:
      return 'Payment';
    case FeedbackType.OTHER:
      return 'Other';
    default:
      return 'Unkown';
  }
}

class FeedbackRequest {

  String userId;
  FeedbackType type;
  String message;
  bool isRequestingResponse;

  FeedbackRequest({
    this.userId,
    this.type = FeedbackType.BUG,
    this.message,
    this.isRequestingResponse = false,
  });

  bool get canBeSent => userId!=null && type != null && hasMessage;

  bool get hasMessage => message != null && message.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'type' : feedbackTypeToString(type), 
    'message' : message,
    'is_requesting_response': isRequestingResponse,
  };
}