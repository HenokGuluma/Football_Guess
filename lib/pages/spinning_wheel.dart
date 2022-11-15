import 'dart:async';
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
    Luck("Harry Kane", Colors.accents[14]),
     Luck("Kevin-DeBruyne", Colors.accents[1]),
    Luck("Kylian-Mbappe", Colors.accents[3]),
    Luck("Bukayo-Saka", Colors.accents[5]),
    Luck("Neymar-Jr", Colors.accents[7]),
     Luck("Steve Jobs", Colors.accents[12]),
    Luck("Karim-Benzema", Colors.accents[14]),
     Luck("Henok-Taddesse", Colors.accents[1]),
    Luck("Yonatan-Taddesse", Colors.accents[3]),
    Luck("Jeff Bezos", Colors.accents[5]),
    Luck("Elon Musk", Colors.accents[7]),
  ];
  Timer _timer;
  int timeLeft = 1200;
  bool spinning = false;
  bool haveSpun = false;
  bool showWinner = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var _duration = Duration(milliseconds: 20000);
    _ctrl = AnimationController(vsync: this, duration: _duration)..addListener(() {
        
      setState(() {
           
      });

     });;
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
     var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
           image: DecorationImage(
            image: AssetImage('assets/game_play.png'),
            fit: BoxFit.cover
           ),),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             SizedBox(
              height: height*0.05,
            ),
            Center(
              child: Text('SPINNER-WHEEL', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),),
            ),
            SizedBox(
              height: height*0.05,
            ),
            AnimatedBuilder(
            animation: _ani,
            builder: (context, child) {
              final _value = _ani.value;
              final _angle = _value * this._angle;
              return Column(
                children: [
                  Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  BoardView(items: _items, current: _current, angle: _angle),
                  _buildGo(),
                 
                ],
              ),
               _buildResult(_value),
              ]);
            }),
            GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Go Back', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
          ],
        )
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
            "Spin",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w900, fontFamily: 'Muli', ),
          ),
        ),
        onTap: _animation,
      ),
    );
  }

   void startTimer(){
    _timer = Timer.periodic(
      Duration(milliseconds: 10), (timer) {
        if(timeLeft==0){
          _timer.cancel();
          // cardWidget.add(card(width, height, value));
         
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
            spinning = false;
            showWinner = true;
          });
          });
        }
        else{
          setState(() {
            timeLeft-=1;
          });
        }
       });
  }


  _animation() {
    _items.shuffle();
    setState(() {
      spinning = true;
      haveSpun = true;
      showWinner = false;
      timeLeft = 1200;
    });
    if (!_ctrl.isAnimating) {
      var _random = Random().nextDouble();
      _angle = 20 + Random().nextInt(5) + _random;
      _ctrl.forward(from: 0.0).then((_) {
        _current = (_current + _random);
        _current = _current - _current ~/ 1;
        _ctrl.reset();
      });
    }
    startTimer();
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
        child: Text(spinning?_asset:haveSpun && showWinner?'Winner: '+ _asset:haveSpun?_asset:'', style: TextStyle(color: spinning?Colors.white:Color(0xff63ff00), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
      ),
    );
  }
}