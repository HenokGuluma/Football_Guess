import 'dart:math';

import 'package:flutter/material.dart';

import 'board_view.dart';
import 'model.dart';

class SpinningBaby extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SpinningBabyState();
  }
}

class _SpinningBabyState extends State<SpinningBaby>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _current = 0;
  AnimationController _ctrl;
  Animation _ani;
  List<Luck> _items = [
    Luck("Christiano-Ronaldo", Colors.accents[0]),
    Luck("Lionel-Messi", Colors.accents[2]),
    Luck("Alexis-Sanchez", Colors.accents[4]),
    Luck("Paul-Pogba", Colors.accents[6]),
    Luck("Sadio-Mane", Colors.accents[8]),
    Luck("Mohammed-Salah", Colors.accents[10]),
    Luck("Luca-Modric", Colors.accents[12]),
    Luck("Karim-Benzema", Colors.accents[14]),
     Luck("Kevin-DeBruyne", Colors.accents[1]),
    Luck("Kylian-Mbappe", Colors.accents[3]),
    Luck("Bukayo-Saka", Colors.accents[5]),
    Luck("Karim-Benzema", Colors.accents[7]),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var _duration = Duration(milliseconds: 15000);
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green, Colors.blue.withOpacity(0.2)])),
        child: AnimatedBuilder(
            animation: _ani,
            builder: (context, child) {
              final _value = _ani.value;
              final _angle = _value * this._angle;
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  BoardView(items: _items, current: _current, angle: _angle),
                  _buildGo(),
                  _buildResult(_value),
                ],
              );
            }),
      ),
    );
  }

  _buildGo() {
    return Material(
      color: Colors.white,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        child: Container(
          alignment: Alignment.center,
          height: 72,
          width: 72,
          child: Text(
            "GO",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: _animation,
      ),
    );
  }

  _animation() {
    _items.shuffle();
    if (!_ctrl.isAnimating) {
      var _random = Random().nextDouble();
      _angle = 20 + Random().nextInt(5) + _random;
      _ctrl.forward(from: 0.0).then((_) {
        _current = (_current + _random);
        _current = _current - _current ~/ 1;
        _ctrl.reset();
      });
    }
  }

  int _calIndex(value) {
    var _base = (2 * pi / _items.length / 2) / (2 * pi);
    return (((((_base + value) % 1) * _items.length)+_items.length/4) % _items.length).floor();
  }

  _buildResult(_value) {
    var _index = _calIndex((_value) * (_angle) + _current);
    String _asset = _items[_index].asset;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(_asset, style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 20, fontWeight: FontWeight.w900),),
      ),
    );
  }
}