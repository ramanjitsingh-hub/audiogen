import 'dart:async';

import 'package:audiogen/widgets/circularradio.dart';
import 'package:audiogen/widgets/playbutton.dart';
import 'package:awesome_number_picker/awesome_number_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surround_sound/surround_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import 'channelselector.provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = SoundController();

  var isPlaying = false;

  bool playit = true;

  double? frequency;
  Color messageBoxColor = Colors.red; // Initialize message box color

  bool isDetecting = false;
  Color buttonColor = Colors.blue;

  FlutterFft flutterFft = FlutterFft();

  final double _minFrequency = 3900;
  final double _maxFrequency = 4100;

  Future<void> requestAudioPermission() async {
    final status = await Permission.microphone.request();

    if (status == PermissionStatus.granted) {
      print('Microphone permission granted.');
    } else if (status == PermissionStatus.denied) {
      print('Microphone permission denied.');
      // Consider displaying a message to the user explaining the need for permission
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Microphone permission permanently denied.');
      // Guide the user to app settings to enable permission
    }
  }

  void _startDetection() async {
    try {
      await requestAudioPermission();

      await flutterFft.startRecorder();
      setState(() {
        isDetecting = true;
        print("$isDetecting");
        buttonColor = Colors.red;
      });
    } catch (error) {
      print("Error starting detection: ${error.toString()}");
    }
  }

  void _stopDetection() async {
    await flutterFft.stopRecorder();
    setState(() {
      isDetecting = false;
      buttonColor = Colors.blue;
    });
  }

  void _updateMessageBoxColor() {
    if (frequency != null &&
        frequency! >= _minFrequency &&
        frequency! <= _maxFrequency) {
      setState(() => messageBoxColor = Colors.green);
    } else {
      setState(() => messageBoxColor = Colors.red);
    }
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() async {
    // Request audio permission
    await requestAudioPermission();

    // Initialize the recorder
    try {
      await flutterFft.startRecorder();
      print("Recorder started successfully.");
    } catch (error) {
      print("Error starting recorder: ${error.toString()}");
      // Handle the error appropriately, potentially informing the user
    }

    // Set up the listener for recorder state changes
    flutterFft.onRecorderStateChanged.listen(
      (data) {
        // Extract frequency data
        frequency = data[1] as double;

        // Update message box color based on frequency range
        _updateMessageBoxColor();
      },
      onError: (err) {
        print("Error: $err");
        // Handle errors as needed
      },
      onDone: () => print("Recorder stopped"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toneGen = context.read<ToneGen>();

    var burstDuration = context.watch<ToneGen>().burstdurations;
    final selectedChannel = toneGen.selectedChannel;
    _controller.setFrequency(5000); // Set frequency
    _controller.setPosition(
      // Set position based on selected channel (adjust logic as needed)
      selectedChannel == 0
          ? 0.2
          : selectedChannel == 1
              ? -0.2
              : 0,
      0,
      0,
    );

    return Scaffold(
      backgroundColor: Color(0xffFFD1E3),
      body: Column(
        children: [
          SoundWidget(
            soundController: _controller,
            backgroundColor: Colors.green,
          ),
          CircleButtons(),
          SizedBox(
            height: 250,
            child: IntegerNumberPicker(
              size: 60,
              pickedItemDecoration: BoxDecoration(
                  color: Color(0xff392467),
                  borderRadius: BorderRadius.circular(25)),
              pickedItemTextStyle:
                  GoogleFonts.inter(fontSize: 20, color: Colors.white),
              axis: Axis.horizontal,
              initialValue: 5,
              minValue: 1,
              maxValue: 11,
              onChanged: (i) => setState(() {
                context.read<ToneGen>().burstdurations = i;
                print(context.read<ToneGen>().burstdurations);
              }),
            ),
          ),
          SoundWidget(
            soundController: _controller,
            backgroundColor: Colors.green,
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                child: Text("Play"),
                onPressed: () async {
                  void playtone() async {
                    if (playit == true) {
                      await _controller.play();

                      Timer(Duration(seconds: burstDuration), () async {
                        await _controller.stop();
                        await Future.delayed(Duration(
                            seconds:
                                10 - burstDuration)); // Use Future.delayed here
                        playtone(); // Recursively call playtone to repeat
                      });
                    } else {
                      _controller.stop();
                    }
                  }

                  playtone();
                  final val = await _controller.isPlaying();
                  print('isPlaying: $val');
                },
              ),
              SizedBox(width: 24),
              MaterialButton(
                child: Text("Stop"),
                onPressed: () async {
                  await _controller.stop();
                  setState(() {
                    playit = false;
                  });
                  final val = await _controller.isPlaying();
                  print('isPlaying: $val');
                },
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          MaterialButton(
            color: buttonColor,
            child: Text(isDetecting ? "Stop Detection" : "Start Detection"),
            onPressed: () async {
              if (isDetecting) {
                _stopDetection();
              } else {
                _startDetection();
              }
            },
          ),
        ],
      ),
    );
  }
}
