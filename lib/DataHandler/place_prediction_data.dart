class PlacePrediction {
  late String mainText, secondaryText, placeId;

  PlacePrediction(
      {this.mainText = '', this.secondaryText = '', this.placeId = ''});

  PlacePrediction.fromJson(Map<String, dynamic> json) {
    mainText = json['structured_formatting']['main_text'];
    secondaryText = json['structured_formatting']['secondary_text'];
    placeId = json['place_id'];
  }
}
