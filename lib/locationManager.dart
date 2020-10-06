import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationManager{
  StreamSubscription<Position> positionStream;


  void assignCallback(Function callback){
    print("assigning call back");
    positionStream = getPositionStream().listen(
            (Position position){callback(position);}
    );
  }


}