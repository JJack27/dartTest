import 'dart:math';
import 'dart:core';
import 'package:collection/collection.dart';

/// Abstract class for encoders
abstract class _BaseEncoder{
  List<int> encode(var value);
  int _bitUsed;

  int get bitUsed{
    return _bitUsed;
  }
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
    if(binaryString.length < this._bitUsed){
      String prefix = '';
      for(int i = 0; i < _bitUsed - binaryString.length; i++){
        prefix += '0';
      }
      binaryString = prefix + binaryString;
    }

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
  // the degree of magnitude you want longitude to scale. The larger, the preciser.
  int _deg = 7;

  // The bit shift of flag indicate if longitude is negative
  int _negBitShifts = 24;

  /// Constructor
  /// args:
  ///   - deg: the degree of magnitude you want longitude to scale. The larger, the preciser.
  _LatitudeEncoder({deg:7}){
    this._deg = deg;

    if(this._deg != 7){
      // Get the maximum value of encoded longitude
      int encodedUpperBound = pow(10, _deg);

      // Calculate bits shift of the flag: negative
      _negBitShifts = 0;
      while(encodedUpperBound != 0){
        encodedUpperBound = encodedUpperBound >> 1;
        _negBitShifts++;
      }
    }
    _bitUsed = _negBitShifts + 1;
  }

