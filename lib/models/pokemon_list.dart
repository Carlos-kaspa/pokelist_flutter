import 'dart:convert';
import 'dart:developer';

import '../services/webservice.dart';
import '../utils/constants.dart';

class PokemonList {
  dynamic next;
  dynamic previous;
  dynamic list;

  PokemonList({this.next, this.previous, this.list});

  factory PokemonList.fromJson(Map<String, dynamic> json) {
    Iterable list = json['results'];
    return PokemonList(
        next: json['next'],
        previous: json['previous'],
        list: list.map((model) => PokemonData.fromJson(model)).toList());
  }

  static Resource<PokemonList> all(url) {
    String path =
        url ?? '${Constants.POKE_API_BASE_URL}/${Constants.POKE_API_PATH}';
    return Resource(
        url: path,
        parse: (response) {
          final result = json.decode(response.body);
          return PokemonList.fromJson(result);
        });
  }
}

class PokemonData {
  dynamic name;
  dynamic url;

  PokemonData({this.name, this.url});

  factory PokemonData.fromJson(Map<String, dynamic> json) {
    return PokemonData(
      name: json['name'],
      url: json['url'],
    );
  }
}
