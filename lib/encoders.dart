abstract class BaseEncoder{
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
    String binaryRepr = value.toRadixString(2);
    List<int> result = [];
    for(var bit in binaryRepr.split('')){
      result.add(int.parse(bit));
    }
    return result;
  }
}

class LatitudeEncoder extends BaseEncoder{
  @override
  List<int> encode(double value){

  }
}

class LongitudeEncoder extends BaseEncoder{
  @override
  List<int> encode(double value){

  }
}

class DatetimeEncoder extends BaseEncoder{
  @override
  List<int> encode(double value){

  }
}

class LocationTimeEncoder{
  final LongitudeEncoder _longitudeEncoder = new LongitudeEncoder();
  final LatitudeEncoder _latitudeEncoder = new LatitudeEncoder();
  final DatetimeEncoder _datetimeEncoder = new DatetimeEncoder();


}

void main(){
  DatetimeEncoder datetimeEncoder = new DatetimeEncoder();
}