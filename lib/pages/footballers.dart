import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Footballers extends StatefulWidget {

  String category;
  bool public;
  String lobbyId;
  String creatorId;
  int categoryNo;
  bool solo;
  UserVariables variables;
   Function pauseBackground;
  Function startBackground;

 
  Footballers({
    this.category, this.lobbyId, this.solo, this.public, this.variables, this.creatorId, this.categoryNo, this.pauseBackground, this.startBackground
  });

  @override
  _FootballersState createState() => _FootballersState();
}

class _FootballersState extends State<Footballers>
    with TickerProviderStateMixin {
  List<List<String>> images = 
  [['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png']
  ];

  List<String> profilePics = ['assets/profile_pic1.png', 'assets/profile_pic2.png',
    'assets/profile_pic3.png', 'assets/profile_pic4.png'
  ];

   List<String> profileNames = ['ashley123', 'joe_rogan',
    'willSmith', 'ruthaBG89'
  ];

  List<String> categories = ['Jersey No.', 'Goals', 'Age', 'Height'];
  List<String> categoryId = ['jersey', 'goals', 'age', 'height'];

  List<List<Map<String, dynamic>>> footballers = 
  [
    [
      {'name': 'Alexis Sanchez', 'age': 33, 'image':'assets/Alexis-Sanchez.png', 'height': 1.68, 'jersey': 4, 'goals': 326 },
      {'name': 'Paul Pogba', 'age': 29, 'image':'assets/Paul-Pogba.png', 'height': 1.81, 'jersey': 6, 'goals': 216 },
    ],
    [
      {'name': 'Lionel Messi', 'age': 35, 'image':'assets/Lionel-Messi.png', 'height': 1.7, 'jersey': 30, 'goals': 750 },
       {'name': 'Christiano Ronaldo', 'age': 37, 'image':'assets/Christiano-Ronaldo.png', 'height': 1.82, 'jersey': 7, 'goals': 780},
    ],
    
    [
      {'name': 'Kylian Mbappe', 'age': 23, 'image':'assets/Kylian-Mbappe.png', 'height': 1.79, 'jersey': 7, 'goals': 160 },
      {'name': 'Bukayo-Saka', 'age': 21, 'image':'assets/Bukayo-Saka.png', 'height': 1.78, 'jersey': 10, 'goals': 89 },
    ],
     [
      {'name': 'Karim Benzema', 'age': 34, 'image':'assets/Karim-Benzema.png', 'height': 1.78, 'jersey': 9, 'goals': 280},
      {'name': 'Luka Modric', 'age': 37, 'image':'assets/Luca-Modric.png', 'height': 1.76, 'jersey': 16, 'goals': 72 },
    ],
   
    [
      {'name': 'Sadio Mane', 'age': 31, 'image':'assets/Sadio-Mane.png', 'height': 1.78, 'jersey': 19, 'goals': 276 },
      {'name': 'Mohammed Salah', 'age': 30, 'image':'assets/Mohammed-Salah.png', 'height': 1.77, 'jersey': 10, 'goals': 306 },
    ]
  ];
  List<String> backgroundTracks = [
    'assets/sound-effects/sugar.mp3', 'assets/sound-effects/on&on.mp3', 'assets/sound-effects/runaway.mp3',
    'assets/sound-effects/this-girl.mp3', 'assets/sound-effects/spectre.mp3',
  ];

  List<String> menuImages = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png'];

  AnimationController _animationController;
  AnimationController _slideController;
  AnimationController _colorController;
    AnimationController _bounceController;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  PageController _pageController;
  Animation _animation;
  Animation colorAnimation;
  bool animate = false;
  bool correctPicked = false;
  int currentPage = 0;
  bool finished = false;
  int second = 8;
  double timeLeft = 8;
  double resetValue = 8;
  double gamePlayTimeLeft = 3;
  double divider = 8;
  bool defeated = false;
  bool wrongClick = false;
  int gamePlayDuration = 0;
  bool disposed = false;
  bool gameStarted = false;
  bool startDown = false;
  double size = 1;
  bool lastPlayer = false;
  bool paused = false;
  NavigatorState _navigator;
  DocumentSnapshot winner;
  bool retrievingWinner = false;
  bool shouldGetWinner = false;
  bool gotWinner = false;
  int playerAmount = 0;
  bool setupPlayers = true;
  dynamic playerInfos;
  dynamic playerInfotemp;
  bool resetColor = true;
  List<dynamic> playerList = [];
  List<dynamic> playerListOnline = [];
  Map<String, dynamic> footballerData;
  Map<String, dynamic> assetData;
  List<List<String>> footballerPairs = [];
   List<List<String>> easyPairs = [];
    List<List<String>> mediumPairs = [];
     List<List<String>> hardPairs = [];
  List<List<String>> height_easy_pairs = [];
  List<List<String>> height_medium_pairs = [];
  List<List<String>> height_hard_pairs = [];
  List<List<String>> goals_easy_pairs = [];
  List<List<String>> goals_medium_pairs = [];
  List<List<String>> goals_hard_pairs = [];
  List<List<String>> age_medium_pairs = [];
  List<List<String>> age_hard_pairs = [];
  List<List<String>> age_easy_pairs = [];
   List<List<String>> jersey_medium_pairs = [];
  List<List<String>> jersey_hard_pairs = [];
  List<List<String>> jersey_easy_pairs = [];
  List<List<String>> age_pairs = [];
  List<List<String>> goals_pairs = [];
  List<List<String>> height_pairs = [];
  List<List<String>> jersey_pairs = [];
  bool automaticCountDown = false;
  bool automaticCounting = false;
  int automaticCount = 0;
  Color finalColor;
  final player = AudioPlayer(); 
  final correctPlayer = AudioPlayer();

  
  

 @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _colorController.dispose();
    _animation = null;
    colorAnimation = null;
   player.stop();
    super.dispose();
  }


  @override
  void initState() {
    readJson().then((value) {
      List<List<String>> age_pairs_temp = [];
      
      List<List<String>> goals_pairs_temp = [];
      List<List<String>> height_pairs_temp = [];
      List<List<String>> jersey_pairs_temp = []; 
      age_pairs_temp = concatenateList(goals_pairs_temp,  age_easy_pairs.take(15).toList());
      age_pairs_temp = concatenateList(goals_pairs_temp,  age_medium_pairs.take(15).toList());
      age_pairs_temp = concatenateList(goals_pairs_temp,  age_hard_pairs.take(15).toList());
      goals_pairs_temp = concatenateList(goals_pairs_temp,  goals_easy_pairs.take(15).toList());
      goals_pairs_temp = concatenateList(goals_pairs_temp,  goals_medium_pairs.take(20).toList());
      goals_pairs_temp = concatenateList(goals_pairs_temp,  goals_hard_pairs.take(30).toList());
      height_pairs_temp = concatenateList(height_pairs_temp,  height_easy_pairs.take(15).toList());
      height_pairs_temp = concatenateList(height_pairs_temp,  height_medium_pairs.take(20).toList());
      height_pairs_temp = concatenateList(height_pairs_temp,  height_hard_pairs.take(30).toList());
      jersey_pairs_temp = concatenateList(jersey_pairs_temp,  jersey_easy_pairs.take(15).toList());
      jersey_pairs_temp = concatenateList(jersey_pairs_temp,  jersey_medium_pairs.take(20).toList());
      jersey_pairs_temp = concatenateList(jersey_pairs_temp,  jersey_hard_pairs.take(30).toList());
      print('shaklooos'); print(height_pairs_temp);print(height_medium_pairs);
      if(widget.category == "height"){
        print('height indeed');
        setState(() {
          footballerPairs = height_pairs_temp;
          easyPairs = height_easy_pairs;
          mediumPairs = height_medium_pairs;
          hardPairs = height_hard_pairs;
        });
      }
      else if(widget.category == "goals"){
        print('major accident');
        setState(() {
          footballerPairs = goals_pairs_temp;
          easyPairs = goals_easy_pairs;
          mediumPairs = goals_medium_pairs;
          hardPairs = goals_hard_pairs;
        });
      }
      else if(widget.category == "age"){
        setState(() {
          footballerPairs = age_pairs_temp;
          easyPairs = age_easy_pairs;
          mediumPairs = age_medium_pairs;
          hardPairs = age_hard_pairs;
        });
      }
        else if(widget.category == "jersey"){
        setState(() {
          footballerPairs = jersey_pairs_temp;
          easyPairs = jersey_easy_pairs;
          mediumPairs = jersey_medium_pairs;
          hardPairs = jersey_hard_pairs;
        });
      }
      setState(() {
        age_pairs = age_pairs_temp;
        goals_pairs = goals_pairs_temp;
        height_pairs = height_pairs_temp;
        jersey_pairs = jersey_pairs_temp;
      });
    });
    _navigator = Navigator.of(context);
    _pageController = PageController(initialPage: currentPage, viewportFraction: 1);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _colorController = AnimationController(duration: Duration(seconds: 13), vsync: this);
     _slideController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(seconds: second),
      // value: timeLeft.toDouble(),
    )..addListener(() {
        setState(() {});
      });
      // _slideController.reset(); _colorController.reset();
    _slideController.repeat(reverse: false);

    super.initState();

    _colorController.repeat(reverse: false);
    
    _animationController.repeat(reverse: true);
    // _animationController.reset();
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });

    colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });

      _bounceController = AnimationController(

      duration: Duration(milliseconds: 500),

      vsync: this,

      upperBound: 1.2,
      lowerBound: 1

    );
     _colorController.forward();
