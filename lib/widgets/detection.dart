import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';

class Application extends StatefulWidget {
  @override
  ApplicationState createState() => ApplicationState();
}

class ApplicationState extends State<Application> {
  double? frequency;
  Color messageBoxColor = Colors.red; // Initialize message box color

  FlutterFft flutterFft = new FlutterFft();

  bool? isRecording;
  _initialize() async {
    print("Starting recorder...");
    print("Before");
    bool hasPermission = await flutterFft.checkPermission();
    print("After: " + hasPermission.toString());

    // Keep asking for mic permission until accepted
    while (!(await flutterFft.checkPermission())) {
      flutterFft.requestPermission();
      // IF DENY QUIT PROGRAM
    }

    // await flutterFft.checkPermissions();
    await flutterFft.startRecorder();
    print("Recorder started...");
    setState(() => isRecording = flutterFft.getIsRecording);

    flutterFft.onRecorderStateChanged.listen(
        (data) => {
              // ... (other data updates)
              frequency = data[1] as double,
              _updateMessageBoxColor(), // Call the color update function
              // ...
            },
        onError: (err) {
          print("Error: " + err);
        },
        onDone: () => {print("Isdone")});
  }

  void _updateMessageBoxColor() {
    if (frequency != null && frequency! >= 3900 && frequency! <= 4100) {
      setState(() => messageBoxColor = Colors.green);
    } else {
      setState(() => messageBoxColor = Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
