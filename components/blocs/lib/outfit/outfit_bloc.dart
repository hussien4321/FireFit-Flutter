import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart';
import 'package:blocs/blocs.dart';
import 'dart:math';

class OutfitBloc{

  final OutfitRepository repository;
  final UserRepository _userRepository;
  final Preferences _preferences;

  List<StreamSubscription<dynamic>> _subscriptions;

  final _exploredOutfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get exploredOutfits => _exploredOutfitsController.stream; 
  final _lookbookOutfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get lookbookOutfits => _lookbookOutfitsController.stream; 
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
  final _loadLookbookOutfitsController = PublishSubject<LoadOutfits>();
  Sink<LoadOutfits> get loadLookbookOutfits => _loadLookbookOutfitsController;

  final _selectedOutfitController = BehaviorSubject<Outfit>(seedValue: null);
  Stream<Outfit> get selectedOutfit => _selectedOutfitController;
  final _selectOutfitController = PublishSubject<LoadOutfit>();
  Sink<LoadOutfit> get selectOutfit => _selectOutfitController; 

  final _loadLookbooksController = PublishSubject<LoadLookbooks>();
  Sink<LoadLookbooks> get loadLookbooks => _loadLookbooksController;
  final _lookbooksController = BehaviorSubject<List<Lookbook>>(seedValue: []);
  Stream<List<Lookbook>> get lookbooks => _lookbooksController.stream; 
  
  final _createLookbookController = PublishSubject<AddLookbook>();
  Sink<AddLookbook> get createLookbook => _createLookbookController;
  final _editLookbookController = PublishSubject<EditLookbook>();
  Sink<EditLookbook> get editLookbook => _editLookbookController;
  final _deleteLookbookController = PublishSubject<Lookbook>();
  Sink<Lookbook> get deleteLookbook => _deleteLookbookController;
  
  final _uploadOutfitsController = PublishSubject<UploadOutfit>();
  Sink<UploadOutfit> get uploadOutfit => _uploadOutfitsController;
  final _editOutfitController = PublishSubject<EditOutfit>();
  Sink<EditOutfit> get editOutfit => _editOutfitController;
  final _deleteOutfitController = PublishSubject<Outfit>();
  Sink<Outfit> get deleteOutfit => _deleteOutfitController;

  final _saveOutfitController = PublishSubject<OutfitSave>();
  Sink<OutfitSave> get saveOutfit => _saveOutfitController;
  final _deleteSaveController = PublishSubject<DeleteSave>();
  Sink<DeleteSave> get deleteSave => _deleteSaveController;
  final _rateOutfitController = PublishSubject<OutfitRating>();
  Sink<OutfitRating> get rateOutfit => _rateOutfitController;

  final _showAdController = PublishSubject<void>();
  Observable<void> get showAd => _showAdController.stream;

  final _isBackgroundLoadingController = PublishSubject<bool>();
  Observable<bool> get isBackgroundLoading => _isBackgroundLoadingController.stream;

  final _noOutfitFoundController = PublishSubject<bool>();
  Observable<bool> get noOutfitFound => _noOutfitFoundController.stream;

  final _loadingController = BehaviorSubject<bool>(seedValue: false);
  BehaviorSubject<bool> get isLoading => _loadingController.stream;
  final _loadingItemsController = BehaviorSubject<bool>(seedValue: false);
  BehaviorSubject<bool> get isLoadingItems => _loadingItemsController;
  final _successController = PublishSubject<bool>();
  Observable<bool> get isSuccessful => _successController.stream;
  final _successMessageController = PublishSubject<String>();
  Observable<String> get successMessage => _successMessageController.stream;
  final _errorController = PublishSubject<String>();
  Observable<String> get hasError => _errorController.stream;
  
