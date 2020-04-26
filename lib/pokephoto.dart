import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:testing/main.dart';
import 'package:testing/pokemon.dart';
import 'package:testing/previa.dart';
import 'package:testing/tipo.dart';
import 'package:testing/tipo.dart';
import 'pokemon.dart';

class PokeError extends StatelessWidget {
  String error;

  PokeError({this.error});

  bodyWidget(BuildContext context) => Container(
    margin: EdgeInsets.all(MediaQuery.of(context).size.width/6),
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "-Error-",
            style: TextStyle(color: Colors.black87, fontSize: 80, fontWeight: FontWeight.bold),
          ),
          Text(
            error,
            style: TextStyle(color: Colors.black87, fontSize: 20, fontStyle: FontStyle.italic),
          )
        ],
      )
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87,
        title: Text("Error"),
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pop(
                context, MaterialPageRoute(builder: (context) => homePage()));
          },
        ),
      ),
      body: bodyWidget(context),
    );
  }
}
