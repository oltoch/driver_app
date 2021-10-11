import 'dart:async';

import 'package:driver_app/Services/geocodingModel.dart';
import 'package:driver_app/Services/location_class.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/map_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  static final _kGoogleCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  static final _kUserCameraPosition = CameraPosition(
    target: GetLocation.latLng,
    zoom: 14.4746,
  );

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  LatLng _kGoogleLatLng = LatLng(37.42796133580664, -122.085749655962);

  LatLng _kUserLatLng = GetLocation.latLng;

  final Completer<GoogleMapController> _googleMapController = Completer();

  GoogleMapController? newGoogleMapController;

  String driverStatusText = 'Offline Now - Go Online  ';
  Color driverStatusColor = Colors.red;
  bool isDriverAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          //zoomControlsEnabled: true,
          //zoomGesturesEnabled: true,
          compassEnabled: true,
          // markers: Provider.of<AppData>(context, listen: false)
          //     .polylineData
          //     .markers,
          // circles: Provider.of<AppData>(context, listen: false)
          //     .polylineData
          //     .circles,
          mapToolbarEnabled: true,
          // polylines: Provider.of<AppData>(context, listen: false)
          //     .polylineData
          //     .polylineSet,
          initialCameraPosition: _kUserLatLng != _kGoogleLatLng
              ? HomeTab._kUserCameraPosition
              : HomeTab._kGoogleCameraPosition,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _googleMapController.complete(controller);
            newGoogleMapController = controller;
            setState(() {
              newGoogleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: GetLocation.latLng,
                    zoom: 14,
                  ),
                ),
              );
            });
          },
        ),
        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,
        ),
        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!isDriverAvailable) {
                      makeDriverOnlineNow();
                      getLocationLiveUpdates();
                      setState(() {
                        // if (GeocodingModel.latLng != _kGoogleLatLng) {
                        //   newGoogleMapController!.animateCamera(
                        //     CameraUpdate.newLatLng(GeocodingModel.latLng),
                        //   );
                        // }
                        driverStatusText = 'Online Now   ';
                        isDriverAvailable = true;
                        driverStatusColor = Colors.green;
                      });
                      EasyLoading.showSuccess('You are online now');
                    } else {
                      GeocodingModel.makeDriverOfflineNow();
                      setState(() {
                        driverStatusText = 'Offline Now - Go Online  ';
                        isDriverAvailable = false;
                        driverStatusColor = Colors.red;
                      });
                      EasyLoading.showSuccess('You are offline now');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(driverStatusColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          driverStatusText,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1),
                        ),
                        Icon(
                          Icons.phone_android_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await Geofire.initialize('AvailableDrivers');
    await Geofire.setLocation(
        currentFirebaseUser!.uid, position.latitude, position.longitude);
    rideRequestRef.onValue.listen((event) {});
  }

  void getLocationLiveUpdates() async {
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) async {
      if (isDriverAvailable) {
        await Geofire.setLocation(
            currentFirebaseUser!.uid, position.latitude, position.longitude);
      }

      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

//Use Geofire.stopListeners() method to stop Geofire from listening on location
//and creating new node in database.
  void makeDriverOfflineNow() async {
    await Geofire.removeLocation(currentFirebaseUser!.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
  }
}
