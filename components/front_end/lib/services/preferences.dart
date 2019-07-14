import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:helpers/helpers.dart';

class Preferences {

  static final String _VERSION = '_VERSION';
  static final String CURRENT_CLOTHES_STYLE = 'CURRENT_CLOTHES_STYLE';
  static final String DEFAULT_START_PAGE = 'DEFAULT_START_PAGE';
  static final String LOOKBOOKS_SORT_BY_SIZE = 'LOOKBOOKS_SORT_BY_SIZE';
  

  final Map<String, dynamic> _initialPreferences = {
    _VERSION: 3,
    CURRENT_CLOTHES_STYLE : 'casualwear',
    DEFAULT_START_PAGE: AppConfig.MAIN_PAGES.first,
    LOOKBOOKS_SORT_BY_SIZE: false
  };

  Map<String, dynamic> _currentPreferences = {};

  Future<Map<String, dynamic>> get currentPreferences async {
    if(_currentPreferences.length != 0){
      return _currentPreferences;
    }
    await reInitiliaze();
    return _currentPreferences;
  }
  
  final String _fileName = 'user_stats.json';
  static File _jsonFile;
  
  static final Preferences _singleton = new Preferences._internal();

  factory Preferences() {
    return _singleton;
  }

  Preferences._internal() {
    reInitiliaze();
  }

  reInitiliaze() async {
    Directory directory = await getApplicationDocumentsDirectory();
    Directory dir = directory;
    _jsonFile = new File(dir.path +  "/" + _fileName);
    bool fileExists = _jsonFile.existsSync();
    if (fileExists){
      _currentPreferences = json.decode(_jsonFile.readAsStringSync());
      if(hasNewVersion){
        _addAnyMissingAttributes();
        _removeDeletedAttributes();
        _currentPreferences[_VERSION] = _initialPreferences[_VERSION];
      }
      _jsonFile.writeAsStringSync(json.encode(_currentPreferences));
    } else {
      _currentPreferences = _initialPreferences;
      _createPreferencesFile(_currentPreferences);
    }
  }

  void _createPreferencesFile(Map<String, dynamic> content) {
    _jsonFile.createSync();
    _jsonFile.writeAsStringSync(json.encode(content));
  }

  bool get hasNewVersion => !_currentPreferences.containsKey(_VERSION) || _currentPreferences[_VERSION] != _initialPreferences[_VERSION];

  void _addAnyMissingAttributes(){
    for(String missingKey in _initialPreferences.keys){
      if(!_currentPreferences.containsKey(missingKey)){
          print('adding key $missingKey');
        _currentPreferences[missingKey] = _initialPreferences[missingKey];
      }
    }
  }
  void _removeDeletedAttributes(){
    List<String> keysToDelete = [];
    for(String keyWhichMightNotExistsAnymore in _currentPreferences.keys){
      if(!_initialPreferences.containsKey(keyWhichMightNotExistsAnymore)){
        print('removing key $keyWhichMightNotExistsAnymore');
        keysToDelete.add(keyWhichMightNotExistsAnymore);
      }
    }
    keysToDelete.forEach((key) => _currentPreferences.remove(key));
  }

  void updatePreference(String key, dynamic value) {
    Map<String, dynamic> content = {key: value};
    Map<String, dynamic> jsonFileContent = json.decode(_jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    _currentPreferences = jsonFileContent;
    _jsonFile.writeAsStringSync(json.encode(jsonFileContent));
  }


  Future<dynamic> getPreference(String key) async {
    var preferences = await currentPreferences;
    return preferences[key];
  }
  
} 