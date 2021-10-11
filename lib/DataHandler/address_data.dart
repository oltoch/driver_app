import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressData {
  String placeFormattedAddress, placeName, placeId;
  LatLng latLng;

  AddressData(
      {this.placeFormattedAddress = '',
      this.placeName = '',
      this.placeId = '',
      this.latLng = const LatLng(37.42796133580664, -122.085749655962)});
}
