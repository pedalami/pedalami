import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class MongoDB {
  //Backend developers make the functions for the mongo api calls here,
  //Frontend developers can then use these functions in the flutter project

  static final MongoDB instance = new MongoDB();

  @protected
  http.Client serverClient = http.Client();

  @protected
  Map<String, String> headers = {
    'Content-type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  Future<bool> initUser(String uid) async {
    var url = Uri.parse('https://pedalami.herokuapp.com/users/create');
    var response = await serverClient.post(url, headers: headers, body: json.encode({'uid': uid}));
    return response.statusCode == 200 ? true : false;
  }
}
