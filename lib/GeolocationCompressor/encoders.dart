/// Abstract class for encoders
abstract class _BaseEncoder{
  List<int> encode(double value);

  /// Convert decimal integer to binary format as list of integer
  ///
  /// arguments:
  ///   - value, int
  /// return:
  ///   - List<int>
  /// throw:
  ///   - Exception
  List<int> decimalToBinaryList(int value){
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
}
/// Encoder that encodes the latitude information
class _LatitudeEncoder extends _BaseEncoder{
  @override
  List<int> encode(double value){

  }
}

/// Encoder that encodes the longitude information
class _LongitudeEncoder extends _BaseEncoder{
  @override
  List<int> encode(double value){

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
  _DatetimeEncoder datetimeEncoder = new _DatetimeEncoder();
  print(datetimeEncoder.decimalToBinaryList(123));
}