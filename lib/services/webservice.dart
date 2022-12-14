import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Resource<T> {
  dynamic url;
  dynamic parse;

  Resource({this.url, this.parse});
}

class Webservice {
  Future<T> load<T>(Resource<T> resource) async {
    final response = await http.get(Uri.parse(resource.url));
    if (response.statusCode == 200) {
      return resource.parse(response);
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
