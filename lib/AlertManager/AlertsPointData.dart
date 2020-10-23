import 'dart:math';

/// Alarm for point data
/// - listening to given data
/// - Trigger alarm if possible
/// ==============================
/// @author: Yizhou Zhao
/// @date: 2020-10-23 13:54
/// @lastUpdate: 2020-10-23 13:54


/// Class represents the alarm listener for point data
class AlertPointData{
  /// Attributes
  int _counter;
  int _configId;
  double _rangeMax;
  double _rangeMin;
  int _duration;
  int _compare;
  String _dataName;
  // deprecated: double _dataToListen;
  // whether to apply smoothing techniques on data;
  bool _smooth;
  // Deprecated: double _smoothFactor;

  int _maxQueueLen;
  List<double> _queue;

  /// Constructor
  AlertPointData(this._dataName, this._configId, this._compare, this._rangeMin,
      this._rangeMax, this._duration,  {bool smooth: true}){
    _counter = 0;
    _smooth = smooth;

    // update _queueLength if applying smooth
    if(_smooth){
      _maxQueueLen = log(_duration) ~/ log(3);
      _maxQueueLen = _maxQueueLen < 1 ? 1 : _maxQueueLen;
    }
  }

  /// Stepping method when new data comes in. Current using exponential moving average
  /// Arguments:
  ///   - data: double
  /// Return:
  ///   - double
  double _step(double data){
    _queue.add(data);
    if(_queue.length > _maxQueueLen){
      _queue.removeAt(0);
    }

    double sum = 0;
    for(var num in _queue){
      sum += num;
    }
    return sum / _queue.length;
  }

  /// Check if we should send emergency message
  /// Arguments:
  ///   - data: double
  /// Return:
  ///   - bool: true if need to send emergency message
  bool inDanger(double data){
    bool warningCondition = false;

    // smooth data if _smooth is set true
    if(_smooth){
      data = _step(data);
    }

    switch (_compare){
      // case for data is greater than sth.
      case 0:{
        if(data > _rangeMin){
          warningCondition = true;
        }
      }
      break;

      // case for data is less than a specific value
      case 1:{
        if(data < _rangeMax){
          warningCondition = true;
        }
      }
      break;

      // case for data is within a range
      case 2:{
        if(data < _rangeMax && data > _rangeMin){
          warningCondition = true;
        }
      }
      break;
    }

    // reset time counter if not in warning condition
    if(!warningCondition){
      _counter = 0;
    }else{
      // else, check if it's satisfying duration condition
      _counter += 1;
      if(_counter >= _duration){
        return true;
      }
    }
    return false;
  }

  /// Getters
  String get name{
    return _dataName;
  }

  int get configId{
    return _configId;
  }

}