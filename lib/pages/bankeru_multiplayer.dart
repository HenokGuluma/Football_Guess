import 'dart:async';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:progress_indicators/progress_indicators.dart';

class BankeruMultiplayer extends StatefulWidget {

  String category;
  String lobbyId;
  String creatorId;
  int categoryNo;
  bool solo;
  int rate;
  bool public;
  UserVariables variables;
  Function startBackground;
 
  BankeruMultiplayer({
    this.category, this.lobbyId, this.public, this.rate, this.startBackground, this.solo, this.variables, this.creatorId, this.categoryNo,
  });

  @override
  BankeruMultiplayerState createState() => BankeruMultiplayerState();
}

class BankeruMultiplayerState extends State<BankeruMultiplayer>
    with TickerProviderStateMixin,  AutomaticKeepAliveClientMixin {
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

  Map<int, dynamic> cardMap = {
    0: 'A', 10: 'J', 11: 'Q', 12: 'K'
  };

  Map<int, Color> colorMap = {
    0: Color(0xffffffff), 1: Color(0xfffffff)
  };

  Map<int, String> typeMap = {
    0: 'assets/spade.svg', 1: 'assets/clubs.svg',  2: 'assets/heart_fill.svg', 3: 'diamond.svg'
  };

 

  List<String> categories = ['Jersey No.', 'Goals', 'Age', 'Height'];
  List<String> categoryId = ['jersey', 'goals', 'age', 'height'];

  List<List<Map<String, dynamic>>> BlackJack = 
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

  List<String> menuImages = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png'];

  int value = 0;
  int color = 0;
  int type = 0;

  AnimationController _animationController;
  AnimationController _slideController;
  AnimationController _colorController;
    AnimationController _bounceController;
  TextEditingController controller;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  PageController _pageController;
  Animation _animation;
  bool betting = false;
  Animation colorAnimation;
  bool animate = false;
  int bankerWallet = 0;
  bool correctPicked = false;
  int currentPage = 0;
  bool finished = false;
  int second = 8;
  double timeLeft = 8;
  double resetValue = 8;
  double gamePlayTimeLeft = 3;
  double divider = 8;
  double betPlaced = 0;
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
    var rng = Random();
  int playerAmount = 0;
  bool setupPlayers = true;
  dynamic playerInfos;
  dynamic playerInfotemp;
  bool resetColor = true;
  List<dynamic> playerList = [];
  List<dynamic> playerListOnline = [];
  List<Widget> drawnCards = [];
  Timer _timer;
  int _start = 100;
  bool randomizing = true;
  bool showRandomizing = true;
   List<int> cards = [];
   List<Map<String, dynamic>> cardValues = [];
   Map<String, dynamic> middleCard = {};
   bool middleCardDrawn = false;
   int score = 0;
   bool gameOver = false;
   bool switchedTurn = false;
   bool switchTurn = false;
   bool win = false;
  final player = AudioPlayer(); 
  final cancel = AudioPlayer();
  final selectPlayer = AudioPlayer();
  String activeUser = '';
  int missedChance = 0;
  bool randomizeBool = true;


 @override
  bool get wantKeepAlive => true;


  @override
  void initState() {
     _navigator = Navigator.of(context);

    super.initState();
    //  print('bankeruu');
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      // randomize();
    });
    startGamePlayCountDown();
    startSecondCountDown();
    setupSound();
      _bounceController = AnimationController(

      duration: Duration(milliseconds: 500),

      vsync: this,

      upperBound: 1.2,
      lowerBound: 1

    );
    _bounceController.forward();
