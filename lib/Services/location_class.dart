import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetLocation {
  static LatLng latLng = LatLng(37.42796133580664, -122.085749655962);
  static late Position position; //Potential issue with position not getting
  // initialized if the getCurrentLocation() method fails.

  static Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Services services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      latLng = LatLng(37.42796133580664, -122.085749655962);
      Geolocator.openAppSettings();
      return Future.error('Services services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        EasyLoading.showError('App requires location permission to be granted',
            dismissOnTap: true, duration: Duration(seconds: 5));
        return Future.error('Services permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Services permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position1 = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      position = position1;
      latLng = LatLng(position1.latitude, position1.longitude);
    } catch (e) {
      print(e);
      EasyLoading.showError(
          'Unable to get your location, please try again! ' + e.toString());
      latLng = LatLng(37.42796133580664, -122.085749655962);
    }
  }
}
