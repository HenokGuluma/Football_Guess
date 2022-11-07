import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';



class SpinnerWheel extends StatefulWidget {
  @override
  _SpinnerWheelState createState() => _SpinnerWheelState();
}

class _SpinnerWheelState extends State<SpinnerWheel> {
  StreamController<int> selected = StreamController<int>();

  int selectedInt = 0;

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      'Grogu',
      'Mace Windu',
      'Obi-Wan Kenobi',
      'Han Solo',
      'Luke Skywalker',
      'Darth Vader',
      'Yoda',
      'Ahsoka Tano',
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        title: Text('Flutter Fortune Wheel', style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 20, fontWeight: FontWeight.w900),),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            selected.add(
              Fortune.randomInt(0, items.length),
            );
            selectedInt = Random().nextInt(items.length-1);
          });
        },
        child: Expanded(
              child: FortuneWheel(
               
                 indicators: <FortuneIndicator>[
    FortuneIndicator(
      alignment: Alignment.centerRight, // <-- changing the position of the indicator
      child: TriangleIndicator(
        color: Colors.green, // <-- changing the color of the indicator
      ),
    ),
  ],
                 physics: CircularPanPhysics(
    duration: Duration(seconds: 8),
    curve: Curves.decelerate,
  ),
                animateFirst: false,
                selected: selectedInt,
                items: [
                  for (var it in items) FortuneItem(child: Text(it, style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli', fontWeight: FontWeight.w900),)),
                ],
              ),
            ),
         
      ),
    );
  }
}
 