_bounceController.forward();
_bounceController.repeat(reverse: true);
_bounceController.addListener(() {

      setState(() {
           size = _bounceController.value;
      });

     });
     
     if(widget.solo){
        setState(() {
          startDown = true;
        });
      }
    
   startCountDown();
   startGamePlayCountDown();
    startSecondCountDown();
    setupSound().then((value) {
      player.play();
    });
    // scheduleTimeout(second * 1000);
    
  }

   Future<void> setupSound() async{
    var index = Random().nextInt(4);
    await player.setAsset(backgroundTracks[index]);
    await correctPlayer.setAsset('assets/sound-effects/correct.mp3');
    player.setVolume(0.04);
    correctPlayer.setVolume(0.2);
    correctPlayer.setSpeed(0.7);
  }

  List<dynamic> concatenateList(List<dynamic> mainList, List<dynamic> addedList){
    List<dynamic> returnedList = mainList;
    for(int i = 0; i<addedList.length; i++){
      returnedList.add(addedList[i]);
    }
    return returnedList;
  }

  Future<void> readJson() async {
final String footballersResponse = await rootBundle.loadString('assets/docs/footballers.json');
final String assetResponse = await rootBundle.loadString('assets/docs/asset-map.json');
final data = await json.decode(footballersResponse);
final data2 = await json.decode(assetResponse);
// print(data["52"]["name"]); print('is the data');
setState(() {
  footballerData = data;
  assetData = data2;
});
String height_easy = await rootBundle.loadString('assets/docs/height-easy.txt');
String height_medium = await rootBundle.loadString('assets/docs/height-medium.txt');
String height_hard = await rootBundle.loadString('assets/docs/height-hard.txt');
String goals_easy = await rootBundle.loadString('assets/docs/goals-easy.txt');
String goals_medium = await rootBundle.loadString('assets/docs/goals-medium.txt');
String goals_hard = await rootBundle.loadString('assets/docs/goals-hard.txt');
String age_easy = await rootBundle.loadString('assets/docs/height-easy.txt');
String age_medium = await rootBundle.loadString('assets/docs/height-medium.txt');
String age_hard = await rootBundle.loadString('assets/docs/height-hard.txt');
String jersey_easy = await rootBundle.loadString('assets/docs/jersey-easy.txt');
String jersey_medium = await rootBundle.loadString('assets/docs/jersey-medium.txt');
String jersey_hard = await rootBundle.loadString('assets/docs/jersey-hard.txt');
splitText(height_easy, 'height_easy');
splitText(height_medium, 'height_medium');
splitText(height_hard, 'height_hard');
splitText(goals_easy, 'goals_easy');
splitText(goals_medium, 'goals_medium');
splitText(goals_hard, 'goals_hard');
splitText(age_easy, 'age_easy');
splitText(age_medium, 'age_medium');
splitText(age_hard, 'age_hard');
splitText(jersey_easy, 'jersey_easy');
splitText(jersey_medium, 'jersey_medium');
splitText(jersey_hard, 'jersey_hard');

// ... 
}

