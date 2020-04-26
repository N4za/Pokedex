import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:testing/pokedetail.dart';
import 'package:testing/pokemon.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(
  title: "Pokemon App",
  theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Carter'),
  debugShowCheckedModeBanner: false,
));
class MyApp extends StatelessWidget {
  MyApp({this.tipo});
  String tipo;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        home: ChipTipo(this.tipo)
    );
  }
}
class ChipTipo extends StatefulWidget {
  ChipTipo(this.tipo);
  String tipo;
//  final String tipo;

  //const Chip({Key key, this.tipo}) : super(key: key);

  @override
  _ChipTipo createState() => _ChipTipo(this.tipo);
}

class _ChipTipo extends State<ChipTipo> {
  _ChipTipo(this.tipo);
  String tipo;
  var url =
      "https://raw.githubusercontent.com/Adrian-Cruz-SanJuan/pokedex_yuko/master/pokemones.json";
  PokeHub pokeHub;
  //final data;

  //_Chip({this.data});



  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void dispose() {
    super.dispose();
  }

  void fetchData() async {
    var res = await http.get(url);
    var decodedValue = jsonDecode(res.body);
    pokeHub = PokeHub.fromJson(decodedValue);
    setState(() {});
  }

  /*Control de Busqueda*/
  String _searchText = "";
  final TextEditingController _search = new TextEditingController();
  Widget _appBarTitle = new Text("Pokemon");
  bool _typing = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _typing ? TextField(
          autofocus: true,
          controller: _search,
          onChanged: (text){
            setState(() {});
          },
        ):Text("Pokemon"),
        leading: IconButton(
          icon: Icon(_typing ? Icons.done: Icons.search),
          onPressed: () {
            print("Is typing: "+ _typing.toString());
            setState(() {
              _typing = !_typing;
              _search.text = "";
            });
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: pokeHub == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : OrientationBuilder(
        builder: (context, orientation) {
          return GridView.count(
            crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            children: pokeHub.pokemon
                .where((poke) =>
            (poke.type.toList().toList().toString()
                .toLowerCase()
                .contains(this.tipo.toLowerCase())
            ))
                .map((Pokemon poke) =>
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PokeDetail(
                                pokemon: poke,
                              )));
                    },
                    child: Card(
                      elevation: 3.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Hero(
                            tag: poke.img,
                            child: Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(poke.img)),
                              ),
                            ),
                          ),
                          Text(
                            poke.name,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ))
                .toList(),
          );},),
      endDrawer: Drawer(
        elevation: 16.0,
        child: ListView(
          children: const <Widget>[
            DrawerHeader(
              child: Text("Pokemon App",
                  style: TextStyle(fontFamily: 'Carter', fontSize: 30)),
              decoration: BoxDecoration(color: Colors.greenAccent),
            ),
            ListTile(
              title: Text(
                "Romero Sosa Emma Yuridia",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            ListTile(
                title: Text(
                  "Rodriguez Velasco Eliazar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
            ListTile(
                title: Text(
                  "Leon Barron Adolfo",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
            ListTile(
                title: Text(
                  "Cruz San Juan Adrian",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
            ListTile(
                title: Text(
                  "Muñoz Ruíz Nazareth",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ))
          ],
        ),
      ),
    );
  }
}
