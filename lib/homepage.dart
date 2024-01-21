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

  String? note;
  int? octave;
  bool? isRecording;

  FlutterFft flutterFft = new FlutterFft();

  _initialize() async {
    print("Starting recorder...");
    // print("Before");
    // bool hasPermission = await flutterFft.checkPermission();
    // print("After: " + hasPermission.toString());

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
              print("Changed state, received: $data"),
              setState(
                () => {
                  frequency = data[1] as double,
                  note = data[2] as String,
                  octave = data[5] as int,
                },
              ),
              flutterFft.setNote = note!,
              flutterFft.setFrequency = frequency!,
              flutterFft.setOctave = octave!,
              print("Octave: ${octave!.toString()}")
            },
        onError: (err) {
          print("Error: $err");
        },
        onDone: () => {print("Isdone")});
  }

  @override
  void initState() {
    isRecording = flutterFft.getIsRecording;
    frequency = flutterFft.getFrequency;
    note = flutterFft.getNote;
    octave = flutterFft.getOctave;
    super.initState();
    _initialize();
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isRecording!
                    ? Column(
                        children: [
                          Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                                color: frequency! >= 3900 && frequency! <= 4100
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Text(
                                  "Current frequency: ${frequency!.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    : Text("Not Recording", style: TextStyle(fontSize: 35))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
