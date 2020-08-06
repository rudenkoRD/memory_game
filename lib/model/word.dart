class Word extends Object{
  int _mempool;

  String recordnum;
  String read;
  String smempool;
  String _giw;
  String _mainText;
  String _firstValue;
  String _secondValue;
  String  _audioFileName;
  String _displayFileName;
  String _displayAudioName;
  bool _isMemorized;

  get mainText => _mainText;
  get firstValue => _firstValue;
  get secondValue => _secondValue;
  get audioFileName => _audioFileName;
  get isMemorized => _isMemorized;
  get displayFileName => _displayFileName;
  get displayAudioName => _displayAudioName;
  get giw => _giw;

  get mempool => _mempool;
  set mempool(newValue) => _mempool = newValue;
  set isMemorized(newValue) => _isMemorized = newValue;
  set giw(newValue) => _giw = newValue;

  Word.fromDatabase(this.recordnum, this.read, this._isMemorized, this._giw, this._mempool, this.smempool, this._mainText, this._audioFileName, this._firstValue, this._secondValue, this._displayFileName, this._displayAudioName);

  @override
  String toString() {
    return '$recordnum,$read,${_isMemorized ? '1':'0'},$giw,$_mempool,$smempool,$_mainText,$_audioFileName,$_firstValue,$_secondValue,$_displayFileName,$_displayAudioName';
  }
}