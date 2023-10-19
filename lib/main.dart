import 'package:flutter/material.dart';
import 'package:flutter_movie_app/home.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/',
  routes: {
    '/': (context) => Home(),
  },
));
