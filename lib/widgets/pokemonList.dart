import 'package:flutter/material.dart';
import '../models/pokemon_list.dart';
import '../services/webservice.dart';

class PokemonListState extends State<PokemonListWidget> {
  PokemonList _pokemonList = PokemonList();
  final _loading = ValueNotifier(true);
  late ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _getPokemon(null);
    _controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    super.dispose();
  }

  Future<PokemonList> _callPokeApi(url) async {
    PokemonList pokemonList = await Webservice().load(PokemonList.all(url));
    return pokemonList;
  }

  void _getPokemon(url) async {
    PokemonList response = await _callPokeApi(url);
    setState(() => {_pokemonList = response});
    _loading.value = false;
  }

  void _getMorePokemon(url) async {
    _loading.value = true;
    PokemonList response = await _callPokeApi(url);
    setState(() => {
          _pokemonList.next = response.next,
          _pokemonList.previous = response.previous,
          _pokemonList.list = _pokemonList.list + response.list
        });
    _loading.value = false;
  }

  Container _buildItemsForListView(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.all(5),
      color: Colors.blueGrey[100],
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: ListTile(
            title: Text(
              _pokemonList.list[index].name.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black45,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned customLoader() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - 20,
      bottom: 24,
      child: Center(
        child: CircleAvatar(
          backgroundColor: Colors.grey[700],
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.grey[200],
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Infinite Pokemon Scroll'),
        ),
        body: Stack(
          children: [
            ValueListenableBuilder(
                valueListenable: ValueNotifier(_pokemonList.list != null),
                builder: (context, bool isLoading, _) {
                  return (isLoading)
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
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
              valueListenable: _loading,
              builder: (context, bool isLoading, _) {
                return (isLoading) ? customLoader() : Container();
              },
            )
          ],
        ));
  }

  void _scrollListener() {
    if (_controller.position.extentAfter < 200 && !_loading.value) {
      _getMorePokemon(_pokemonList.next);
    }
  }
}

class PokemonListWidget extends StatefulWidget {
  const PokemonListWidget({super.key});

  @override
  createState() => PokemonListState();
}