_bounceController.repeat(reverse: true);
_bounceController.addListener(() {

      if(!disposed){
        setState(() {
           size = _bounceController.value;
      });
      }

     });
  }

   @override
  void dispose() {
    // _pageController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _colorController.dispose();
    // startTimer();
    _timer.cancel();
   
    super.dispose();
  }

  Future<void> setupSound() async{
    await player.setAsset('assets/glass.mp3');
    await selectPlayer.setAsset('assets/sound-effects/option-click-confirm.wav');
    await cancel.setAsset('assets/sound-effects/option-click.wav');
    selectPlayer.setVolume(0.1);
    cancel.setVolume(0.1);
    cancel.play();
    cancel.stop();
  }

  Future<void> changeActiveUser(String userId) async{
    if(widget.public){
      await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'activeUser': userId});
    }
    else{
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'activeUser': userId});
    }
    setState(() {
      switchedTurn = false;
      switchTurn = false;
    });
   return; 
  }

  skipTurn(List<dynamic> playerList, int index)async{
    if(missedChance >0){
      if(widget.public){
        _firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId);
      }
      else{
        _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
      }
    }
    else{
      setState(() {
        missedChance = missedChance+1;
      });
    }
    changeActiveUser(playerList[index]);
  }

  
   Future<void> editUserInLobby (String userId, String lobbyId) async{
    await _firestore.collection('lobbies').doc(lobbyId).update({'activeUser': userId});
  }

  void startTimer() {
  
  const oneSec = const Duration(milliseconds: 10);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      var added = 0;
      if(value <9){
        added = value+1;
      }
      else if(value == 0){
        added = 11;
      }
      else{
        added = 10;
      }
      if (_start == 0) {
        timer.cancel();
        cards.add(value);
        if(!middleCardDrawn){
          cardValues.add({'value': value, 'type': type});
        }
        
           if (cardValues.length<2){
            randomize();
            setState(() {
              score = score+added;
            });
          }
          else if(middleCardDrawn){
            print('shabobom');
             int low = cardValues[0]['value'];
            int high = cardValues[1]['value'];
            bool winner;
            if((low<value) && (value<high) || (high<value) && (value<low)){
              winner = true;
            }
            else{
              winner = false;
            }
             setState(() {
            middleCard = {'value': value, 'type': type};
            gameOver = true;
            win = winner;
            randomizing = false;
          });
          print(middleCard);
          }
          else{
           
             setState(() {
            showRandomizing = false;
          });
             Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
            score = score+added;
            randomizing = false;
            showRandomizing = true;
          });
          });
          }
         
         

         
      } else {
        // print(_start);
        setState(() {
          _start--;
          value = rng.nextInt(12);
          type = rng.nextInt(3);
        });
      }
    },
  );
}

 void startTurnTimer(List<dynamic> playerLists) {
  
  const oneSec = const Duration(milliseconds: 10);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      
      if (_start == 0) {
        timer.cancel();
         skipTurn(playerLists, playerLists.indexOf(widget.variables.currentUser.userName)+1);
      } else {
        // print(_start);
        setState(() {
          _start--;
          value = rng.nextInt(12);
          type = rng.nextInt(3);
        });
      }
    },
  );
}

void startGameTimer() {
  
  const oneSec = const Duration(milliseconds: 10);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      
      if (disposed) {
        
      } else if (gameStarted && !switchedTurn && switchTurn) {
       startTurnTimer(playerList);
       setState(() {
         switchedTurn = true;
       });
      }
    },
  );
}


  Future<void> getWinner() async{
    if(!widget.solo){
      setState(() {
      retrievingWinner = true;
    });
   Future.delayed(Duration(seconds: 10)).then((value) {
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

 void randomize(){
    // print('daaum');
    setState(() {
      _start = 100;
      randomizing = true;
      showRandomizing = true;
      
    });
    startTimer();
  }


  void startCountDown(){
    Timer.periodic(Duration(milliseconds: 100), (timer) { 
      if(disposed){
       
      }
      else if(paused){

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

  shuffleCard(Map<String, dynamic> card)async{
    if(!widget.public){
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'shuffle': true, 'cardValue': card});
      Future.delayed(Duration(seconds: 1)).then((value) async {
        await _firestore.collection('lobbies').doc(widget.lobbyId).update({'shuffle': false});
      });
    }
    else{
       await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'shuffle': true, 'cardValue': card});
      Future.delayed(Duration(seconds: 1)).then((value) async {
        await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'shuffle': false});
      });
    }
    
  }

   twoCards(List<Map<String, dynamic>> cards)async{
    if(!widget.public){
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'shuffle': true, 'initialCards': cards});
      Future.delayed(Duration(seconds: 1)).then((value) async {
        await _firestore.collection('lobbies').doc(widget.lobbyId).update({'shuffle': false});
      });
    }
    else{
       await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'shuffle': true, 'initialCards': cards});
      Future.delayed(Duration(seconds: 1)).then((value) async {
        await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'shuffle': false});
      });
    }
    
  }

  placeBet(int amount, AsyncSnapshot snapshot) async{
    Map<String, dynamic> betsPlaced = snapshot.data['betsPlaced'];
    int betLeft = snapshot.data['betLeft'];
    betsPlaced[widget.variables.currentUser.userName] = amount;
    if(widget.public){
      await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'betsPlaced': betsPlaced});
    }
    else{
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'betsPlaced': betsPlaced});
    }
  }


  void startSecondCountDown(){
    Timer.periodic(Duration(milliseconds: 1000), (timer) { 
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

      if(setupPlayers && playerInfotemp!=null){
        List<dynamic> list =  playerInfotemp.entries.map( (entry) => entry.value).toList();
        setState(() {
          playerList = playerListOnline;
          playerInfos = playerInfotemp;
          setupPlayers = false;
        });
      }

      if(randomizeBool && gameStarted){
        randomize();
        setState(() {
          randomizeBool = false;
        });
      }
      // print(playerAmount); print(' is the amount');

    });
  }

  void stopGame(){
     _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
  }

