import 'package:flutter/cupertino.dart';
import 'package:memory_game/model/word.dart';

class UsersDataNotifier with ChangeNotifier {

  int _toRememberWordsNum;
  int _successRememberedWordsNum;
  int _wordsCommitted;
  int _totalNumOfWords;
  int _currentDayToRemember;
  List<Word> _wordList;

  int _numberToStageTest;
  List<String> _testingStagesList;
  List<String> _testingStageIsComplete;

  get toRememberWordsNum => _toRememberWordsNum;

  get successRememberedWordsNum => _successRememberedWordsNum;

  get wordsCommitted => _wordsCommitted;

  get totalNumOfWords => _totalNumOfWords;

  get currentDayToRemember => _currentDayToRemember;

  List<Word> get wordList => _wordList;

  List<String> get testingStagesList => _testingStagesList;

  List<String> get testingStageIsComplete => _testingStageIsComplete;

  get numberToStageTest => _numberToStageTest;


  set toRememberWordsNum(newValue) {
    _toRememberWordsNum = newValue;
    notifyListeners();
  }

  set testingStageIsComplete(newValue) {
    _testingStageIsComplete = newValue;
    notifyListeners();
  }


  set successRememberedWordsNum(newValue) {
    _successRememberedWordsNum = newValue;
    notifyListeners();
  }

  set wordsCommitted(newValue) {
    _wordsCommitted = newValue;
    notifyListeners();
  }

  set totalNumOfWords(newValue) {
    _totalNumOfWords = newValue;
    notifyListeners();
  }

  set currentDayToRemember(newValue) {
    _currentDayToRemember = newValue;
    notifyListeners();
  }

  set numberToStageTest(newValue){
    _numberToStageTest = newValue;
    notifyListeners();
  }

  set testingStagesList(newValue){
    _testingStagesList = newValue;
    notifyListeners();
  }

  setWordList(List<List<String>> data) {
    _wordList = List();
    data.forEach((element){
      bool isMemorised = (element[2] == '1');

      _wordList.add(Word.fromDatabase(element[0], element[1], isMemorised,element[3],int.parse(element[4]),element[5],element[6],element[7],element[8],element[9],element[10],element[11]));
      print(wordList[wordList.length-1].toString() + '   $isMemorised');
    }
    );

    notifyListeners();
  }
}