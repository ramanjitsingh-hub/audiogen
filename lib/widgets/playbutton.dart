import 'package:audiogen/channelselector.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surround_sound/surround_sound.dart';

class PlayButton extends StatefulWidget {
  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool isPlaying = false;
  final _controller = SoundController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Button tapped!");
        setState(() {
          isPlaying = !isPlaying;
          print("$isPlaying");
        });
        _playTone(context, _controller, isPlaying);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Icon(
          isPlaying ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

void _playTone(
    BuildContext context, SoundController controller, bool isPlaying) async {
  print("inside play func");
  final toneGen = context.read<ToneGen>(); // Access the provider

  final frequency = toneGen.frequency;
  final burstDuration = toneGen.burstdurations;
  final selectedChannel = toneGen.selectedChannel;
  controller.setPosition(
      selectedChannel == 0
          ? 0.2
          : selectedChannel == 1
              ? -0.2
              : 0,
      0,
      0);
  controller.setPosition(0, 0, 0);
  controller.setFrequency(5000);
  controller.setVolume(1);
  controller.play();
  await Future.delayed(Duration(seconds: burstDuration));
  await controller.stop();
  await Future.delayed(Duration(seconds: 10 - burstDuration));
  // if (isPlaying) {
  //   _playTone(context, controller, isPlaying); // Repeat
  // }
  // Repeat
}

// void _stopTone(BuildContext context, SoundController controller) async {
//   await controller.stop(); // Repeat
// }
