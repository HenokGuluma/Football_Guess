import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';

import 'board_view.dart';
import 'model.dart';

class SpinningBaby extends StatefulWidget {

  String category;
  String lobbyId;
  bool public;
  String creatorId;
  int categoryNo;
  bool solo;
  UserVariables variables;
  Function startBackground;

  SpinningBaby({
    this.category, this.lobbyId, this.public, this.solo, this.variables, this.startBackground, this.creatorId, this.categoryNo,
  });

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
    Luck("Christiano-Ronaldo", 0),
    Luck("Lionel-Messi", 1),
    Luck("Alexis-Sanchez", 2),
    Luck("Paul-Pogba", 3),
    Luck("Sadio-Mane", 4),
    Luck("Mohammed-Salah", 5),
    Luck("Luca-Modric", 6),
    Luck("Harry Kane", 7),
     Luck("Kevin-DeBruyne", 8),
    Luck("Kylian-Mbappe", 9),
    Luck("Bukayo-Saka", 10),
    Luck("Neymar-Jr", 11),
     Luck("Steve Jobs", 12),
    Luck("Karim-Benzema", 13),
     Luck("Henok-Taddesse", 14),
    Luck("Yonatan-Taddesse", 15),
    Luck("Jeff Bezos", 16),
    Luck("Elon Musk", 17),
  ];
  Timer _timer;
  int timeLeft = 150;
  bool spinning = false;
  bool haveSpun = false;
  bool showWinner = false;
  bool disposed = false;
  var _firestore = FirebaseFirestore.instance;
  int playerAmount = 0;
   bool setupPlayers = true;
  dynamic playerInfos;
  dynamic playerInfotemp;
  bool resetColor = true;
  List<dynamic> playerList = [];
  List<dynamic> playerListOnline = [];
  int _start = 100;
  bool startDown = false;
  bool lastPlayer = false;
    bool automaticCountDown = false;
  bool automaticCounting = false;
  int automaticCount = 0;
  var _firebaseProvider = FirebaseProvider();
  List<dynamic> initialPlayers = ['@sewyew', '@babyShark', '@magnaw', '@chisua', '@antemAleh?', '@echinYiwedal'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var _duration = Duration(milliseconds: 50000);
    _ctrl = AnimationController(vsync: this, duration: _duration)..addListener(() {
        
      setState(() {
           
      });

     });;
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastOutSlowIn);
  }

  

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
     var height = MediaQuery.of(context).size.height;
    return WillPopScope(
    onWillPop: () async => false,
    child: StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection("lobbies").doc(widget.lobbyId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // print('hooray');
        
        if(snapshot.hasData){
          // print('hooray');
          playerAmount = snapshot.data['players'].length;
          playerListOnline = snapshot.data['players'];
          playerInfotemp = snapshot.data['playerInfo'];
          if(snapshot.data['players'].length<2){
            lastPlayer = true;
             
          }
          

          if(snapshot.data['active']){
             startDown = true;
            
          }
           
          else{
             startDown = false;
            
          }
           if(widget.public){
            if(snapshot.data['players'].length >0 && !snapshot.data['startedCountdown']){
            automaticCountDown = true;
            automaticCounting = true;
            automaticCount = 30;
          }
         
          }
        }
        else{
         print('bowwwnce');
        }
        return gameScreen(width, height, snapshot);})
        );
   
    
    }

    gameScreen(var width, var height, AsyncSnapshot snapshot){
      Map<dynamic, dynamic> playerDetails = snapshot.data['playerInfo'];
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
              child: Text('Spinner-Wheel', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),),
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
                  BoardView(items: _items, current: _current, angle: _angle, players: snapshot.data['active']?snapshot.data['spinList']:snapshot.data['players'], playerInfo: snapshot.data['playerInfo'],),
                  _buildGo(snapshot),
                 
                ],
              ),
               _buildResult(_value, snapshot),
              ]);
            }),
            GestureDetector(
            onTap: (){
              setState(() {
                disposed = true;
              });
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

  _buildGo(AsyncSnapshot snapshot) {
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
        onTap: (){
          spinning
          ?_noPress()
          :_animation(snapshot);
          ;
        }
      ),
    );
  }

   void startTimer(){
    _timer = Timer.periodic(
      Duration(milliseconds: 100), (timer) {
        if(disposed){

        }
        else if(timeLeft==0){
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

  _noPress(){
    print('boom');
  }


  _animation(AsyncSnapshot snapshot) {
    List<dynamic> shuffledList = snapshot.data['players'];
    shuffledList.shuffle();
    _items.shuffle();
    initialPlayers.shuffle();
    
    // _firebaseProvider.sendSpinList(shuffledList, widget.lobbyId);
    setState(() {
      spinning = true;
      haveSpun = true;
      showWinner = false;
      timeLeft = 150;
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

  int _calIndex(value, snapshot) {
    var _base = (2 * pi / snapshot.data['players'].length / 2) / (2 * pi);
    return (((((_base + value) % 1) * snapshot.data['players'].length)+snapshot.data['players'].length/4) % snapshot.data['players'].length).floor();
  }

  _buildResult(_value, snapshot) {
    var _index = _calIndex((_value) * (_angle) + _current, snapshot);
    String _asset = '@' + snapshot.data['playerInfo'][snapshot.data['players'][_index]]['userName'];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(spinning?_asset:haveSpun && showWinner?'Winner: '+ _asset:haveSpun?_asset:'', style: TextStyle(color: spinning?Colors.white:Color(0xff63ff00), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
      ),
    );
  }
}