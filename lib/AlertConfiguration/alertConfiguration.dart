/// Class represents a configuration of alerts
/// @author: Yizhou Zhao
/// @date: 2020-10-22 14:26
/// @lastUpdate: 2020-10-22 14:26

class AlertConfiguration{
  /// Attributes
  String _name;
  int _compare;
  double _rangeMin;
  double _rangeMax;
  int _duration;
  int _version;

  /// Constructor
  AlertConfiguration(this._name, this._compare, this._rangeMin, this._rangeMax,
      this._duration, this._version);

  /// Getters
  String get name{
    return _name;
  }

  int get compare{
    return _compare;
  }

  double get rangeMin{
    return _rangeMin;
  }

  double get rangeMax{
    return _rangeMax;
  }

  int get duration{
    return _duration;
  }

  int get version{
    return _version;
  }

}