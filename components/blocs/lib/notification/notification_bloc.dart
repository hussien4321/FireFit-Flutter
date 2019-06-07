import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';

class NotificationBloc {

  final UserRepository repository;

  List<StreamSubscription<dynamic>> _subscriptions;

  final _registerNotificationTokenController = PublishSubject<String>();
  Sink<String> get registerNotificationToken => _registerNotificationTokenController;
  final _loadNotificationsController = PublishSubject<String>();
  Sink<String> get loadNotifications => _loadNotificationsController;
  final _notificationsController = BehaviorSubject<List<OutfitNotification>>(seedValue: []);
  Stream<List<OutfitNotification>> get notifications => _notificationsController.stream; 

  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;
  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;
  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;


  NotificationBloc(this.repository) {
    _subscriptions = <StreamSubscription<dynamic>>[
      _registerNotificationTokenController.listen(_registerNotificationToken),
      _loadNotificationsController.listen(_loadNotifications),
    ];
    _notificationsController.addStream(repository.getNotifications());
  }

  _registerNotificationToken(String userId) async {
    repository.registerNotificationToken(userId);
  }

  _loadNotifications(String userId) async {
    _loadingController.add(true);
    bool success = await repository.loadNotifications(userId);
    _loadingController.add(false);
    if(!success){
      _errorController.add('Failed to load notifications');
    };
  }

  void dispose() {
    _registerNotificationTokenController.close();
    _loadNotificationsController.close();
    _notificationsController.close();
    _loadingController.close();
    _errorController.close();
    _successController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}