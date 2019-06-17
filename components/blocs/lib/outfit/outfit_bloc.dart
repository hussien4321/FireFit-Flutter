import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart'
;
class OutfitBloc{

  final OutfitRepository repository;
  List<StreamSubscription<dynamic>> _subscriptions;

  final _exploredOutfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get exploredOutfits => _exploredOutfitsController.stream; 
  final _savedOutfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get savedOutfits => _savedOutfitsController.stream; 
  final _myOutfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get myOutfits => _myOutfitsController.stream; 
  final _selectedOutfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get selectedOutfits => _selectedOutfitsController.stream; 
  final _feedOutfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get feedOutfits => _feedOutfitsController.stream; 

  final _exploreOutfitsController = PublishSubject<LoadOutfits>();
  Sink<LoadOutfits> get exploreOutfits => _exploreOutfitsController;
  final _loadMyOutfitsController = PublishSubject<LoadOutfits>();
  Sink<LoadOutfits> get loadMyOutfits => _loadMyOutfitsController;
  final _loadUserOutfitsController = PublishSubject<LoadOutfits>();
  Sink<LoadOutfits> get loadUserOutfits => _loadUserOutfitsController;
  final _loadFeedOutfitsController = PublishSubject<LoadOutfits>();
  Sink<LoadOutfits> get loadFeedOutfits => _loadFeedOutfitsController;
  final _loadSavedOutfitsController = PublishSubject<LoadOutfits>();
  Sink<LoadOutfits> get loadSavedOutfits => _loadSavedOutfitsController;

  final _selectedOutfitController = BehaviorSubject<Stream<Outfit>>();
  Stream<Outfit> get selectedOutfit => _selectedOutfitController.value;
  final _selectOutfitController = PublishSubject<int>();
  Sink<int> get selectOutfit => _selectOutfitController; 
  
  final _uploadOutfitsController = PublishSubject<UploadOutfit>();
  Sink<UploadOutfit> get uploadOutfit => _uploadOutfitsController;
  final _deleteOutfitController = PublishSubject<Outfit>();
  Sink<Outfit> get deleteOutfit => _deleteOutfitController;

  final _saveOutfitController = PublishSubject<OutfitSave>();
  Sink<OutfitSave> get saveOutfit => _saveOutfitController;
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
    _exploredOutfitsController.addStream(repository.getOutfits(SearchModes.EXPLORE));
    _myOutfitsController.addStream(repository.getOutfits(SearchModes.MINE));
    _savedOutfitsController.addStream(repository.getOutfits(SearchModes.SAVED));
    _selectedOutfitsController.addStream(repository.getOutfits(SearchModes.SELECTED));
    _feedOutfitsController.addStream(repository.getOutfits(SearchModes.FEED));

    _subscriptions = <StreamSubscription<dynamic>>[
      _exploreOutfitsController.listen(_exploreOutfits),
      _loadMyOutfitsController.listen(_loadMyOutfits),
      _loadUserOutfitsController.distinct().listen(_loadUserOutfits),
      _loadFeedOutfitsController.listen(_loadFeedOutfits),
      _loadSavedOutfitsController.listen(_loadSavedOutfits),
      _uploadOutfitsController.listen(_uploadOutfit),
      _deleteOutfitController.listen(_deleteOutfit),
      _saveOutfitController.listen(_saveOutfit),
      _likeOutfitController.listen((outfitImpression) => _triggerImpression(outfitImpression, 1)),
      _dislikeOutfitController.listen((outfitImpression) => _triggerImpression(outfitImpression, -1)),
      _selectOutfitController.listen(_getOutfitStream),
    ];
  }

  _exploreOutfits(LoadOutfits loadOutfits) async {
    loadOutfits.searchMode = SearchModes.EXPLORE;
    await _loadOutfits(loadOutfits);
  }
  _loadMyOutfits(LoadOutfits loadOutfits) async {
    loadOutfits.searchMode = SearchModes.MINE;
    await _loadOutfits(loadOutfits);
  }
  _loadFeedOutfits(LoadOutfits loadOutfits) async {
    loadOutfits.searchMode = SearchModes.FEED;
    await _loadOutfits(loadOutfits);
  }
  _loadUserOutfits(LoadOutfits loadOutfits) async {
    loadOutfits.searchMode = SearchModes.SELECTED;
    await _loadOutfits(loadOutfits);
  }
  _loadSavedOutfits(LoadOutfits loadOutfits) async {
    loadOutfits.searchMode = SearchModes.SAVED;
    await _loadOutfits(loadOutfits);
  }

  _loadOutfits(LoadOutfits LoadOutfits) async {
    _loadingController.add(true);
    final success = await repository.loadOutfits(LoadOutfits);
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

  _saveOutfit(OutfitSave saveData) async {
    final success = await repository.saveOutfit(saveData);
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
    _exploredOutfitsController.close();
    _myOutfitsController.close();
    _savedOutfitsController.close();
    _selectedOutfitsController.close();
    _feedOutfitsController.close();
    _exploreOutfitsController.close();
    _loadMyOutfitsController.close();
    _loadFeedOutfitsController.close();
    _loadUserOutfitsController.close();
    _loadSavedOutfitsController.close();
    _uploadOutfitsController.close();
    _selectedOutfitController.close();
    _selectOutfitController.close();
    _saveOutfitController.close();
    _likeOutfitController.close();
    _dislikeOutfitController.close();
    _loadingController.close();
    _successController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}