import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineData {
  List<LatLng> polylineCoordinates;
  Set<Polyline> polylineSet;
  Set<Marker> markers;
  Set<Circle> circles;
  var bounds;
  PolylineData(
      {this.polylineCoordinates = const [],
      this.polylineSet = const {},
      this.markers = const {},
      this.circles = const {},
      this.bounds});
}