Future<void>splitText(String text, String type){
  // print(text);
  List<List<String>> finalResult = [];
  List<String> pairs = text.split("],");
  for (int i = 0; i<3; i++){
    // print(pairs[i]);
    String clean = pairs[i].replaceAll("[", "");
    List<String> indices = clean.split("-");
    print(indices);
  }
  print(type);
  for (int i = 0; i<pairs.length; i++){
    String clean = pairs[i].replaceAll("[", "");
    List<String> indices = clean.split("-");
    finalResult.add(indices);
    // print(indices);
  }
 if(type == 'height_easy'){
   setState(() {
    height_easy_pairs = finalResult;
    height_easy_pairs.shuffle();
  });
  print(finalResult); print(' is result'); print(height_easy_pairs);
 }
 else if(type == 'height_medium'){
   setState(() {
    height_medium_pairs = finalResult;
    height_medium_pairs.shuffle();
  });
 }
 else if(type == 'height_hard'){
   setState(() {
    height_hard_pairs = finalResult;
    height_hard_pairs.shuffle();
  });
 }
 else if(type == 'age_easy'){
   setState(() {
    age_easy_pairs = finalResult;
    age_easy_pairs.shuffle();
  });
 }
 else if(type == 'age_medium'){
   setState(() {
    age_medium_pairs = finalResult;
    age_medium_pairs.shuffle();
  });
 }
 else if(type == 'age_hard'){
   setState(() {
    age_hard_pairs = finalResult;
    age_hard_pairs.shuffle();
  });
 }
 else if(type == 'goals_easy'){
   setState(() {
    goals_easy_pairs = finalResult;
    goals_easy_pairs.shuffle();
  });
 }
 else if(type == 'goals_medium'){
   setState(() {
    goals_medium_pairs = finalResult;
    goals_medium_pairs.shuffle();
  });
 }
 else if(type == 'goals_hard'){
  setState(() {
    goals_hard_pairs = finalResult;
    goals_hard_pairs.shuffle();
  });
 }
 else if(type == 'jersey_easy'){
  setState(() {
    jersey_easy_pairs = finalResult;
    jersey_easy_pairs.shuffle();
  });
 }
 else if(type == 'jersey_medium'){
  setState(() {
    jersey_medium_pairs = finalResult;
    jersey_medium_pairs.shuffle();
  });
 }
 else if(type == 'jersey_hard'){
  setState(() {
    jersey_hard_pairs = finalResult;
    jersey_hard_pairs.shuffle();
  });
 }
//  print(finalResult); print(' is final result');
 return null;
}

  Future<void> getWinner() async{
    if(!widget.solo){
      setState(() {
      retrievingWinner = true;
    });
   Future.delayed(Duration(seconds: 6)).then((value) {
     if(widget.public){
      _firebaseProvider.getPublicLobbyWinner(widget.lobbyId).then((lobbyWinner) {
      if(lobbyWinner!=null){
        setState(() {
          winner = lobbyWinner;
          retrievingWinner = false;
        });
      }
    });
     }
     else{
      _firebaseProvider.getLobbyWinner(widget.lobbyId).then((lobbyWinner) {
      if(lobbyWinner!=null){
        setState(() {
          winner = lobbyWinner;
          retrievingWinner = false;
        });
      }
    });
     }
   });
    }
    else{

    }
  }

  void startCountDown(){
    Timer.periodic(Duration(milliseconds: 100), (timer) { 
      if(disposed){
       
      }
      else if(paused){

      }

      else if(automaticCountDown){
        _firebaseProvider.setAutomaticTime(widget.lobbyId);
        setState(() {
          automaticCountDown = false;
        });
      }

      else if(!gameStarted){

      }
      else if (wrongClick){
        
      }
      else if(timeLeft >0){
        setState(() {
          timeLeft = timeLeft-0.1;
          // _colorController.value = (timeLeft -1).toDouble();
          // _slideController.value = (timeLeft-1).toDouble();
        });
      }
      
      else{
        handleTimeout();
      }

      
     
    });
  }

  void startGamePlayCountDown(){
    Timer.periodic(Duration(milliseconds: 1000), (timer) { 
      
      if(disposed){
       
      }
       else if(paused){

      }
      else if(!startDown && !widget.solo){
       
      }
      else if(gamePlayTimeLeft >0){
         
        setState(() {
          gamePlayTimeLeft = gamePlayTimeLeft-1;
          // _slideController.value = (timeLeft-1).toDouble();
        });
      }

      else if (resetColor){
        setState(() {
           _colorController = AnimationController(duration: Duration(seconds: resetValue.toInt()), vsync: this);
           colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
          _colorController.forward();
          resetColor = false;
        });
      }

      else{
        
        setState(() {
          gameStarted = true;
          
        });
      }
     
      
    });
  }

  void startSecondCountDown(){
    Timer.periodic(Duration(milliseconds: 1000), (timer) { 
      if(automaticCounting && !disposed){
        if(automaticCount>0){
          setState(() {
          automaticCount = automaticCount -1;
        });
        }
        else{
          setState(() {
            _colorController.reset();
          automaticCounting = false;
          gameStarted = true;
          gamePlayTimeLeft = 0;
        });
        }
      }
      if(!gameStarted){

      }
       else if(paused){

      }
      else if(disposed){

      }
      else if (gamePlayDuration >=100){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 1.5;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=100){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 1.75;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=90){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 2.0;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=80){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 2.5;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=65){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 3.0;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=50){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 3.5;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=40){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 4;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if(gamePlayDuration >=20){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          gamePlayDuration = gamePlayDuration+1;
          resetValue = 6;
          // _slideController.value = (timeLeft-1).toDouble();
        });
      }
      
      else{
        // print(gamePlayDuration.toString() + ' is the duration');
        gamePlayDuration = gamePlayDuration+1;
      }

      // print(timeLeft/resetValue); print (' is the timer');

       if(!gotWinner && playerAmount<1 && !disposed){
        print('baaaam');
        getWinner().then((value) {
          setState(() {
            gotWinner = true;
            // shouldGetWinner = false;
          });
        });
      }

      if(setupPlayers && playerInfotemp!=null && !disposed){
        // List<dynamic> list =  playerInfotemp.entries.map( (entry) => entry.value).toList();
        setState(() {
          playerList = playerListOnline;
          playerInfos = playerInfotemp;
          setupPlayers = false;
        });
      }
      // print(playerAmount); print(' is the amount');

    });
  }

  void stopGame(){
     _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
  }



