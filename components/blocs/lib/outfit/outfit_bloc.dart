import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart'
;
class OutfitBloc{

  final OutfitRepository repository;
  List<StreamSubscription<dynamic>> _subscriptions;

  final _outfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get outfits => _outfitsController.stream; 
  
  final _exploreOutfitsController = PublishSubject<ExploreOutfits>();
  Sink<ExploreOutfits> get exploreOutfits => _exploreOutfitsController;
  
  final _selectedOutfitController = BehaviorSubject<Stream<Outfit>>();
  Stream<Outfit> get selectedOutfit => _selectedOutfitController.value;

  final _selectOutfitController = PublishSubject<int>();
  Sink<int> get selectOutfit => _selectOutfitController; 
  
  final _uploadOutfitsController = PublishSubject<UploadOutfit>();
  Sink<UploadOutfit> get uploadOutfit => _uploadOutfitsController;

  final _deleteOutfitController = PublishSubject<Outfit>();
  Sink<Outfit> get deleteOutfit => _deleteOutfitController;

  final _likeOutfitController = PublishSubject<OutfitImpression>();
  Sink<OutfitImpression> get likeOutfit => _likeOutfitController;

  final _dislikeOutfitController = PublishSubject<OutfitImpression>();
  Sink<OutfitImpression> get dislikeOutfit => _dislikeOutfitController;

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
      _uploadOutfitsController.listen(_uploadOutfit),
      _deleteOutfitController.listen(_deleteOutfit),
      // _loadingController.listen((loading) => print('got loading = $loading')),
      _likeOutfitController.listen((outfitImpression) => _triggerImpression(outfitImpression, 1)),
      _dislikeOutfitController.listen((outfitImpression) => _triggerImpression(outfitImpression, -1)),
      _selectOutfitController.listen(_getOutfitStream),
    ];
  }

  _exploreOutfits(ExploreOutfits explore) async {
    _loadingController.add(true);
    final success = await repository.exploreOutfits(explore);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load outfits");
    }
  }

  _uploadOutfit(UploadOutfit uploadOutfit) async {
    _loadingController.add(true);
    final success = await repository.uploadOutfit(uploadOutfit);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to create new outfit");
    }
  }

  _deleteOutfit(Outfit outfit) async {
    _loadingController.add(true);
    final success = await repository.deleteOutfit(outfit);
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to delete outfit");
    }
  }

  _triggerImpression(OutfitImpression outfitImpression, int impressionValue){
    if(outfitImpression.outfit.userImpression == impressionValue){
      _impressOutfit(outfitImpression, 0);
    }else{
      _impressOutfit(outfitImpression, impressionValue);
    }
  }

  _impressOutfit(OutfitImpression outfitImpression, int impressionValue) async {
    outfitImpression.impressionValue = impressionValue;
    final success = await repository.impressOutfit(outfitImpression);
    if(!success){
      _errorController.add("Failed to react to outfit");
    }
  }

  _getOutfitStream(int outfitId) async {
    _loadingController.add(true);
    _selectedOutfitController.add(repository.getOutfit(outfitId));
    _loadingController.add(false);
  }

  void dispose() {
    _outfitsController.close();
    _exploreOutfitsController.close();
    _uploadOutfitsController.close();
    _selectedOutfitController.close();
    _selectOutfitController.close();
    _likeOutfitController.close();
    _dislikeOutfitController.close();
    _loadingController.close();
    _successController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}