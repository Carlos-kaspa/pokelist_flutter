import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/pokemon_list.dart';
import '../services/webservice.dart';

class PokemonListState extends State<PokemonListWidget> {
  PokemonList _pokemonList = PokemonList();
  final loading = ValueNotifier(true);
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
    loading.value = true;
    Webservice().load(PokemonList.all(url)).then((pokemonList) => {
          setState(() => {_pokemonList = pokemonList})
        });
    loading.value = false;
  }

  Container _buildItemsForListView(BuildContext context, int index) {
    return Container(
      color: Colors.blueGrey[100],
      child: Padding(
          padding: EdgeInsets.all(5),
          child: ListTile(title: Text(_pokemonList.list[index].name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pokemon'),
        ),
        body: Stack(
          children: [
            ValueListenableBuilder(
                valueListenable: ValueNotifier(_pokemonList.list != null),
                builder: (context, bool isLoading, _) {
                  return (isLoading)
                      ? ListView.builder(
                          itemCount: _pokemonList.list.length,
                          controller: _controller,
                          itemBuilder: _buildItemsForListView,
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                }),
            ValueListenableBuilder(
              valueListenable: loading,
              builder: (context, bool isLoading, _) {
                return (isLoading)
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Container();
              },
            )
          ],
        ));
  }

  void _scrollListener() {
    log(' current pos: ${_controller.position.maxScrollExtent}');
    log('list size: ${_pokemonList.list.length}');
    if (_controller.position.extentAfter < 200 && !loading.value) {
      loading.value = true;
      Webservice()
          .load(PokemonList.all(_pokemonList.next))
          .then((pokemonList) => {
                setState(() => {
                      _pokemonList.next = pokemonList.next,
                      _pokemonList.previous = pokemonList.previous,
                      _pokemonList.list = _pokemonList.list + pokemonList.list
                    })
              });
      loading.value = false;
    }
  }
}

class PokemonListWidget extends StatefulWidget {
  @override
  createState() => PokemonListState();
}
