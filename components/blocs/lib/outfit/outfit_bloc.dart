import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart'
;
class OutfitBloc{

  final OutfitRepository repository;
  List<StreamSubscription<dynamic>> _subscriptions;

  final _outfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get outfits => _outfitsController.stream; 
  
  final _exploreOutfitsController = PublishSubject<Null>();
  Sink<Null> get exploreOutfits => _exploreOutfitsController;

  final _createOutfitsController = PublishSubject<CreateOutfit>();
  Sink<CreateOutfit> get createOutfit => _createOutfitsController;

  final _loadingController = PublishSubject<bool>();
  Observable<bool> get isLoading => _loadingController.stream;

  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;

  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;
  
  OutfitBloc(this.repository) {
    _outfitsController.addStream(repository.getOutfits());
    _subscriptions = <StreamSubscription<dynamic>>[
      _exploreOutfitsController.listen(_exploreOutfits),
      _createOutfitsController.listen(_uploadOutfit),
      _outfitsController.listen((outfits) => print("FOUND ${outfits.length} OUTFITS")),
    ];
  }

  _exploreOutfits([_]) async {
    _loadingController.add(true);
    final success = await repository.exploreOutfits();
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load outfits");
    }
  }

  _uploadOutfit(CreateOutfit createOutfit) async {
    _loadingController.add(true);
    final success = await repository.uploadOutfit(createOutfit);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to create new outfit");
    }
  }

  void dispose() {
    _outfitsController.close();
    _exploreOutfitsController.close();
    _createOutfitsController.close();
    _loadingController.close();
    _successController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}