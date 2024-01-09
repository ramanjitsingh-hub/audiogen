import 'package:audiogen/channelselector.provider.dart';
import 'package:audiogen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ToneGen>(
      create: (context) => ToneGen(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surround Sound Demo',
      home: HomePage(),
    );
  }
}
