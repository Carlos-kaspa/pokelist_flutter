import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/pokemon_list.dart';
import '../services/webservice.dart';

class PokemonListState extends State<PokemonListWidget> {
  PokemonList _pokemonList = PokemonList();
  late ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _populatePokemonList(null);
    _controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);

    super.dispose();
  }

  void _populatePokemonList(url) {
    Webservice().load(PokemonList.all(url)).then((pokemonList) => {
          setState(() => {_pokemonList = pokemonList})
        });
  }

  ListTile _buildItemsForListView(BuildContext context, int index) {
    return ListTile(title: Text(_pokemonList.list[index].name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pokemon'),
        ),
        body: _pokemonList.list == null
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: _pokemonList.list.length,
                controller: _controller,
                itemBuilder: _buildItemsForListView,
              ));
  }

  void _scrollListener() {
    log(' current pos: ${_controller.position.extentAfter}');
    log('list size: ${_pokemonList.list.length}');
    if (_controller.position.extentAfter < 40) {
      Webservice()
          .load(PokemonList.all(_pokemonList.next))
          .then((pokemonList) => {
                setState(() => {
                      _pokemonList.next = pokemonList.next,
                      _pokemonList.previous = pokemonList.previous,
                      _pokemonList.list = _pokemonList.list + pokemonList.list
                    })
              });
    }
  }
}

class PokemonListWidget extends StatefulWidget {
  @override
  createState() => PokemonListState();
}