  OutfitBloc(this.repository, this._userRepository, this._preferences) {    
    _exploredOutfitsController.addStream(repository.getOutfits(SearchModes.EXPLORE));
    _myOutfitsController.addStream(repository.getOutfits(SearchModes.MINE));
    _lookbookOutfitsController.addStream(repository.getOutfits(SearchModes.SAVED));
    _selectedOutfitsController.addStream(repository.getOutfits(SearchModes.SELECTED));
    _selectedOutfitController.addStream(repository.getOutfit(SearchModes.SELECTED_SINGLE));
    _feedOutfitsController.addStream(repository.getOutfits(SearchModes.FEED));
    _lookbooksController.addStream(repository.getLookbooks());

    _subscriptions = <StreamSubscription<dynamic>>[
      _exploreOutfitsController.distinct().listen(_exploreOutfits),
      _loadMyOutfitsController.distinct().listen(_loadMyOutfits),
      _loadUserOutfitsController.distinct().listen(_loadUserOutfits),
      _loadFeedOutfitsController.distinct().listen(_loadFeedOutfits),
      _loadLookbookOutfitsController.distinct().listen(_loadLookbookOutfits),
      _loadLookbooksController.listen(_loadLookbooks),
      _uploadOutfitsController.listen(_uploadOutfit),
      _editOutfitController.listen(_editOutfit),
      _deleteOutfitController.listen(_deleteOutfit),
      _createLookbookController.listen(_createLookbook),
      _editLookbookController.listen(_editLookbook),
      _deleteLookbookController.listen(_deleteLookbook),
      _saveOutfitController.listen(_saveOutfit),
      _deleteSaveController.listen(_deleteSave),
      _rateOutfitController.listen(_rateOutfit),
      _selectOutfitController.listen(_loadOutfit),
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
  _loadLookbookOutfits(LoadOutfits loadOutfits) async {
    loadOutfits.searchMode = SearchModes.SAVED;
    await _loadOutfits(loadOutfits);
  }

  _loadOutfits(LoadOutfits loadOutfits) async {
    _loadingItemsController.add(true);
    final success = loadOutfits.startAfterOutfit==null ? await repository.loadOutfits(loadOutfits) : await repository.loadMoreOutfits(loadOutfits);
    _loadingItemsController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load outfits");
    }
  }

  _loadLookbooks(LoadLookbooks loadLookbooks) async {
    _loadingItemsController.add(true);
    final success = await repository.loadLookbooks(loadLookbooks);
    _loadingItemsController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load lookbooks");
    }
  }

  _uploadOutfit(UploadOutfit uploadOutfit) async {
    _successController.add(true);
    _isBackgroundLoadingController.add(true);
    Future.delayed(Duration(milliseconds: 1500), () => _showAdController.add(null));
    final success = await repository.uploadOutfit(uploadOutfit);
    _isBackgroundLoadingController.add(false);
    if(success){
      _successMessageController.add("Outfit uploaded!");
    }else{
      _errorController.add("Failed to create new outfit");
    }
  }
  _editOutfit(EditOutfit editOutfit) async {
    _loadingController.add(true);
    final success = await repository.editOutfit(editOutfit);
    _loadingController.add(false);
    _successController.add(success);
    if(success){
      _successMessageController.add("Edit successful!");
    }else{
      _errorController.add("Failed to edit outfit");
    }
  }

  _deleteOutfit(Outfit outfit) async {
    final success = await repository.deleteOutfit(outfit);
    _successController.add(success);
    if(success){
      _successMessageController.add("Delete successful!");
      
      String userId = outfit.poster.userId;
      
      bool sortBySize = await _preferences.getPreference(Preferences.LOOKBOOKS_SORT_BY_SIZE);
      _loadLookbooks(LoadLookbooks(
        userId: userId,
        sortBySize: sortBySize,
      ));
      
      _userRepository.loadUserDetails(LoadUser(
        currentUserId: userId,
        searchMode: SearchModes.MINE,
        userId: userId,
      ), SearchModes.MINE);
    }else{
      _errorController.add("Failed to delete outfit");
    }
  }

