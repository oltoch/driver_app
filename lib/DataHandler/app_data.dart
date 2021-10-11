import 'package:driver_app/DataHandler/address_data.dart';
import 'package:driver_app/DataHandler/all_users.dart';
import 'package:driver_app/DataHandler/direction_details_data.dart';
import 'package:driver_app/DataHandler/polyline_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  AddressData addressData = AddressData();
  AddressData dropOffAddress = AddressData();
  DirectionDetailsData directionDetailsData = DirectionDetailsData();
  PolylineData polylineData = PolylineData();
  Users users = Users();

  void updateAddress(AddressData userAddressData) {
    addressData = userAddressData;
    notifyListeners();
  }

  void updateDropOffAddress(AddressData dropOffData) {
    dropOffAddress = dropOffData;
    notifyListeners();
  }

  void updateDirectionDetails(DirectionDetailsData directionDetails) {
    directionDetailsData = directionDetails;
    notifyListeners();
  }

  void updatePolylineData(PolylineData data) {
    polylineData = data;
    notifyListeners();
  }

  void usersFromSnapshot(DataSnapshot snapshot) {
    users.id = snapshot.key!;
    users.email = snapshot.value['email'];
    users.name = snapshot.value['name'];
    users.phone = snapshot.value['phone'];
    notifyListeners();
  }
}
