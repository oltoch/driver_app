import 'package:driver_app/DataHandler/address_data.dart';
import 'package:driver_app/DataHandler/all_users.dart';
import 'package:driver_app/DataHandler/app_data.dart';
import 'package:driver_app/DataHandler/direction_details_data.dart';
import 'package:driver_app/DataHandler/place_prediction_data.dart';
import 'package:driver_app/DataHandler/polyline_data.dart';
import 'package:driver_app/Services/networking.dart';
import 'package:driver_app/Widgets/progress_dialog.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/map_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class GeocodingModel {
  static List<PlacePrediction> list = [];
  static LatLng latLng = LatLng(37.42796133580664, -122.085749655962);

  //Function to get address of user from coordinate derived from position,
  //that is, latitude and longitude of the user's device. The function take the
  //address and update userAddress in the AppData using provider package.
  static Future<void> getAddressFromCoordinate(
      Position position, context) async {
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    var response = await NetworkHelper(url: url).getData();

    String address = '';
    AddressData addressData = AddressData();
    if (response != 'failed') {
      address = response['results'][1]['formatted_address'];

      addressData.placeFormattedAddress = address;
      addressData.placeName = response['results'][0]['formatted_address'];
      addressData.placeId = response['results'][1]['place_id'];
      addressData.latLng = LatLng(position.latitude, position.longitude);

      Provider.of<AppData>(context, listen: false).updateAddress(addressData);
    } else {
      Provider.of<AppData>(context, listen: false).updateAddress(addressData);
    }
  }

  //Function to get details of destination address which the user select as the
  //drop off location from the list tiles.
  static void getPlaceAddressDetails(
      String placeId, BuildContext context) async {
    //String url = 'https://maps.googleapis.com/maps/api/place/details/json?fields=name%2Crating%2Cformatted_phone_number&place_id=ChIJN1t_tDeuEmsRUsoyG83frY4&key=YOUR_API_KEY';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: 'Setting destination, please wait...',
          );
        },
        barrierDismissible: false);

    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
    var response = await NetworkHelper(url: placeDetailsUrl).getData();
    Navigator.pop(context);
    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      AddressData data = AddressData();
      data.placeName = response['result']['name'];
      data.placeId = placeId;
      data.latLng = LatLng(response['result']['geometry']['location']['lat'],
          response['result']['geometry']['location']['lng']);

      Provider.of<AppData>(context, listen: false).updateDropOffAddress(data);
      Navigator.pop(context, 'yes');
    }
  }

  //Function to predict user destination based off the entry in the text field.
  //The function attempts to auto complete the user's entry based off the letters
  //already typed in.
  static void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&sessiontoken=123456789&key=$mapKey&types=address&radius=50000&components=country:ng';

      var response = await NetworkHelper(url: autoCompleteUrl).getData();
      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictions = response['predictions'];
        var placeList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();
        list = placeList;
      }
    }
  }

  //Function to get direction details. It takes current position and destination
  // user selects as the inputs.
  static Future<void> getDirectionDetails(BuildContext context,
      LatLng initialPosition, LatLng finalPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey';
    // String url1 =
    //     'https://maps.googleapis.com/maps/api/directions/json?origin=7.3381088,3.9505875&destination=7.435867200000001,3.919291&key=AIzaSyA9T8yUDP2hyQhuEAsJI96gRYnJh-xVKwA';

    var response = await NetworkHelper(url: url).getData();
    DirectionDetailsData detailsData = DirectionDetailsData();
    if (response['status'] == 'OK') {
      detailsData.encodedPoints =
          response['routes'][0]['overview_polyline']['points'];
      detailsData.distanceText =
          response['routes'][0]['legs'][0]['distance']['text'];
      detailsData.distanceValue =
          response['routes'][0]['legs'][0]['distance']['value'];
      detailsData.durationText =
          response['routes'][0]['legs'][0]['duration']['text'];
      detailsData.durationValue =
          response['routes'][0]['legs'][0]['duration']['value'];

      Provider.of<AppData>(context, listen: false)
          .updateDirectionDetails(detailsData);
    } else {
      Provider.of<AppData>(context, listen: false)
          .updateDirectionDetails(detailsData);
    }
  }

  static Future<void> getDirection(BuildContext context) async {
    var initialPosition =
        Provider.of<AppData>(context, listen: false).addressData;
    var finalPosition =
        Provider.of<AppData>(context, listen: false).dropOffAddress;

    var pickUpLatLng = initialPosition.latLng;
    var destinationLatLng = finalPosition.latLng;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProgressDialog(
          message: 'Please wait...',
        );
      },
    );

    await getDirectionDetails(context, pickUpLatLng, destinationLatLng);

    Navigator.pop(context);
  }

  static void drawPolyLine(BuildContext context) {
    List<LatLng> polylineCoordinates = [];
    Set<Polyline> polylineSet = {};

    var details =
        Provider.of<AppData>(context, listen: false).directionDetailsData;

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    polylineCoordinates.clear();

    if (decodedPolylinePointsResult.isNotEmpty) {
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();

    //wrap in a setState
    Polyline polyline = Polyline(
        polylineId: PolylineId('PolylineID'),
        color: Colors.blueAccent,
        jointType: JointType.round,
        points: polylineCoordinates,
        width: 5,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap);
    polylineSet.add(polyline);

    LatLngBounds bounds;
    var pickUpLatLng =
        Provider.of<AppData>(context, listen: false).addressData.latLng;
    var destinationLatLng =
        Provider.of<AppData>(context, listen: false).dropOffAddress.latLng;

    if (pickUpLatLng.latitude > destinationLatLng.latitude &&
        pickUpLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickUpLatLng.longitude),
          northeast:
              LatLng(pickUpLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: destinationLatLng);
    }

    Marker pickUpMarker = Marker(
        markerId: MarkerId('pickUpID'),
        position: pickUpLatLng,
        infoWindow: InfoWindow(
            title: Provider.of<AppData>(context, listen: false)
                .addressData
                .placeFormattedAddress,
            snippet: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

    Marker destinationMarker = Marker(
        markerId: MarkerId('destinationID'),
        position: destinationLatLng,
        infoWindow: InfoWindow(
            title: Provider.of<AppData>(context, listen: false)
                .dropOffAddress
                .placeName,
            snippet: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

    Set<Marker> markers = {};
    markers.add(pickUpMarker);
    markers.add(destinationMarker);

    Circle pickUpCircle = Circle(
        circleId: CircleId('pickUpID'),
        fillColor: Colors.deepOrange,
        radius: 12,
        center: pickUpLatLng,
        strokeColor: Colors.deepOrangeAccent,
        strokeWidth: 4);

    Circle destinationCircle = Circle(
        circleId: CircleId('destinationID'),
        fillColor: Colors.deepPurple,
        radius: 12,
        center: destinationLatLng,
        strokeColor: Colors.deepPurpleAccent,
        strokeWidth: 4);

    Set<Circle> circles = {};
    circles.add(pickUpCircle);
    circles.add(destinationCircle);

    PolylineData data = PolylineData(
        polylineCoordinates: polylineCoordinates,
        polylineSet: polylineSet,
        markers: markers,
        circles: circles,
        bounds: bounds);
    Provider.of<AppData>(context, listen: false).updatePolylineData(data);
  }

  static int calculateFare(BuildContext context) {
    double timeTraveledFare =
        Provider.of<AppData>(context).directionDetailsData.durationValue /
            60 *
            0.2;
    double distanceTraveledFare =
        Provider.of<AppData>(context).directionDetailsData.distanceValue /
            1000 *
            0.2;
    return (timeTraveledFare + distanceTraveledFare).toInt();
  }

  static void getCurrentOnlineUserInfo(BuildContext context) {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userID = firebaseUser!.uid;
    try {
      DatabaseReference reference =
          FirebaseDatabase.instance.reference().child('users').child(userID);

      reference.once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          // currentUsers = Users.fromSnapshot(snapshot);
          Provider.of<AppData>(context, listen: false)
              .usersFromSnapshot(snapshot);
        }
      });
    } catch (e) {
      EasyLoading.showError('Error occurred');
    }
  }

  static DatabaseReference? reference;

  static void saveRideRequest(BuildContext context) async {
    String path = 'ride_requests';
    reference = FirebaseDatabase.instance.reference().child(path).push();
    AddressData pickUp =
        Provider.of<AppData>(context, listen: false).addressData;
    AddressData destination =
        Provider.of<AppData>(context, listen: false).dropOffAddress;

    Map pickUpLocationMap = {
      'latitude': pickUp.latLng.latitude.toString(),
      'longitude': pickUp.latLng.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latLng.latitude.toString(),
      'longitude': destination.latLng.longitude.toString(),
    };
    Users users = Provider.of<AppData>(context, listen: false).users;
    Map rideInfoMap = {
      'driver_id': 'waiting',
      'payment_method': 'cash',
      'pick_up_location': pickUpLocationMap,
      'destination': destinationMap,
      'created_at': DateTime.now().toString(),
      //rider represent passenger
      'rider_name': users.name,
      'rider_phone': users.phone,
      'pick_up_address': pickUp.placeFormattedAddress,
      'destination_address': destination.placeName,
    };
    await reference!.set(rideInfoMap);
  }

  static void cancelRideRequest() async {
    await reference!.remove();
  }

  static void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    Geofire.initialize('AvailableDrivers');
    Geofire.setLocation(
        currentFirebaseUser!.uid, position.latitude, position.longitude);
    rideRequestRef.onValue.listen((event) {});
  }

  static void getLocationLiveUpdates(bool condition) {
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      if (condition) {
        Geofire.setLocation(
            currentFirebaseUser!.uid, position.latitude, position.longitude);
      }
      Geofire.setLocation(
          currentFirebaseUser!.uid, position.latitude, position.longitude);

      latLng = LatLng(position.latitude, position.longitude);
    });
  }

  static void makeDriverOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
  }
}
