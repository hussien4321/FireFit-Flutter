import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:middleware/middleware.dart'
;
class NewOutfitBloc{

  final OutfitRepository repository;
  List<StreamSubscription<dynamic>> _subscriptions;

  final _outfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
  Stream<List<Outfit>> get outfits => _outfitsController.stream; 
  
  final _loadOutfitsController = PublishSubject<Null>();
  Sink<Null> get loadOutfits => _loadOutfitsController;

  NewOutfitBloc(this.repository) {
    _outfitsController.addStream(repository.getOutfits().asStream());
    _subscriptions = <StreamSubscription<dynamic>>[
      _loadOutfitsController.listen(_loadClothes),
    ];
  }

  _loadClothes([_]) async {
    final list = await repository.getOutfits();
    _outfitsController.add(_outfitsController.value..addAll(list));
  }

  void dispose() {
    _outfitsController.close();
    _loadOutfitsController.close();
    _subscriptions.forEach((subscription) => subscription.cancel());
  }
}

// class OutfitBloc {

//   final List<StreamSubscription<dynamic>> _subscriptions;

//   PublishSubject<Null> loadOutfits;

//   Stream<List<Outfit>> outfits;
  
  
//   factory OutfitBloc(OutfitRepository repository) {


//     final loadOutfitsController = PublishSubject<Null>();

//     final outfitsController = BehaviorSubject<List<Outfit>>(seedValue: []);
//     outfitsController.addStream(repository.getOutfits().asStream());

//     loadOutfitsController.doOnCancel(() {
//       outfitsController.close();
//     });

//     void _loadClothes([_]) async {
//       final list = await repository.getOutfits();
//       outfitsController.add(outfitsController.value..addAll(list));
//     }

//     final subscriptions = <StreamSubscription<dynamic>>[
//       loadOutfitsController.listen(_loadClothes)
//     ];

//     return OutfitBloc._(
//       subscriptions,
//       loadOutfits: loadOutfitsController,

//       outfits: outfitsController.stream,
//     );
//   }

//   OutfitBloc._(
//     this._subscriptions,
//   {
//     this.loadOutfits,

//     this.outfits,
//   });


  
//   void close() {
//     loadOutfits.close();
//     _subscriptions.forEach((subscription) => subscription.cancel());
//   }

// }
