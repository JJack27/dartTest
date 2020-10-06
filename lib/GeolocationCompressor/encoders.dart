import 'dart:math';
import 'dart:core';

/// Abstract class for encoders
abstract class _BaseEncoder{
  List<int> encode(double value);
  int _bitUsed;

  /// Convert decimal integer to binary format as list of integer
  ///
  /// arguments:
  ///   - value, int
  /// return:
  ///   - List<int>
  /// throw:
  ///   - Exception
  List<int> _decimalToBinaryList(int value){
    if(value < 0){
      throw Exception("Argument value has to be non-negative integer, but given $value.");
    }
    String binaryString = value.toRadixString(2);

    List<int> result = [];
    for(var bit in binaryString.split('')){
      result.add(int.parse(bit));
    }
    return result;
  }

  /// Degree to radian
  /// args:
  ///   - deg: double
  double _degToRad(double deg){
    return (deg * pi) / 180.0;
  }
}
/// Encoder that encodes the latitude information
class _LatitudeEncoder extends _BaseEncoder{


  @override
  List<int> encode(double value){
    // determine flags
  }
}

/// Encoder that encodes the longitude information
class _LongitudeEncoder extends _BaseEncoder{

  // the degree of magnitude you want longitude to scale. The larger, the preciser.
  int _deg = 7;

  // The bit shift of flag that indicate if (pi/2 < longitude < 3pi/2)
  int _overNinetyDegBitShifts = 24;

  // The bit shift of flag indicate if longitude is negative
  int _negBitShifts = 25;

  /// Constructor
  /// args:
  ///   - deg: the degree of magnitude you want longitude to scale. The larger, the preciser.
  _LongitudeEncoder({deg:7}){
    this._deg = deg;

    if(this._deg != 7){
      // Get the maximum value of encoded longitude
      int encodedUpperBound = pow(10, _deg);

      // Calculate bits shift of flags: overNinetyDeg, negative
      _overNinetyDegBitShifts = 0;
      while(encodedUpperBound != 0){
        encodedUpperBound = encodedUpperBound >> 1;
        _overNinetyDegBitShifts++;
      }
      _negBitShifts = _overNinetyDegBitShifts + 1;
    }

    _bitUsed = _negBitShifts + 1;
  }

  @override
  List<int> encode(double value){
    // Determine flags
    int negative = value >= 0 ? 0 : 1;
    int overNinetyDeg = value.abs() > 90 ? 1 : 0;

    // encoding the longitude
    double longitude = sin(_degToRad(value));
    int encodedLng = (longitude * (pow(10, _deg))).toInt().abs();
    encodedLng = encodedLng | (negative << _negBitShifts) | (overNinetyDeg << _overNinetyDegBitShifts);

    return _decimalToBinaryList(encodedLng);
  }
}

/// Encoder that encodes dateTime information
class _DatetimeEncoder extends _BaseEncoder{
  @override
  List<int> encode(double value){

  }
}

/// Class that encodes all information relate with geolocation & time information
class LocationTimeEncoder{
  final _LongitudeEncoder _longitudeEncoder = new _LongitudeEncoder();
  final _LatitudeEncoder _latitudeEncoder = new _LatitudeEncoder();
  final _DatetimeEncoder _datetimeEncoder = new _DatetimeEncoder();


}

void main(){
  List<double> lngTests = [0, 1, 45, 89, 90, 91, 100, 135, 179, 180];
  List<double> lngTestsTemp = [];
  List<List<int>> lngResult = [[0] ,
      [1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
      [1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
      [1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
      [1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0] ,
      [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
      [1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1] ,
      [1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
      [1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ,
      [0] ,
      [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
      [1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
      [1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
      [1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0] ,
      [1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
      [1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1] ,
      [1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  ];
  for(double i in lngTests){
    lngTestsTemp.add(-i);
  }
  lngTests = lngTests + lngTestsTemp;
  _LongitudeEncoder lngEncoder = new _LongitudeEncoder();

  for(int i = 0; i < lngTests.length; i++){
    assert(lngEncoder.encode(lngTests[i]) == lngResult[i],
      lngTests[i].toString() + ' is wrong');

  }
  print('Pass');


}