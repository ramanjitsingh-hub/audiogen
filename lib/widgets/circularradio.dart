import 'package:audiogen/channelselector.provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CircleButtons extends StatefulWidget {
  const CircleButtons({super.key});

  @override
  State<CircleButtons> createState() => _CircleButtonsState();
}

class _CircleButtonsState extends State<CircleButtons> {
  int selectedButton = -1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SizedBox(
              height: 200,
            ),
            Text("Left",
                style: GoogleFonts.inter(
                    fontSize: 25, fontWeight: FontWeight.normal)),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedButton = 0;
                  context.read<ToneGen>().selectedChannel = selectedButton;
                  // Assuming 0 represents the left circle
                });
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Color(0xffA367B1)),
                  color: selectedButton == 0
                      ? Color(0xffA367B1)
                      : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 150,
        ),
        Column(
          children: [
            SizedBox(
              height: 200,
            ),
            Text("Right",
                style: GoogleFonts.inter(
                    fontSize: 25, fontWeight: FontWeight.normal)),
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedButton = 1;
                  context.read<ToneGen>().selectedChannel =
                      selectedButton; // Assuming 1 represents the right circle
                });
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.green),
                  color: selectedButton == 1
                      ? Color(0xffA367B1)
                      : Colors.transparent,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
