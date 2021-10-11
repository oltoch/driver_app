import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class NetworkHelper {
  NetworkHelper({required this.url});

  final String url;

  Future<dynamic> getData() async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String data = response.body;

        return jsonDecode(data);
      } else {
        EasyLoading.showError(
            "Failed. Error code: " + response.statusCode.toString());
        print(response.statusCode);
        return 'failed';
      }
    } catch (e) {
      print(e.toString());
      return 'failed';
    }
  }
}