void handleTimeout() {  // callback function
  print('time out');
  setState(() {
          animate = true;
          wrongClick = true;
          _animationController.repeat(reverse: true);
           _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });
        });
        print('stage777');
        if(!widget.solo){
          print('stage587');
          if(widget.public){
            print('stage478');
            _firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId).then((value) {
      _firebaseProvider.submitPublicUserScore(widget.variables.currentUser, widget.lobbyId, currentPage*10);
    });
          }
          else{
            print('stage255');
            _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId).then((value) {
      _firebaseProvider.submitUserScore(widget.variables.currentUser, widget.lobbyId, currentPage*10);
    });
          }
       if(lastPlayer){
        stopGame();
       }
        }
        Future.delayed(Duration(seconds: 3)).then((value) {
          setState(() {
            defeated = true;
            
          });
        });
}
   

  @override
  Widget build(BuildContext context) {
     var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
 
    return WillPopScope(
    onWillPop: () async => false,
    child: !widget.solo
    ?StreamBuilder<DocumentSnapshot>(
      stream: widget.public?_firestore
          .collection("publicLobbies").doc(widget.lobbyId).snapshots():_firestore
          .collection("lobbies").doc(widget.lobbyId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        
        if(snapshot.hasData){
          playerAmount = snapshot.data['players'].length;
          playerListOnline = snapshot.data['players'];
          playerInfotemp = snapshot.data['playerInfo'];
          if(snapshot.data['players'].length<2){
            lastPlayer = true;
             
          }
          else if(snapshot.data['players'].length <1){
            shouldGetWinner = true;
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
         
        }
        return gameScreen(width, height, snapshot);})
        :gameScreenSolo(width, height)
        );
   
   }

   Widget gameScreen(var width, var height, AsyncSnapshot<DocumentSnapshot> snapshot){
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/stadium.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          Container(
        width: width,
        height: height,
        child: defeated || finished
        ?Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height*0.05,),
            Padding(
              padding: EdgeInsets.only(top: height*0.05, left: width*0.05),
              child: Center()
              ),
              SizedBox(
                height: height*0.02,
              ),
             Container(
              height: height*0.15,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                    return profileCircle(width, height, index, playerInfos[playerList[index]], snapshot);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: playerList.length,
                ),
            ),
            SizedBox(height: height*0.05,),
            retrievingWinner
            ?Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                'Game Over', style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 45, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.1,
            ),
            
             Center(
            child: Text(
                'Calculating Results', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
          
             MaterialButton(
                onPressed: (){
                  showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Leave', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          ],
        )
        ,
            )
            :Center(
              child: winner!=null
            ?
              widget.variables.currentUser.userName != winner.data()['userName']
              ?Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                'The Winner is: ', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            SizedBox(
              height: height*0.02,
            ),
            winnerWidget(width, height, winner),
           
              SizedBox(
              height: height*0.1,
            ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               MaterialButton(
              onPressed: (){
                print('sdfasdf');
                widget.public?_firebaseProvider.addUserToPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId);
                setState(() {
                  footballerPairs = [];
                  footballerPairs = concatenateList(footballerPairs, randomElements(easyPairs, 15));
                  footballerPairs = concatenateList(footballerPairs,  randomElements(mediumPairs, 20));
                  footballerPairs = concatenateList(footballerPairs,  randomElements(hardPairs, 30));
                });
                setState(() {
                    _colorController = AnimationController(duration: Duration(seconds: resetValue.toInt()), vsync: this);
           colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
          _colorController.forward();
                  timeLeft = 5.5;
                  // _slideController.value = 5.5;
                  defeated = false;
                  resetValue = 6;
                  resetColor = true;
                  winner = null;
                  gotWinner = false;
                  gamePlayDuration=0;
                  divider = 6;
                  finished = false;
                  wrongClick = false;
                  gameStarted = false;
                  gamePlayTimeLeft = 3;
                  correctPicked = false;
                  easyPairs.shuffle();
                  mediumPairs.shuffle();
                  hardPairs.shuffle();
                  animate = false;
                  currentPage = 0;
                  _animationController.reset();
                  _slideController.reset();
                  _slideController.repeat(reverse: false);
                });
                
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
                ),
                width: width*0.45,
                height: width*0.12,
                child: Center(
                  child: Text(
                'Try Again', style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 22, fontWeight: FontWeight.w900),
              ),
                ),
              ),
            ),
            
             MaterialButton(
                onPressed: (){
                  showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Leave', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          
            ],
           )],
        )
        :Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                'Congratulations', style: TextStyle(color: Color(0xff63ff00), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.06,
            ),
           Text(
                'You have won with score ' + (currentPage*10).toString(), style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
              SizedBox(
              height: height*0.1,
            ),
              SizedBox(
              height: height*0.08,
            ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               MaterialButton(
              onPressed: (){
                print('asdfasdf');
                setState(() {
                  footballerPairs = [];
                  footballerPairs = concatenateList(footballerPairs, randomElements(easyPairs, 15));
                  footballerPairs = concatenateList(footballerPairs,  randomElements(mediumPairs, 20));
                  footballerPairs = concatenateList(footballerPairs,  randomElements(hardPairs, 30));
                  // footballerPairs.shuffle();
                });
                  _colorController = AnimationController(duration: Duration(seconds: resetValue.toInt()), vsync: this);
           colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
          _colorController.forward();
                widget.public?_firebaseProvider.addUserToPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId);
                setState(() {
                  timeLeft = 5.5;
                  // _slideController.value = 5.5;
                  defeated = false;
                  resetColor = true;
                  resetValue = 6;
                  winner = null;
                  gotWinner = false;
                  gamePlayDuration=0;
                  divider = 6;
                  finished = false;
                  wrongClick = false;
                  gameStarted = false;
                  gamePlayTimeLeft = 3;
                  correctPicked = false;
                  easyPairs.shuffle();
                  mediumPairs.shuffle();
                  hardPairs.shuffle();
                  animate = false;
                  currentPage = 0;
                  _animationController.reset();
                  _slideController.reset(); 
                  _slideController.repeat(reverse: false);
                });
                
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
                ),
                width: width*0.45,
                height: width*0.12,
                child: Center(
                  child: Text(
                'Try Again', style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 22, fontWeight: FontWeight.w900),
              ),
                ),
              ),
            ),
            
             MaterialButton(
                onPressed: (){
                  showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Leave', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          
            ],
           )],
        ): gotWinner
        ?Text(
                'The score is a tie.', style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              )
        :Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Text(
                'Nice Effort', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 45, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.1,
            ),
            Text(
                'Your final Score is: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),
              ),
               SizedBox(
              height: height*0.1,
            ),
               Center(
            child: Text(
                'Waiting for others to finish', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center,
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
          
             MaterialButton(
                onPressed: (){
                  showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                 widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Leave', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ],
          ),
        )
        ,
            )
          
          ],
        ):Column(
          children: [
            SizedBox(
              height: height*0.1,
            ),
            Container(
              height: height*0.15,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                    return profileCircle(width, height, index, playerInfos[playerList[index]], snapshot);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: playerList.length,
                ),
            ),
            gameStarted
            ?Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
              child: Text(
                widget.category == 'age'?'Who is Older?':widget.category == 'height'
                ?'Who is taller?':widget.category == 'jersey'?'Who has higher Jersey Number?':'Who has more goals?',
                 style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: widget.category == 'jersey'?22:25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            ),
              
            SizedBox(
              height: height*0.03,
            ),
           Container(
            width: width*0.9,
            child:  LinearProgressIndicator(
             /*  color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555), */
              minHeight: 5, 
              backgroundColor: Colors.transparent,
              value: timeLeft == divider?1:(timeLeft/(divider-1)).toDouble(),
              // value: _slideController.value,
              valueColor: AlwaysStoppedAnimation(wrongClick?finalColor:colorAnimation.value),
            ),
           ),
             SizedBox(
              height: height*0.02,
            ),

            Container(
              height: height*0.55,
              width: width,
              child: defeated
              ?Center(
                child: MaterialButton(
                  onPressed: (){

                  },
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('Nice Effort. Your final Score is: '+ (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :finished
              ?Center(
                child: MaterialButton(
                  onPressed: (){},
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('You have finished the list', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :Center(
                child: PageView.builder(
                  allowImplicitScrolling: false,
                  itemCount: (footballerPairs.length),
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelecting(width, height, index, footballerPairs, snapshot),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
              height: height*0.05,
              child:  Padding(
                 padding: EdgeInsets.only(left: width*0.08),
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            ),
            ),
            GestureDetector(
                onTap: (){
                  setState(() {
                    paused = false;
                  });
                   showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                 
                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.4,
                  height: 40,
                  child: Center(
                    child: Text('Leave Game', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              ],
            )

              ],
            )
            :snapshot.hasData && snapshot.data['active'] && gameStarted
            ?Column(
              children: [
                Container(
              width: width*0.8,
              height: height*0.08,
             
              child: Center(
              child: Text(
                widget.category == 'age'?'Who is Older?':widget.category == 'height'
                ?'Who is taller?':widget.category == 'jersey'?'Who has higher Jersey Number?':'Who has more goals?',
                 style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: widget.category == 'jersey'?22:25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            ),
            ),
            SizedBox(
              height: height*0.03,
            ),
           Container(
            width: width*0.9,
            child:  LinearProgressIndicator(
             /*  color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555), */
              minHeight: 5,
              
              backgroundColor: Colors.transparent,
              value: timeLeft == divider?1:(timeLeft/(divider-1)).toDouble(),
              // value: _slideController.value,
             valueColor: AlwaysStoppedAnimation(wrongClick?finalColor:colorAnimation.value),
            ),
           ),
             SizedBox(
              height: height*0.02,
            ),

            Container(
              height: height*0.55,
              width: width,
              child: defeated
              ?Center(
                child: MaterialButton(
                  onPressed: (){

                  },
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('Nice Effort. Your final Score is: '+ (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :finished
              ?Center(
                child: MaterialButton(
                  onPressed: (){},
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('You have finished the list', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :Center(
                child: PageView.builder(
                  allowImplicitScrolling: false,
                  itemCount: (footballerPairs.length),
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelecting(width, height, index, footballerPairs, snapshot),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
             height: height*0.05,
              child:  Padding(
                 padding: EdgeInsets.only(left: width*0.08),
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            ),
            ),
            GestureDetector(
                onTap: (){
                  setState(() {
                    paused = false;
                  });
                   showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                 
                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.4,
                  height: 40,
                  child: Center(
                    child: Text('Leave Game', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              ],
            )

              ],
            )
            :startDown || automaticCounting
            ?Container(
              height: height*0.6,
              width: width,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height*0.15,
                ),
                Center(
            child: Text(
                'Game Starts in', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          SizedBox(
            height: height*0.03,
          ),
           Center(
            child: Text(
                widget.public?automaticCount.toInt().toString():gamePlayTimeLeft.toInt().toString(), style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          
              ],
            )
            )
            : widget.variables.currentUser.uid == widget.creatorId
            ? Container(
              height: height*0.75,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                height: height*0.03,
              ),
              Center(
                child: menuOption(width, height, widget.categoryNo, menuImages),
              ),
              SizedBox(
                height: height*0.06,
              ),
                    Container(
                      height: height*0.3,
                      child: Column(
                        children: [
                          snapshot.data['players'].length<1
                          ?Container(
              width: width*0.35,
              height: width*0.35,
              child: Center(
                child: Text(
                'Start', style: TextStyle(color: Color(0xff999999), fontFamily: 'Muli', fontSize: 38, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                 boxShadow: [BoxShadow(
            color: Color(0xff999999),
            blurRadius: width*0.02,
            spreadRadius: width*0.02
          )],
              ),
            )
                          :MaterialButton(
                onPressed: (){
                  widget.public?_firebaseProvider.startPublicLobbyGame(widget.creatorId, widget.lobbyId):_firebaseProvider.startLobbyGame(widget.creatorId, widget.lobbyId);
                },
                child:  Container(
              width: width*0.35*(pow(size, 0.5)),
              height: width*0.35*pow(size, 0.5),
              child: Center(
                child: Text(
                'Start', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 38, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                 boxShadow: [BoxShadow(
            color: Color(0xff00ffff),
            blurRadius: pow(size, 5)*2,
            spreadRadius: pow(size, 5)*2
          )],
              ),
            ),
              ),
                        ],
                      ),
                    ),
             /*  SizedBox(
                height: height*0.08,
              ), */
               GestureDetector(
                onTap: (){
                 showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Leave', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
                  ],
                )
              ),
            )
            :Container(
              height: height*0.6,
              width: width,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height*0.2,
                ),
                Center(
            child: Text(
                'Waiting for the game to start.', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
          MaterialButton(
                onPressed: (){
                 showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Leave', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              ],
            )
            )
          
          ],
        ),
      ),
    
        ],
      ));
   }

    Widget menuOption(var width, var height, int index, List<String> images){
    return GestureDetector(
      onTap: (){
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
        width: width*0.4,
        height: width*0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(images[index]),
            fit: BoxFit.cover
          )
        ),
      ),
      Container(
        width: width*0.4,
        height: width*0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            stops: [0.4, 1.0],
            colors: [Colors.transparent, Colors.white]
          )
        ),
      ),
      Container(
        width: width*0.3,
        height: width*0.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
         
        ),
        child: Center(
          child: Text(categories[index], style: TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Muli', fontWeight: FontWeight.w900),)
        ),
      ),
      
     
        ],
      )
    );
   }


   List<dynamic> randomElements(List<dynamic> list, int amount) {
    List<dynamic> returnedList;
    returnedList = new List.generate(10, (_) => list[Random().nextInt(list.length)]);
    return returnedList;
  }


   


   Widget gameScreenSolo(var width, var height, ){
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/stadium.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          Container(
        width: width,
        height: height,
        child: defeated || finished
        ?Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height*0.05,),
            Padding(
              padding: EdgeInsets.only(top: height*0.05, left: width*0.05),
              child: Center()
              ),
              SizedBox(
                height: height*0.02,
              ),
             !defeated
             ?Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
              height: height*0.05,
              child:  Padding(
                padding: EdgeInsets.only(left: width*0.08),
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            ),
            ),
            GestureDetector(
                onTap: (){
                  setState(() {
                    paused = false;
                  });
                   showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                 
                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.4,
                  height: 40,
                  child: Center(
                    child: Text('Leave Game', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              ],
            ):Container(
              height: height*0.15,),
            SizedBox(height: height*0.05,),
            Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                'Nice Effort', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 45, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.1,
            ),
            Text(
                'Your final Score is: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),
              ),
              SizedBox(
              height: height*0.1,
            ),
            MaterialButton(
              onPressed: (){
                if(!widget.solo){
                  widget.public?_firebaseProvider.addUserToPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId);
                }
                print('bounchd');
                setState(() {
                  easyPairs.shuffle();
                  mediumPairs.shuffle();
                  hardPairs.shuffle();
                  
                  // footballerPairs.shuffle();
                });
                setState(() {
                    _colorController = AnimationController(duration: Duration(seconds: resetValue.toInt()), vsync: this);
           colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
          _colorController.forward();
          footballerPairs = [];
           footballerPairs = concatenateList(footballerPairs, randomElements(easyPairs, 1));
                  footballerPairs = concatenateList(footballerPairs,  randomElements(mediumPairs, 1));
                  footballerPairs = concatenateList(footballerPairs,  randomElements(hardPairs, 1));
                  timeLeft = 5.5;
                  // _slideController.value = 5.5;
                  defeated = false;
                  resetValue = 6;
                  gamePlayDuration=0;
                  divider = 6;
                  finished = false;
                  wrongClick = false;
                  resetColor = true;
                  correctPicked = false;
                  animate = false;
                  currentPage = 0;
                  _animationController.reset();
                  _slideController.reset(); 
                  _slideController.repeat(reverse: false);
                 
                });
                
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
                ),
                width: width*0.45,
                height: width*0.12,
                child: Center(
                  child: Text(
                'Try Again', style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 22, fontWeight: FontWeight.w900),
              ),
                ),
              ),
            ),
            SizedBox(height: height*0.05,),
             MaterialButton(
                onPressed: (){
                 showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  // _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Leave', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          ],
        )
        ,
            )
          ],
        ):Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height*0.08,
            ),
            !defeated
            ?Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
              height: height*0.05,
              child:  Padding(
                 padding: EdgeInsets.only(left: width*0.08),
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            ),
            ),
            GestureDetector(
                onTap: (){
                  setState(() {
                    paused = false;
                  });
                   showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Leaving the game',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900),
                            ),
                            content: new Text(
                              'Are you sure you want to leave the game? All progresses and bets will be lost.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    paused = false;
                                  });
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  // _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                 _bounceController.reset();
                  _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); player.stop(); widget.startBackground();
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));


                 
                  // dispose();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.4,
                  height: 40,
                  child: Center(
                    child: Text('Leave Game', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
              ],
            ):Container(
              height: height*0.15,),
              SizedBox(
                height: height*0.08,
              ),
            gameStarted
            ?Column(
              children: [
                Container(
              width: width*0.8,
              height: height*0.08,
             
              child: Center(
              child: Text(
                widget.category == 'age'?'Who is Older?':widget.category == 'height'
                ?'Who is taller?':widget.category == 'jersey'?'Who has higher Jersey Number?':'Who has more goals?',
                 style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: widget.category == 'jersey'?22:25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            ),
            ),
            SizedBox(
              height: height*0.03,
            ),
           Container(
            height: height*0.03,
            child: Column(
              children: [
                Container(
            width: width*0.9,
            constraints: BoxConstraints(maxHeight: height*0.05),
            child:  LinearProgressIndicator(
             /*  color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555), */
              minHeight: 5,
              
              backgroundColor: Colors.transparent,
              value: timeLeft == divider?1:(timeLeft/(divider-1)).toDouble(),
              // value: _slideController.value,
             valueColor: AlwaysStoppedAnimation(wrongClick?finalColor:colorAnimation.value),
            ),
           ),
              ],
            )
           ),
             SizedBox(
              height: height*0.02,
            ),

            Container(
              height: height*0.55,
              width: width,
              child: defeated
              ?Center(
                child: MaterialButton(
                  onPressed: (){

                  },
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('Nice Effort. Your final Score is: '+ (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :finished
              ?Center(
                child: MaterialButton(
                  onPressed: (){},
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('You have finished the list', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :Center(
                child: PageView.builder(
                  allowImplicitScrolling: false,
                  itemCount: (footballerPairs.length),
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelecting(width, height, index, footballerPairs, null),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
           

              ],
            )
           : gameStarted
           ?Column(
              children: [
                Container(
              width: width*0.8,
              height: height*0.08,
             
              child: Center(
              child: Text(
                widget.category == 'age'?'Who is Older?':widget.category == 'height'
                ?'Who is taller?':widget.category == 'jersey'?'Who has higher Jersey Number?':'Who has more goals?',
                 style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: widget.category == 'jersey'?22:25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            ),
            ),
            SizedBox(
              height: height*0.03,
            ),
           Container(
            width: width*0.9,
            child:  LinearProgressIndicator(
             /*  color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555), */
              minHeight: 5,
              
              backgroundColor: Colors.transparent,
              value: timeLeft == divider?1:(timeLeft/(divider-1)).toDouble(),
              // value: _slideController.value,
             valueColor: AlwaysStoppedAnimation(wrongClick?finalColor:colorAnimation.value),
            ),
           ),
             SizedBox(
              height: height*0.02,
            ),

            Container(
              height: height*0.55,
              width: width,
              child: defeated
              ?Center(
                child: MaterialButton(
                  onPressed: (){

                  },
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('Nice Effort. Your final Score is: '+ (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :finished
              ?Center(
                child: MaterialButton(
                  onPressed: (){},
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('You have finished the list', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :Center(
                child: PageView.builder(
                  allowImplicitScrolling: false,
                  itemCount: (footballerPairs.length),
                itemBuilder: (context, index){
                 var item = footballers[index%5];
                  return Center(
                    child: playerSelecting(width, height, index, footballerPairs, null),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            

              ],
            )
            :startDown
            ?Container(
              height: height*0.6,
              width: width,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height*0.15,
                ),
                Center(
            child: Text(
                'Game Starts in', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          SizedBox(
            height: height*0.03,
          ),
           Center(
            child: Text(
                gamePlayTimeLeft.toInt().toString(), style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          
              ],
            )
            )
            :Container(
              height: height*0.6,
              width: width,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height*0.2,
                ),
                Center(
            child: Text(
                'Waiting for the game to start.', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
          
              ],
            )
            )
            
          ],
        ),
      ),
    
        ],
      ));
   }

   bool compare(var first, var second, bool reverse){
    if(reverse){
      return second>= first;
    }
    return first>=second;
   }

   Widget winnerWidget(var width, var height, DocumentSnapshot winner){
    return Column(
      children: [
        Container(
            width: width*0.6,
             height: height*0.12,
            child: Column(
              children: [
                Container(
                  child: Center(
                    child: Container(
                    width: width*0.5,
                    child: Text('@'+winner['userName'], style: TextStyle(color: Color(0xff63ff00), fontSize: width*0.09, fontFamily: 'Muli', fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                  )),
              width: width*0.55,
              height: height*0.1,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent
                 
              ),
            ),
         
              ],
            ),
          ),
          SizedBox(height: height*0.03,),
          Center(
            child: Text('Score: '+ winner['score'].toString(), style: TextStyle(color: Colors.white, fontSize: width*0.06, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          )
    ]);
   }

   Widget profileCircle(var width, var height, int index, dynamic data, AsyncSnapshot snapshot){
    List<dynamic> theList = snapshot.data['players'];
    bool active = theList.contains(data['uid']);
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Container(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: data['photoUrl']==null
                ?AssetImage('assets/grey.png')
                :CachedNetworkImageProvider(data['photoUrl']),
                fit: BoxFit.cover,
              )
            ),
            width: width*0.1,
      height: width*0.1,
          ),
          SizedBox(height: height*0.02,),
          Center(
            child: Text('@'+data['userName'], style: TextStyle(
              color: Colors.white, fontFamily:'Muli', fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic
            )),
          ),
          SizedBox(height: height*0.01,),
          Container(
            width: width*0.02,
            height: width*0.02,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active?Color(0xff23ff89):Color(0xffff2389)
            ),
          )
        ],
      ),
    )
    );}


   

   Widget playerSelect(var width, var height, int index, List<Map<String, dynamic>> footballer,  AsyncSnapshot<DocumentSnapshot> snapshot){
    return  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                playerCard(width, height, compare((footballer[0][widget.category]), footballer[1][widget.category], false),0, 0, footballer[0]['image'], footballer[0]['name'], snapshot, []),
                SizedBox(width: 20,),
                playerCard(width, height,  compare(footballer[1][widget.category], footballer[0][widget.category], false),0,1, footballer[1]['image'], footballer[1]['name'], snapshot, [])
              ],
            );
   }

   Widget playerSelecting(var width, var height, int index, List<List<String>> pageViewList,  AsyncSnapshot<DocumentSnapshot> snapshot){
    bool reversed = widget.category == "age";
    return  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                playerCard(width, height, compare(int.parse(footballerData[pageViewList[index][0]][widget.category]), int.parse(footballerData[pageViewList[index][1]][widget.category]), reversed),index, 0, assetData[pageViewList[index][0].toString()], footballerData[pageViewList[index][0]]["name"], snapshot, pageViewList),
                SizedBox(width: 20,),
                playerCard(width, height,  compare(int.parse(footballerData[pageViewList[index][1]][widget.category]), int.parse(footballerData[pageViewList[index][0]][widget.category]), reversed),index, 1,  assetData[pageViewList[index][1].toString()], footballerData[pageViewList[index][1]]["name"], snapshot, pageViewList)
              ],
            );
   }

   Widget playerCard(var width, var height, bool correct, int index1, int index, String image, String name, AsyncSnapshot<DocumentSnapshot> snapshot, List<List<String>> pageViewList){
    //  print(footballerData[footballerPairs[index1][index]]["name"]);
    return GestureDetector(
      onTap: (){
        print(footballerData[pageViewList[index1][index]][widget.category]);
        print(widget.category);
         print(footballerData[pageViewList[index1][index]]["name"]);
        if(wrongClick){
          print('wrong click');
        }
        
        else if(correct){
          correctPlayer.play();
          setState(() {
            correctPicked = true;
            currentPage = currentPage+1;
             _colorController = AnimationController(duration: Duration(seconds: (resetValue+0.2).toInt()), vsync: this);
           colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
         
            timeLeft = resetValue;
            divider = resetValue;
            _slideController.reset(); 
            _animation = new Tween<double>(begin: 0, end: 1).animate(
        new CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutCirc));
          });
          
          _animationController.forward().then((value) {
            Future.delayed(Duration(milliseconds: 200)).then((value){
              if(currentPage == (footballers.length)*10){
          setState(() {
            finished = true;
          });
         /*  Future.delayed(Duration(seconds: 1)).then((value) {
            correctPlayer.stop();
          }); */
        }
           else{
             setState((){
              correctPicked = false;
             });
             _pageController.animateToPage(currentPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
             _animationController.reset();
             _colorController.forward();
             
           }
           
            }); 
            Future.delayed(Duration(milliseconds: 200)).then((value) {
              correctPlayer.stop();
            });
          });
        }
        else{
          setState(() {
            finalColor = colorAnimation.value;
          animate = true;
          wrongClick = true;
          _colorController.reset();
          _animationController.repeat(reverse: true);
           _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });
    if(widget.solo){
      print('');
    }
    else{
      List<dynamic> players = snapshot.data['players'];
    if(players.length ==1){
      widget.public?_firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId):_firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
    }
   if(widget.public){
            print('stage478');
            _firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId).then((value) {
     _firebaseProvider.submitPublicUserScore(widget.variables.currentUser, widget.lobbyId, currentPage*10);
    });
          }
          else{
            print('stage255');
            _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId).then((value) {
      _firebaseProvider.submitUserScore(widget.variables.currentUser, widget.lobbyId, currentPage*10);
    });
          }
    }
        });
        Future.delayed(Duration(seconds: 3)).then((value) {
          setState(() {
            defeated = true;
            
          });
        });
        }
      },
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
        width: width*0.42,
        height: width*0.65,
        decoration: BoxDecoration(
          image: DecorationImage(
            
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [BoxShadow(
            color: animate?correct?Color(0xff63ff89):Color(0xffff3989):Colors.black,
            blurRadius: animate?_animation.value:0,
            spreadRadius: animate?_animation.value:0
          )],
          
          borderRadius: BorderRadius.circular(20)
        ),
        
      ), 
   
              
              correct && correctPicked?Align(
                alignment: Alignment.center,
                child: Container(
                  child: Center(
                    child: AnimatedCheck(
                      
                progress: _animation,
                size: 100,
                color: Color(0xff63ff89),
              ),
                  )),
              )
              :correct && wrongClick
              ?Align(
                alignment: Alignment.center,
                child: Container(
                  child: Center(
                    child: Icon(Icons.done, size: 100, color: Color(0xff63ff89),)
                  )),
              )
              :wrongClick?Align(
                alignment: Alignment.center,
                child: Container(
                  child: Center(
                    child: Icon(Icons.close, size: 100, color: Color(0xffff3989),)
                  )),
              ):Center()
            ],
          ),
          SizedBox(height: 10,),
      Container(
        width: width*0.45,
        child: Center(
          child:  Text(
                name, style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 20, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis,
              ),
        )
      )
        ],
      )
    );
   }


}