import 'package:background_location/background_location.dart';
import 'package:latlong/latlong.dart';

/// Class that updates and stores geolocation information
class BackgroundLocationManager{
  /// Properties and compound properties
  double _longitude;
  double _latitude;
  final Distance distance = new Distance();

  // A list of double representing the location is form of [longitude and latitude]
  List<double> get lastKnownLocation{
    return [this._longitude, this._latitude];
  }

  // Constructor. Starting the location service.
  BackgroundLocationManager(){
    print("Initializing BackgroundLocation Manager");

    _longitude = 0;
    _latitude = 0;
    BackgroundLocation.startLocationService();
  }


  void onUpdate(Function callback) {
    BackgroundLocation.getLocationUpdates(
            (location){
              // update internal longitude and latitude
              double delta = this.distance(
                new LatLng(this._latitude, this._longitude),
                new LatLng(location.latitude, location.longitude)
              );
              print('$delta');
              if(delta > 5){
                this._longitude = location.longitude;
                this._latitude = location.latitude;

                // call the callback
                callback(location);
              }



            });
  }



}