void checkGameStatus(){
  if(lastPlayer){
    stopGame();
  }
}

void handleTimeout() {  // callback function
  setState(() {
          animate = true;
          wrongClick = true;
          _animationController.repeat(reverse: true);
           _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });
        });
        if(!widget.solo){
          _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId).then((value) {
      _firebaseProvider.submitUserScore(widget.variables.currentUser, widget.lobbyId, currentPage*10);
    });
       if(lastPlayer){
        stopGame();
       }
        }
        Future.delayed(Duration(seconds: 5)).then((value) {
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
          else if(snapshot.data['players'].length <1){
            shouldGetWinner = true;
          }

          if(snapshot.data['active']){
             startDown = true;
            
          }
           
          else{
             startDown = false;
            
          }

          if(snapshot.data['activeUser'] == widget.variables.currentUser.userName){
            switchTurn = true;
          }
          else{
            switchTurn = false;
          }
        }
        else{
         print('bowwwnce');
        }
        return gameScreen(width, height, snapshot);})
        );
   
   }

   double calculateWinnings (int total){
    return total*0.95;
   }

   searchQuery(String text){
    setState(() {
      betPlaced = double.parse(text);
    });
   }

   Widget gameScreen(var width, var height, AsyncSnapshot snapshot){
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/blackjack_wallpaper.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          Center(
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 
                   SizedBox(
                height: height*0.08,
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
            snapshot.data['active'] && gameStarted
            ?Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                    Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: height*0.05,
                          ),
                          Text('Bank Vault', style: TextStyle(color: Color(0xff00ffff), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          Text('5000 ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                           SizedBox(
                            height: height*0.05,
                          ),
                          Text('Wallet', style: TextStyle(color: Color(0xff23ff34), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          Text(widget.variables.currentUser.coins.toString() + ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
          ,
                        ],
                      ),
                      Container(
                    height: height*0.3,
                    child: (showRandomizing?randomizing||middleCardDrawn?card(width, height, {'value': value, 'type': type}, 0):cardBack(width, height):Center()),
                  ),
                  Container(
                    width: width*0.1,
                  ),
                    ],
                  )
                ),
                SizedBox(
                  height: height*0.05,
                ),
                Row(
                  children: [
                   
                    Container(
              width: width,
              height: height*0.3,
              child: Center(
                child: cardValues.length>0 || randomizing
                ?Stack(
            alignment: cardValues.length>1?Alignment.centerLeft:Alignment.center,
              // scrollDirection: Axis.horizontal,
              children: 
                cardValues.map((item) {
                                      return card(width, height, item, cardValues.indexOf(item));
                                    }).toList()
              
        
          )
          :Text('Press the deck to draw', style: TextStyle(color: Color(0xff00ffff), fontSize: 25, fontFamily: 'Muli', fontWeight: FontWeight.w900))
          ,
              )
            ), 
            
                  ],
                ),
          SizedBox(height: height*0.05,),
            !(randomizing) && gameOver
            ?Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                win
                ?Container(
              decoration: BoxDecoration(
                color: Color(0xff23ff12),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Winner', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ):Container(
              decoration: BoxDecoration(
                color: Color(0xffff2389),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Loser', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
                GestureDetector(
            onTap: (){
              setState(() {
                gameOver = false;
                cardValues = [];
                middleCard = {};
                middleCardDrawn = false;
                win = false;
              });
              randomize();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Try Again', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
              ],
            )
            :!randomizing
            ?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     GestureDetector(
            onTap: (){
              cancel.play();
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
                                  cancel.play();
                                  checkGameStatus();
                                  _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                //  _bounceController.reset();
                  // _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context);
                  Future.delayed(Duration(seconds: 1)).then((value) {
                cancel.stop();
                });
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
                        Future.delayed(Duration(seconds: 1)).then((value) {
                cancel.stop();
                });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffff2389),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Leave', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
            betting
            ?Container(
              decoration: BoxDecoration(
                // color: Color(0xff23ff34),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: TextField(
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900), textAlign: TextAlign.center,
                              controller: controller,
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.white,
                              autofocus: false,
                              focusNode: FocusNode(),
                              cursorHeight: 20,
                              maxLength: 20,
                              cursorWidth: 0.5,
                              onChanged: searchQuery,
                               inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')),
              ],
                              decoration: InputDecoration(
                                
                                  hintText: 'Bet in ETB',
                                  // contentPadding: EdgeInsets.only(bottom: 20),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff999999),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900)),
                            ),
            
              ))
            :GestureDetector(
            onTap: (){
              setState(() {
                betting = true;
              });
               selectPlayer.play();
               
             
              Future.delayed(Duration(seconds: 1)).then((value) {
                selectPlayer.stop();
                });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff23ff34),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Place Bet', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
            betting
            ?GestureDetector(
            onTap: (){
              setState(() {
                disposed = true;
              });
              checkGameStatus();
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text('Confirm Bet', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
            :GestureDetector(
            onTap: (){
              setState(() {
                disposed = true;
              });
              checkGameStatus();
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
                child: Text('Skip turn', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
                  ],
                 )
                 :GestureDetector(
            onTap: (){
              cancel.play();
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
                                  cancel.play();
                                  checkGameStatus();
                                  _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                //  _bounceController.reset();
                  // _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context);
                  Future.delayed(Duration(seconds: 1)).then((value) {
                cancel.stop();
                });
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
                        Future.delayed(Duration(seconds: 1)).then((value) {
                cancel.stop();
                });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffff2389),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Leave', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
                 ,
           
              ],
            )
            :Center(
              child: startDown
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
                gamePlayTimeLeft.toInt().toString(), style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          
              ],
            )
            )
            : widget.variables.currentUser.uid == widget.creatorId
            ?Container(
              height: height*0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height*0.2,
                  ),
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
                  _firebaseProvider.startLobbyGame(widget.creatorId, widget.lobbyId);
                },
                child:  Container(
                   width: width*0.4,
              height: width*0.4,
                  child: Column(
                    children: [
                      Container(
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
                    ],
                  ),
                )
              ),
              SizedBox(height: height*0.1,),
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
                                  checkGameStatus();
                                  _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  Navigator.pop(context);
                                //  _bounceController.reset();
                  // _animationController.reset();
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
              ))
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
                                  checkGameStatus();
                                  _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
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
              ,
            )
            ])
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
                image: AssetImage('assets/blackjack_wallpaper.png'),
                fit: BoxFit.cover
              )
            ),
            child: card( width, height, {}, 0),
          ),
          Container()
        ],
      ));
   }

   bool compare(var first, var second){
    return first>second;
   }

   Widget symbolLetter(String value, Color color, int type, var width, var height){
    // print(typeMap[type]);
    return Container(
      width: width*0.1,
      height: width*0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: color, fontFamily: 'Muli', fontWeight: FontWeight.w900, fontSize: width*0.05),),
          SvgPicture.asset(typeMap[type],  color: color, width: width*0.05, height: width*0.05,)
        ],
      ),
    );
   }

 
   Widget cardBack(var width, var height){
    String cardValue = '';
    Map<int, String> map;
    if (value <1 || value >9){
      cardValue = cardMap[value];
    }
    else{
      cardValue = (value+1).toString();
    }

    return GestureDetector(
         onTap: (){
          setState(() {
            middleCardDrawn = true;
          });
        randomize();
      },
      child: Container(
      width: width*0.35,
      height: height*0.3,
      decoration: BoxDecoration(
               
                color: Colors.black,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [Colors.black, Color(0xff180018), Color(0xff300030)]
                ),
                 boxShadow: [BoxShadow(
            color: Colors.white,
            blurRadius: 3,
            spreadRadius: 3
          )],
          borderRadius: BorderRadius.circular(15)
              ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: width*0.01,
          ),
         /* Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: width*0.02),
              child: Container(
                width: width*0.08,
                height: width*0.08,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/banker-removed.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              ),
              Padding(
              padding: EdgeInsets.only(right: width*0.02),
              child: Container(
                width: width*0.08,
                height: width*0.08,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/banker-removed.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              ),
          ],
         ), */
          Center(
            child: Container(
                width: width*0.3,
                height: width*0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bankeru-new.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
          ),
          /* Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: width*0.02),
              child: Container(
                width: width*0.08,
                height: width*0.08,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/banker-removed.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              ),
              Padding(
              padding: EdgeInsets.only(right: width*0.02),
              child: Container(
                width: width*0.08,
                height: width*0.08,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/banker-removed.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              ),
          ],
         ),
           */
          SizedBox(
            height: width*0.01,
          )
        ]
      ),
    )
  ,
    ); }


   Widget card(var width, var height, Map<String, dynamic> item, int index){
    String cardValue = '';
    var value = item['value'];
    var color = Colors.black;
    var type = item['type'];
    Map<int, String> map;
    if (value <1 || value >9){
      cardValue = cardMap[value];
    }
    else{
      cardValue = (value+1).toString();
    }


    // print(typeMap[type]); print('babbby');

    Color cardColor = Colors.black;

    if(type ==2 || type ==3){
      cardColor = Colors.red;
    }

    return Padding(
      padding: EdgeInsets.only(left: index*width*0.15),
      child: Container(
      width: width*0.35,
      height: height*0.3,
      decoration: BoxDecoration(
               
                color: Colors.black,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [Colors.white, Color(0xffe2ffff), Color(0xffbbffff)]
                ),
                /*  boxShadow: [BoxShadow(
            color: Colors.white,
            blurRadius: 3,
            spreadRadius: 3
          )], */
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black)
              ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: width*0.007,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: symbolLetter(cardValue, cardColor, type, width, height),
          ),
          SvgPicture.asset(typeMap[type], color: cardColor, width: width*0.2, height: width*0.2,),
          Align(
             alignment: Alignment.bottomRight,
             child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(pi),
              child: symbolLetter(cardValue, cardColor, type, width, height),
             ),
          ),
          SizedBox(
            height: width*0.007,
          )
        ]
      ),
    ));
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
          // SizedBox(height: height*0.02,),
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
                playerCard(width, height, compare(footballer[0][widget.category], footballer[1][widget.category]), 0, footballer[0]['image'], footballer[0]['name'], snapshot),
                SizedBox(width: 20,),
                playerCard(width, height,  compare(footballer[1][widget.category], footballer[0][widget.category]), 1, footballer[1]['image'], footballer[1]['name'], snapshot)
              ],
            );
   }

   Widget playerCard(var width, var height, bool correct, int index, String image, String name, AsyncSnapshot<DocumentSnapshot> snapshot){
    return GestureDetector(
      onTap: (){
        if(wrongClick){
          // print('wrong click');
        }
        
        else if(correct){
          setState(() {
            correctPicked = true;
            currentPage = currentPage+1;
             _colorController = AnimationController(duration: Duration(seconds: resetValue.toInt()), vsync: this);
           colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
          _colorController.forward();
            timeLeft = resetValue;
            divider = resetValue;
            _slideController.reset(); 
            _animation = new Tween<double>(begin: 0, end: 1).animate(
        new CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutCirc));
          });
          
          _animationController.forward().then((value) {
            Future.delayed(Duration(milliseconds: 200)).then((value){
              if(currentPage == (BlackJack.length)*10){
          setState(() {
            finished = true;
          });
        }
           else{
             setState((){
              correctPicked = false;
             });
             _pageController.animateToPage(currentPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
             _animationController.reset();
            
           }
            }); 
          });
        }
        else{
          setState(() {
          animate = true;
          wrongClick = true;
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
      _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
    }
    _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId).then((value) {
      _firebaseProvider.submitUserScore(widget.variables.currentUser, widget.lobbyId, currentPage*10);
    });
    }
        });
        Future.delayed(Duration(seconds: 5)).then((value) {
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
      Text(
                name, style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 22, fontWeight: FontWeight.w900),
              ),
        ],
      )
    );
   }


}