import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:testing/pokedetail.dart';
import 'package:testing/pokemon.dart';
import 'dart:convert';
import 'package:splashscreen/splashscreen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:testing/pokephoto.dart';
import 'package:tflite/tflite.dart';


void main() =>
    runApp(MaterialApp(
      navigatorKey: nav,
      title: "Pokemon App",
      home: new MyApp(),
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Carter'),
      debugShowCheckedModeBanner: false,
    ));

final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      title: new Text(
        'Welcome',
        style: new TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
      ),
      photoSize: 120.0,
      seconds: 6,
      backgroundColor: Colors.black,
      image: Image.network(
        "http://pngimg.com/uploads/pokeball/pokeball_PNG7.png",
      ),
      navigateAfterSeconds: new AfterSplash(),
    );
  }
}

class AfterSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Carter'),
      home: homePage(),
    );
  }
}

class homePage extends StatefulWidget {
  @override
  _myHomePageState createState() => _myHomePageState();
}

class _myHomePageState extends State<homePage> {
  var url =
      "https://raw.githubusercontent.com/Adrian-Cruz-SanJuan/pokedex_yuko/master/pokemones.json";
  PokeHub pokeHub;

  StreamSubscription connectivitySubscription;
  ConnectivityResult _previousResult;

  bool _isLoading;
  File _image;
  List _output;

  @override
  void initState() {
    super.initState();
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        SystemNavigator.pop();
      } else if (_previousResult == ConnectivityResult.none) {
        nav.currentState
            .push(MaterialPageRoute(builder: (BuildContext _) => homePage()));
      }
      _previousResult = connectivityResult;
    });
    fetchData();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void dispose() {
    super.dispose();

    connectivitySubscription.cancel();
  }

  void fetchData() async {
    var res = await http.get(url);
    var decodedValue = jsonDecode(res.body);
    pokeHub = PokeHub.fromJson(decodedValue);
    setState(() {});
  }

  /*Control de Busqueda*/
  final TextEditingController _search = new TextEditingController();
  bool _typing = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _typing
            ? TextField(
          autofocus: true,
          controller: _search,
          onChanged: (text) {
            setState(() {});
          },
        )
            : Text("Pokemon"),
        leading: IconButton(
          icon: Icon(_typing ? Icons.done : Icons.search),
          onPressed: () {
            print("Is typing: " + _typing.toString());
            setState(() {
              _typing = !_typing;
              _search.text = "";
            });
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
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
            ((poke.name
                .toLowerCase()
                .contains(_search.text.toLowerCase())) ||
                poke.type
                    .toList()
                    .toList()
                    .toString()
                    .toLowerCase()
                    .contains(_search.text.toLowerCase()) ||
                poke.num.toString().contains(_search.text)))
                .map((Pokemon poke) =>
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PokeDetail(
                                    pokemon: poke,
                                  )));
                    },
                    child: Card(
                      elevation: 3.0,
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
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
          );
        },
      ),
      floatingActionButton: SpeedDial(
          backgroundColor: Colors.green[800],
          animatedIconTheme: IconThemeData(color: Colors.black),
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
                backgroundColor: Colors.green[800],
                child: Icon(
                  Icons.image,
                  color: Colors.black,
                ),
                label: "Gallery",
                labelStyle: TextStyle(color: Colors.black),
                onTap: () {
                  chooseImageGallery();
                }),
            SpeedDialChild(
                backgroundColor: Colors.green[800],
                child: Icon(Icons.camera, color: Colors.black),
                label: "Camera",
                labelStyle: TextStyle(color: Colors.black),
                onTap: () {
                  chooseImageCamera();
                })
          ]),
      endDrawer: Drawer(
        elevation: 16.0,
        child: ListView(
          children: const <Widget>[
            DrawerHeader(
              child: Text("Pokemon App",
                  style: TextStyle(fontFamily: 'Carter', fontSize: 30)),
              decoration: BoxDecoration(color: Colors.black),
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
                )),
            ListTile(
                title: Text(
                  "Meneses Alegria Diana Marlen",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
            ListTile(
                title: Text(
                  "Hernandez Oliveira Luis",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ))
          ],
        ),
      ),
    );
  }

  await(Future<ConnectivityResult> checkConnectivity) {}

  chooseImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = image;
    });
    runModelOnImage(image);
  }

  chooseImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = image;
    });
    runModelOnImage(image);
  }

  runModelOnImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 10,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5);
    setState(() {
      _isLoading = false;
      _output = output;

      if (_output.isEmpty) {
        String e="NO hay pokemon";
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => PokeError(error: e,)));
      }else {
        print(_output[0]["label"]);
        print(_output[0]["confidence"]);
        String pok = (_output[0]["label"]).toString();
        double con = (_output[0]["confidence"]);
        int a = pok.length;
        String b = pok.substring(2, a);
        print(b);
        if( con > 0.90) {
          print(
              pokeHub.pokemon.where((poke) => poke.num.contains(b)).map((
                  poke) =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PokeDetail(pokemon: poke)))));
        }else{
          String e="Pokemon no reconocido";
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => PokeError(error: e,)));
        }
      }
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }
}