  _createLookbook(AddLookbook addLookbook) async {
    _loadingController.add(true);
    final success = await repository.createLookbook(addLookbook);
    _loadingController.add(false);
    _successController.add(success);
    if(success){
      _successMessageController.add("Lookbook created!");
    }else{
      _errorController.add("Failed to create new lookbook");
    }
  }
  _editLookbook(EditLookbook editLookbook) async {
    final success = await repository.editLookbook(editLookbook);
    _successController.add(success);
    if(success){
      _successMessageController.add("Edit successful!");
    }else{
      _errorController.add("Failed to edit lookbook");
    }
  }

  _deleteLookbook(Lookbook lookbook) async {
    _loadingController.add(true);
    final success = await repository.deleteLookbook(lookbook);
    _loadingController.add(false);
    _successController.add(success);
    if(success){
      _successMessageController.add("Delete successful!");
    }else{
      _errorController.add("Failed to delete lookbook");
    }
  }

  _rateOutfit(OutfitRating outfitRating) async {
    final success = await repository.rateOutfit(outfitRating);
    if(success){
      String message = _generateRandomMessage(outfitRating);
      _successMessageController.add(message);
    }else{
      _errorController.add("Failed to react to outfit");
    }
  }

  String _generateRandomMessage(OutfitRating outfitRating){
    Random random =Random();
    List<String> badRatings = [
      "Leave a suggestion?",
      "Share why you don't like it?",
      "Maybe offer some advice?",
    ];
    List<String> mediumRatings = [
      "Thanks for rating!",
      "They will appreciate your feedback!",
      "Thanks alot!",
      "Nice one!"
    ];
    List<String> goodRatings = [
      "You just made someone's day!",
      "WOOHOO!",
      "Save this style if you want to remember it!"
    ];
    switch (outfitRating.ratingValue) {
      case 1:
        return badRatings[random.nextInt(badRatings.length)];
      case 5:
        return goodRatings[random.nextInt(goodRatings.length)];
      default:
        return mediumRatings[random.nextInt(mediumRatings.length)];
    }
  }
  _saveOutfit(OutfitSave saveData) async {
    final resId = await repository.saveOutfit(saveData);
    final success = resId != -1;
    if(success){
      if(resId == 0){
        _successMessageController.add("Item already exists in lookbook!");
      }else{
        _successMessageController.add("Added to lookbook!");
      }
    }else{
      _errorController.add("Failed to add to lookbook");
    }
  }

  _deleteSave(DeleteSave deleteSave) async {
    final success = await repository.deleteSave(deleteSave);
    if(success){
      _successMessageController.add("Removed from lookbook!");
    }else{
      _errorController.add("Failed to remove from lookbook");
    }
  }

  _loadOutfit(LoadOutfit loadOutfit) async {
    loadOutfit.searchModes = SearchModes.SELECTED_SINGLE;
    _loadingController.add(true);
    bool success = false;
    try {
      success =  await repository.loadOutfit(loadOutfit);     
    } on NoItemFoundException catch (_) {
      print('caught _noOutfitFoundController!');
      success = true;
      _noOutfitFoundController.add(true);
    }
    
    _loadingController.add(false);
    _successController.add(success);
    if(!success){
      _errorController.add("Failed to load outfits");
    }
  }

  void dispose() {
    _exploredOutfitsController.close();
    _myOutfitsController.close();
    _lookbookOutfitsController.close();
    _selectedOutfitsController.close();
    _feedOutfitsController.close();
    _exploreOutfitsController.close();
    _loadMyOutfitsController.close();
    _loadFeedOutfitsController.close();
    _loadUserOutfitsController.close();
    _loadLookbookOutfitsController.close();
    _loadLookbooksController.close();
    _lookbooksController.close();
    _showAdController.close();
    _uploadOutfitsController.close();
    _editOutfitController.close();
    _deleteOutfitController.close();
    _createLookbookController.close();
    _editLookbookController.close();
    _noOutfitFoundController.close();
    _deleteLookbookController.close();
    _selectedOutfitController.close();
    _selectOutfitController.close();
    _saveOutfitController.close();
    _deleteSaveController.close();
    _rateOutfitController.close();
    _loadingController.close();
    _loadingItemsController.close();
    _isBackgroundLoadingController.close();
    _successController.close();
    _successMessageController.close();
    _errorController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}