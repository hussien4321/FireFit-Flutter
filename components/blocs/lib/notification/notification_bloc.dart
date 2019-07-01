import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';

class NotificationBloc {

  final UserRepository repository;

  List<StreamSubscription<dynamic>> _subscriptions;

  final _registerNotificationTokenController = PublishSubject<String>();
  Sink<String> get registerNotificationToken => _registerNotificationTokenController;
  final _loadStaticNotificationsController = PublishSubject<LoadNotifications>();
  Sink<LoadNotifications> get loadStaticNotifications => _loadStaticNotificationsController;
  final _loadLiveNotificationsController = PublishSubject<LoadNotifications>();
  Sink<LoadNotifications> get loadLiveNotifications => _loadLiveNotificationsController;
  final _notificationsController = BehaviorSubject<List<OutfitNotification>>(seedValue: []);
  Stream<List<OutfitNotification>> get notifications => _notificationsController.stream; 

  final _markNotificationsSeenController = PublishSubject<MarkNotificationsSeen>();
  Sink<MarkNotificationsSeen> get markNotificationsSeen => _markNotificationsSeenController;

  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;
  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;
  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;


  NotificationBloc(this.repository) {
    _subscriptions = <StreamSubscription<dynamic>>[
      _registerNotificationTokenController.listen(_registerNotificationToken),
      _loadStaticNotificationsController.distinct().listen(_loadStaticNotifications),
      _loadLiveNotificationsController.listen(_loadLiveNotifications),
      _markNotificationsSeenController.listen(_markNotificationsSeen)
    ];
    _notificationsController.addStream(repository.getNotifications());
  }

  _registerNotificationToken(String userId) async {
    repository.registerNotificationToken(userId);
  }

  _loadStaticNotifications(LoadNotifications loadNotifications) async {
    _loadNotifications(LoadNotifications(
      userId: loadNotifications.userId,
      startAfterNotification: loadNotifications.startAfterNotification,
      isLive: false
    ));
  }
  _loadLiveNotifications(LoadNotifications loadNotifications) async {
    _loadNotifications(LoadNotifications(
      userId: loadNotifications.userId,
      startAfterNotification: loadNotifications.startAfterNotification,
      isLive: true
    ));
  }

  _loadNotifications(LoadNotifications loadNotifications) async {
    _loadingController.add(true);
    bool success = loadNotifications.startAfterNotification == null ? await repository.loadNotifications(loadNotifications) : await repository.loadMoreNotifications(loadNotifications);
    _loadingController.add(false);
    if(!success){
      _errorController.add('Failed to load notifications');
    };
  }

  _markNotificationsSeen(MarkNotificationsSeen markSeen){
    repository.markNotificationsSeen(markSeen);
  }

  void dispose() {
    _registerNotificationTokenController.close();
    _loadStaticNotificationsController.close();
    _loadLiveNotificationsController.close();
    _notificationsController.close();
    _markNotificationsSeenController.close();
    _loadingController.close();
    _errorController.close();
    _successController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}