  /// Encode the given longitude value to a list of integer of 1 and 0s
  /// args:
  ///   - value - double: longitude with range [-180, 180]
  /// return:
  ///   - List<int>
  /// throw:
  ///   - FormatException
  @override
  List<int> encode(var value){
    if(value < -90 || value > 90){
      throw FormatException("Latitude value has to be in range [-180, 180]");
    }
    // Determine flags
    int negative = value >= 0 ? 0 : 1;

    // encoding the longitude
    double latitude = sin(_degToRad(value));
    int encodedLat = (latitude * (pow(10, _deg))).toInt().abs();
    encodedLat = encodedLat | (negative << _negBitShifts);

    return _decimalToBinaryList(encodedLat);
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

  /// Encode the given longitude value to a list of integer of 1 and 0s
  /// args:
  ///   - value - double: longitude with range [-180, 180]
  /// return:
  ///   - List<int>
  /// throw:
  ///   - FormatException
  @override
  List<int> encode(var value){
    if(value < -180 || value > 180){
      throw FormatException("Longitude value has to be in range [-180, 180]");
    }
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
  // Options
  bool _exactYear = true;
  bool _date = true;

  // Masks
  int _yearMask = 0x3FF00000;
  int _monthMask = 0xF0000;
  int _dateMask = 0xF800;
  int _hrMask = 0x7C0;
  int _minMask = 0x3F;
  //int _fieldMask = 0x3FFFFFFF;

  // Bits for each field
  int _yearBits = 10;
  int _monthBits = 4;
  int _dateBits = 5;
  int _hrBits = 5;
  int _minBits = 6;

  // Shifts
  int _hrShift = 6;
  int _dateShift;
  int _monthShift;
  int _yearShift;

  /// Constructor
  /// args:
  ///   - exactYear - bool: optional
  ///   - date - bool: optional
  _DatetimeEncoder({bool exactYear:true, bool date:true}) {
    _exactYear = exactYear;
    _date = date;


    // Configure based on options
    if (!_date){
      _dateBits = 0;
      _monthBits = 0;
      _yearBits = 0;
    }
    if (!_exactYear) {
      _yearBits = min(_yearBits, 1);
      if(_yearBits == 1){
        _yearMask = 0x100000;
      }else{
        _yearMask = 0;
      }
    }

    // calculating shifts
    _dateShift = _hrShift + _hrBits;
    _monthShift = _dateShift + _dateBits;
    _yearShift = _monthShift + _monthBits;

    _bitUsed = _yearBits + _monthBits + _dateBits + _hrBits + _minBits;
  }

  /// Encoding string time stamp to list of integers
  /// args:
  ///   - value - String: timestamp
  /// return:
  ///   - List<int>
  /// throws:
  ///   - FormatException
  @override
  List<int> encode(var value){
    // Initialization
    int year = 0;
    int month = 0;
    int day = 0;
    int hr = 0;
    int mins = 0;
    int encoded;

    // parsing string
    List<String> dateTime = value.split(' ');
    List<String> date = dateTime[0].split('-');
    List<String> time = dateTime[1].split(':');
    hr = int.parse(time[0]);
    mins = int.parse(time[1]);

    if(hr < 0 || hr > 23){
      throw FormatException('Hour must be within the range [0, 23]');
    }

    if(mins < 0 || mins > 59){
      throw FormatException('Minutes must be within the rage [0, 23]');
    }

    // encode time
    encoded = mins;
    encoded |= (hr << _hrShift);

    if(_date){
      year = int.parse(date[0]) % 1000;
      if(!_exactYear){
        year = year % 2;
      }
      month = int.parse(date[1]);
      day = int.parse(date[2]);

      // encode date
      encoded |= day << _dateShift;
      encoded |= month << _monthShift;
      encoded |= year << _yearShift;
    }

    return _decimalToBinaryList(encoded);
  }
}

/// Class that encodes all information relate with geolocation & time information
class LocationTimeEncoder{
  _LongitudeEncoder _longitudeEncoder;
  _LatitudeEncoder _latitudeEncoder;
  _DatetimeEncoder _datetimeEncoder;
  LocationTimeEncoder({lngDeg:7, latDeg:7, exactYear:true, date:true}){
    _longitudeEncoder = new _LongitudeEncoder(deg:lngDeg);
    _latitudeEncoder = new _LatitudeEncoder(deg:latDeg);
    _datetimeEncoder = new _DatetimeEncoder(exactYear: exactYear, date: date);
  }

  List<int> encode(String dateTime, double lng, double lat){
    return [..._datetimeEncoder.encode(dateTime), ..._longitudeEncoder.encode(lng), ..._latitudeEncoder.encode(lat)];
  }


}










void main(){
  Function eq = const ListEquality().equals;

  // Testing Longitudes
  List<double> lngTests = [0, 1, 45, 89, 90, 91, 100, 135, 179, 180];
  List<double> lngTestsTemp = [];
  List<List<int>> lngResult = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ,
    [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
    [0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
    [0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
    [0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0] ,
    [0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
    [0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1] ,
    [0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
    [0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ,
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ,
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
    assert(eq(lngEncoder.encode(lngTests[i]), lngResult[i]),
      lngTests[i].toString() + ' is wrong.\nShould be: '
          + lngResult[i].toString() + '\nGet:'
          + lngEncoder.encode(lngTests[i]).toString());
  }

  try{
    lngEncoder.encode(-180.1);
    throw Exception();
  }on FormatException{
  }catch(e){throw Exception("-180.1, caught unexpected exception.");}

  try{
    lngEncoder.encode(180.1);
    throw Exception();
  }on FormatException{
  }catch(e){throw Exception("180.1, caught unexpected exception.");}

  print('Longitude encoding passed!');

  // =========================
  // Testing Latitude encoding
  List<double> latTests = [-90, -89, -45, -1, 0, -0, 1, 45, 89, 90];
  List<List<int>> latResult = [
    [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0] ,
    [1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
    [1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
    [1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ,
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] ,
    [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0] ,
    [0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1] ,
    [0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0] ,
    [0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0]
  ];

  _LatitudeEncoder latEncoder = new _LatitudeEncoder();
  // causal cases
  for(int i = 0; i < latTests.length; i++){
    assert(eq(latEncoder.encode(latTests[i]), latResult[i]),
    latTests[i].toString() + ' is wrong.\nGiven:\t'
        + latResult[i].toString() + '\nGet:\t'
        + latEncoder.encode(latTests[i]).toString());
  }

  // error cases
  try{
    latEncoder.encode(-90.1);
    throw Exception();
  }on FormatException{
  }catch(e){throw Exception("-90.1, caught unexpected exception.");}

  try{
    latEncoder.encode(90.1);
    throw Exception();
  }on FormatException{
  }catch(e){throw Exception("90.1, caught unexpected exception.");}
  print('Latitude encoding passed!');

  // =========================
  // Testing DateTimeEncoder
  _DatetimeEncoder timeEncoder = new _DatetimeEncoder();
  List<String> datetimeTests = ['2020-09-23 14:39:30.504677', '2999-12-31 23:59:59.504677','2000-1-1 0:00:00.504677'];
  List<List<int>> datetimeResult = [
    [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1] ,
    [1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1] ,
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  ];

  // causal cases
  for(int i = 0; i < datetimeTests.length; i++){
    assert(eq(timeEncoder.encode(datetimeTests[i]), datetimeResult[i]),
    datetimeTests[i].toString() + ' is wrong.\nGiven:\t'
        + datetimeResult[i].toString() + '\nGet:\t'
        + timeEncoder.encode(datetimeTests[i]).toString());
  }

  // error cases
  try{
    timeEncoder.encode('2020-09-23 14:60:30.504677');
    throw Exception('Should throw');
  }on FormatException{
  }catch(e){throw Exception("2020-09-23 14:60:30.504677, caught unexpected exception.");}

  try{
    timeEncoder.encode('2020-09-23 24:60:30.504677');
    throw Exception('Should throw');
  }on FormatException{
  }catch(e){throw Exception("2020-09-23 24:60:30.504677, caught unexpected exception.");}

  try{
    timeEncoder.encode('2020-09-23 -1:60:30.504677');
    throw Exception('Should throw');
  }on FormatException{
  }catch(e){throw Exception("2020-09-23 -1:60:30.504677, caught unexpected exception.");}

  try{
    timeEncoder.encode('2020-09-23 24:-1:30.504677');
    throw Exception('Should throw');
  }on FormatException{
  }catch(e){throw Exception("2020-09-23 24:-1:30.504677, caught unexpected exception.");}
  print('DateTime encoding passed!');

  LocationTimeEncoder locationTimeEncoder = new LocationTimeEncoder();
  List<int> encoded = locationTimeEncoder.encode('2020-09-23 14:39:30.504677', 89, 45);
  List<int> LocationTimeResult = [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1,
    0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0,
    0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1
  ];
  assert(eq(encoded, LocationTimeResult), "Wrong");
  print("LocationTimeEncoder passed!");
}