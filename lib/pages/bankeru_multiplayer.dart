import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
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
import 'package:instagram_clone/models/user.dart';
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
  Function returnBack;
 
  BankeruMultiplayer({
    this.category, this.lobbyId, this.returnBack, this.public, this.rate, this.startBackground, this.solo, this.variables, this.creatorId, this.categoryNo,
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

  List<Map<String, dynamic>> tempCards = [{'value': 12, 'type': 0}, {'value': 9, 'type': 2}];
  Map<String, dynamic> tempCard = {'value': 6, 'type': 1};

  List<String> menuImages = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png'];

  int value = 0;
  int color = 0;
  int type = 0;

  AnimationController _animationController;
  AnimationController _slideController;
  AnimationController _colorController;
    AnimationController _bounceController;
  TextEditingController controller = TextEditingController();
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
  bool betPlaced = false;
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
  Timer _gameTimer;
  Timer turnTimer;
  Timer _skipTimer;
  int _start = 800;
  bool randomizing = true;
  bool showRandomizing = true;
   List<int> cards = [];
   List<Map<String, dynamic>> cardValues = [];
   List<dynamic> onlineCardValues = [];
   Map<String, dynamic> middleCard = {};
   List<Map<String, dynamic>> displayCards = [];
   Map<String ,dynamic> displayMiddleCard = {};
   dynamic onlinefinalCard = {};
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
  int winnings = 0;
  String nextUser = '';
  bool randomizeBool = true;
  int skipTimer = 10;
  bool shouldStartSkipTimer = false;
  bool startedSkipTimer = false;
  bool shouldCheckBet = true;
  bool skipButton = false;
  bool turnCancelled = false;
  bool skipped = false;
  bool shouldSkip = false;
  bool shouldRandomize = false;
  bool didRandomize = false;
  int bankVault = 0;
  bool timeAdjusted = false;
  bool timeLeftAdjusted = false;
  int betLeftOnline = 0;
  int betLeft = 5;
  int displayWinnings = 0;
  bool initialStart = true;
  int playerTurns = 0;
  int betAmount = 0;
  bool emptyScreen = false;
  var focusNode = FocusNode();
  bool emptyScreenToggled = false;


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
    startTurnTimer(playerList);
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
   _gameTimer.cancel();
   turnTimer.cancel();
   _skipTimer.cancel();
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
    var increment = FieldValue.increment(1);
    if(widget.public){
      await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'activeUser': userId, 'playerTurns': increment});
    }
    else{
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'activeUser': userId, 'playerTurns': increment});
    }
    setState(() {
      skipTimer = 10;
      switchedTurn = false;
      switchTurn = false;
    });
    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        shouldSkip = true;
      });
    });
   return; 
  }

  skipTurn(dynamic player, bool idle)async{
    if(!idle){
      print('skipped voluntarily');
      setState(() {
        missedChance = 0;
      });
    }
    else if(missedChance >0){
      print('waka waka');
      if(widget.public){
        _firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId);
      }
      else{
        _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
      }
    }
    else{
      print('lazy ass');
      setState(() {
        missedChance = missedChance+1;
      });
    }
    print(' turn is '); print(playerTurns);
    print(' length is '); print(playerList.length -1 );
    if(playerTurns == playerList.length-1 || betLeft == 0){
      roundCompleteLobby(widget.variables.currentUser.uid, widget.lobbyId);
      int cardValue1 = rng.nextInt(13);
      int cardType1 = rng.nextInt(3);
      finalCard({'type': cardType1, 'value': cardValue1});
       Future.delayed(Duration(seconds: 6)).then((value) {
        resetLobby(widget.variables.currentUser.uid, widget.lobbyId, bankVault);
      });
    }
     else{
      print(' not randomizing');
    }
    changeActiveUser(nextUser);
    
  }



  
   Future<void> editUserInLobby (String userId, String lobbyId) async{
    if(widget.public){
      await _firestore.collection('publicLobbies').doc(lobbyId).update({'activeUser': userId});
    }
    else{
      await _firestore.collection('lobbies').doc(lobbyId).update({'activeUser': userId});
    }
    return;
  }

  Future<void> roundCompleteLobby (String userId, String lobbyId) async{
    if(widget.public){
      await _firestore.collection('publicLobbies').doc(lobbyId).update({'roundCompleted': true});
    }
    else{
      await _firestore.collection('lobbies').doc(lobbyId).update({'roundCompleted': true});
    }
    return;
  }

  Future<void> handleWin(int winning) async{
    int added = (winning*0.95*2).toInt();
    var increment = FieldValue.increment(added);
    var decrement = FieldValue.increment(0-winning);
    setState(() {
      displayWinnings = added;
      winnings = added;
    });
    print(' let us goooooo.');
     if(widget.public){
      await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'vault': decrement});
    }
    else{
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'vault': decrement});
    }
    
    await _firestore.collection('users').doc(widget.variables.currentUser.uid).update({'coins': increment});

  }

   Future<void> handleLose(int winnings) async{
    var increment = FieldValue.increment(winnings);
    var decrement = FieldValue.increment(0-winnings);
     if(widget.public){
      await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'vault': increment});
    }
    else{
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'vault': increment});
    }
    
    // await _firestore.collection('users').doc(widget.variables.currentUser.uid).update({'coins': decrement});
  }

  Future<void> resetLobby (String userId, String lobbyId, int vault) async{

    if(widget.public){
      await _firestore.collection('publicLobbies').doc(lobbyId).update({'roundCompleted': false, 'betsPlaced': {}, 'playerTurns': 0, 'betsLeft': vault, 'initialCards': [], 'finalCard': {}, 'active': false, });
    }
    else{
      await _firestore.collection('lobbies').doc(lobbyId).update({'roundCompleted': false, 'betsPlaced': {}, 'playerTurns': 0,'betsLeft': vault, 'initialCards': [], 'finalCard': {}, 'active': false});
    }
    setState(() {
      didRandomize = false;
      cardValues = [];
      middleCard = {};
      middleCardDrawn = false;
      skipTimer = 10;
      gamePlayTimeLeft = 3;
      _start = 400;
      skipped = false;
      missedChance = 0;
      betPlaced = false;
      betting = false;
      randomizeBool = true;
      shouldCheckBet = true;
      gameStarted = false;
      switchedTurn = false;
      timeAdjusted = false;
      betLeft = 5;
      timeLeftAdjusted = false;
      // gamePlayTimeLeft = 0;
      betPlaced = false;
      
    });

    Future.delayed(Duration(seconds: 5)).then((value) {
      setState(() {
         displayCards = [];
      displayMiddleCard = {};
      });
    });
    return;
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
          if(cardValues.length == 0){
            cardValues.add(onlineCardValues[0]);
            displayCards.add(onlineCardValues[0]);
          }
          else if(cardValues.length ==1){
            cardValues.add(onlineCardValues[1]);
            displayCards.add(onlineCardValues[1]);
          }
          // cardValues.add({'value': value, 'type': type});
        }
        else{
          middleCard = onlinefinalCard;
          // displayMiddleCard = onlinefinalCard;
        }
        
           if (cardValues.length<2){
            randomize();
            setState(() {
              score = score+added;
            });
          }
          else if(middleCardDrawn /* && betPlaced */){
            print('shabobom');
             int low = cardValues[0]['value'];
            int high = cardValues[1]['value'];
            int thisValue = onlinefinalCard['value'];
            bool winner;
            if(((low<thisValue) && (thisValue<high)) || ((high<thisValue) && (thisValue<low))){
              winner = true;
            }
            else{
              winner = false;
            }
            if(winner && betPlaced){
              print('winnner1');
              handleWin(betAmount);
            }
            else if (!winner && betPlaced){
              print('loserrrrr');
              handleLose(betAmount);
            }
             /* setState(() {
            middleCard = {'value': value, 'type': type};
          }); */
          Future.delayed(Duration(seconds: 2)).then((value){
            setState(() {
            gameOver = true;
            win = winner;
            randomizing = false;
            });
          });

          print(middleCard);
          Future.delayed(Duration(seconds: 8)).then((value) {
            setState(() {
              gameOver = false;
              win = false;
              middleCard = {};
              betPlaced = false;
              skipped = false;
            });
          });
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
            timeLeft = 8;
          });
          startGameTimer();
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
  print('turn timer started');
  const oneSec = const Duration(milliseconds: 1000);
  turnTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      // print(gameStarted); print(' is game started');
      // print(timeLeftAdjusted);
      if(turnCancelled || skipped || !gameStarted || !timeLeftAdjusted || betPlaced || disposed || didRandomize){
        // print('whoops');
      }
      else if (timeLeft == 0) {
        print('shazaaam');
        // timer.cancel();
        setState(() {
          turnCancelled = true;
        });
         skipTurn(widget.variables.currentUser.uid, true);
      } else {
        // print(_start);
        setState(() {
          timeLeft--;
          value = rng.nextInt(12);
          type = rng.nextInt(3);
        });
      }
      // print(activeUser);
    },
  );
}

void startGameTimer() {
  print('started game timer');
  print(gameStarted); print(switchedTurn); print(switchTurn);
  const oneSec = const Duration(milliseconds: 10);
  _gameTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      
      if (disposed) {
        
      } else if (gameStarted && !switchedTurn && switchTurn && !timeAdjusted) {
        print('booom');
        setState(() {
          timeLeft = 8;
          timeAdjusted = true;
          turnCancelled = false;
          skipped = false;
        });
       setState(() {
         switchedTurn = true;
       });
      }
    },
  );
}

void startSkipTimer() {
  
  const oneSec = const Duration(milliseconds: 1000);
  _skipTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      
      if (disposed || didRandomize || !gameStarted) {
        
      } 
      else if(skipTimer == 0 && shouldSkip){
        // print('eeerrrrooooorrrrrrrrr');
        setState(() {
          skipButton = true;
        });
      }
      else{
        skipTimer--;
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
        // handleTimeout();
      }

      
     
    });
  }

  void startGamePlayCountDown(){
    Timer.periodic(Duration(milliseconds: 1000), (timer) { 
      
      if(disposed){
       
      }
       else if(paused){

      }
      else if(!startDown){
       
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

        if(!timeLeftAdjusted){
          print('adjusted the time');
          setState(() {
            timeLeftAdjusted = true;
            timeLeft = 8;
          });
        }
        
        setState(() {
          gameStarted = true;
        });
      }
     
      
    });
  }

  void showVaultFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 0,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Color(0xff00ffff), Color(0xff00ffff)],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: Text(
        'Please bet an amount not higher than the bank vault balance.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black),
      )),
    )..show(context);
  }

   void showWalletFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 0,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Color(0xff00ffff), Color(0xff00ffff)],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: Text(
        'Please bet an amount not higher than your wallet balance.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black),
      )),
    )..show(context);
  }

   void showValidFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 0,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Color(0xff00ffff), Color(0xff00ffff)],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: Text(
        'Please enter a valid number for a bet.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black),
      )),
    )..show(context);
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

  finalCard(Map<String, dynamic> card)async{
    if(!widget.public){
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'finalCard': card, 'shuffle': true});
      Future.delayed(Duration(seconds: 1)).then((value) async {
        await _firestore.collection('lobbies').doc(widget.lobbyId).update({'shuffle': false});
      });
    }
    else{
       await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'finalCard': card, 'shuffle': true});
      Future.delayed(Duration(seconds: 1)).then((value) async {
        await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'shuffle': false});
      });
    }

    setState(() {
      displayMiddleCard = card;
    });
    
  }

  Future<void>vaultBet() async{
    var increment = FieldValue.increment(widget.rate);
    var decrement = FieldValue.increment(0-widget.rate);
     if(widget.public){
      await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'vault': increment, 'betsLeft': increment,});
    }
    else{
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'vault': increment, 'betsLeft': increment,});
    }

    await _firestore.collection('users').doc(widget.variables.currentUser.uid).update({'coins': decrement});
  }

  placeBet(int amount, AsyncSnapshot snapshot) async{
    Map<String, dynamic> betsPlaced = snapshot.data['betsPlaced'];
    int betLeftHere = snapshot.data['betLeft'];
    betsPlaced[widget.variables.currentUser.userName] = amount;
    betLeftHere = betLeftOnline - amount;
    setState(() {
      betAmount = amount;
    });
    var increment = FieldValue.increment(amount);
    var decrement = FieldValue.increment(0-amount);
    if(widget.public){
      await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'betsPlaced': betsPlaced, 'betsLeft': betLeftHere,});
    }
    else{
      await _firestore.collection('lobbies').doc(widget.lobbyId).update({'betsPlaced': betsPlaced, 'betsLeft': betLeftHere,});
    }
    await _firestore.collection('users').doc(widget.variables.currentUser.uid).update({'coins': decrement});
    /* User user = widget.variables.currentUser;
    user.coins = user.coins - amount;
    widget.variables.setCurrentUser(user);
    setState(() {
      
    }); */
      if(playerTurns == playerList.length-1 || betLeft == 0){
      roundCompleteLobby(widget.variables.currentUser.uid, widget.lobbyId);
      int cardValue1 = rng.nextInt(13);
      int cardType1 = rng.nextInt(3);
      finalCard({'type': cardType1, 'value': cardValue1});
      Future.delayed(Duration(seconds: 6)).then((value) {
        resetLobby(widget.variables.currentUser.uid, widget.lobbyId, bankVault);
      });
    }
     else{
      print(' not randomizing');
    }
    changeActiveUser(nextUser);
    
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
          // playerList = playerListOnline;
          playerInfos = playerInfotemp;
          setupPlayers = false;
        });
      }
      
      if(!disposed){
        setState(() {
        playerList = playerListOnline;
      });
      }

      if(randomizeBool && gameStarted && !disposed){
        randomize();
        setState(() {
          randomizeBool = false;
        });
      }

      if(shouldStartSkipTimer && !startedSkipTimer){
        print('major error');
        setState(() {
          skipTimer = 10;
        });
        setState(() {
          shouldSkip = true;
          startedSkipTimer = true;  
        });
        startSkipTimer();
      }

      if(shouldRandomize && !didRandomize){
        
        setState(() {
          didRandomize = true;
          middleCardDrawn = true;
        });
        randomize();
      }

      if(shouldCheckBet && betLeftOnline == 0 && !disposed){
        setState(() {
          betLeft = 0;
          shouldCheckBet = false;
        });
      }

      if(!emptyScreenToggled && bankVault <= 0 && !disposed){
        setState(() {
          emptyScreen = true;
          emptyScreenToggled = true;
        });
      }
      // print(playerAmount); print(' is the amount');

    });
  }

  void stopGame(){
     _firebaseProvider.stopBankeruLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
  }

void checkGameStatus(){
  if(playerList.length<3){
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

          if(snapshot.data['activeUser'] == widget.variables.currentUser.uid){
            switchTurn = true;
          }
          else if (snapshot.data['activeUser'] != activeUser && gameStarted){
            shouldStartSkipTimer = true;
            switchTurn = false;
          }
          else{
            switchTurn = false;
          }

          activeUser = snapshot.data['activeUser'];

          int indexPlayer = playerList.indexOf(snapshot.data['activeUser']);
          if(indexPlayer == playerList.length - 1 && playerList.length!=0){
            nextUser = playerList[0];
          }
          else if (playerList.length!=0){
            nextUser = playerList[indexPlayer+1];
          }

          if(snapshot.data['roundCompleted']){
            shouldRandomize = true;
          }
          else{
            shouldRandomize = false;
          }
          onlineCardValues = snapshot.data['initialCards'];
          onlinefinalCard = snapshot.data['finalCard'];
          bankVault = snapshot.data['vault'];
          betLeftOnline = snapshot.data['betsLeft'];
          playerTurns = snapshot.data['playerTurns'];
          
        }
        else{
         print('bowwwnce');
        }
        return gameOver?finalScreen(width, height, snapshot):(bankVault<1 && !snapshot.data['active']) || (emptyScreen && !betPlaced)?betScreen(width, height, snapshot):gameScreen(width, height, snapshot);})
        );
   
   }

   double calculateWinnings (int total){
    return total*0.95;
   }

   searchQuery(String text){
    setState(() {
      
    });
   }

   Widget finalScreen(var width, var height, AsyncSnapshot snapshot){
  return Scaffold(
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
                height: height*0.05,
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
            
              !betPlaced
              ?Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            SizedBox(
              height: height*0.02,
            ),
             Text(
                'Round Over', style: TextStyle(color: Color(0xff63ff00), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 Transform.scale(
                  child: Container(
              width: width*0.5,
              height: height*0.3,
              child: Center(
                child: Stack(
            alignment: displayCards.length>1?Alignment.centerLeft:Alignment.center,
              // scrollDirection: Axis.horizontal,
              children: 
                displayCards.map((item) {
                                      return card(width, height, item, displayCards.indexOf(item));
                                    }).toList()
              
        
          )
          ,
              )
            ),
                  scale: 0.6,
                 ),
                 Transform.scale(
                  scale: 0.6,
                  child: card(width, height, displayMiddleCard, 0),
                 )

              ],
            ),
            Stack(
              children: [
                Opacity(
                  opacity: 0.2,
                  child:  Container(
              width: width*0.7,
              height: height*0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white
              ),
            ),
                  ), 
            Container(
              width: width*0.7,
              height: height*0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView(
                children: [
                 Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Bank Vault', style: TextStyle(color: Color(0xff00ffff), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                      Text(snapshot.data['vault'] == null?'0 ETB':snapshot.data['vault'].toString()+ ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                    ],
                  ),
                  SizedBox(
                    height: height*0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       Text('Bet Left', style: TextStyle(color: Color(0xff00ffff), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          // Text(snapshot.data['betLeft'] == null?'0 ETB':snapshot.data['betLeft'].toString()+ ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          Text(betLeftOnline == null?'0 ETB':betLeftOnline.toString()+ ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          
                    ],
                  ),
                   SizedBox(
                    height: height*0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       Text('Wallet', style: TextStyle(color: Color(0xff23ff34), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          Text(widget.variables.currentUser.coins.toString() + ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                    ],
                  ),
                ],
              ),
            )
              ],
            ),
             /*  SizedBox(
              height: height*0.1,
            ), */
            ]))
              
              :win
              ?Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             SizedBox(
              height: height*0.15,
            ),
             Text(
                'Congratulations', style: TextStyle(color: Color(0xff63ff00), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.15,
            ),
           Text(
                'You have won this round.', style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.1,
            ),
             Text(
                'Total Winnings: ' + displayWinnings.toString(), style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.1,
            ),
            ]))
              :Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height*0.15,
            ),
             Text(
                'Tough Luck', style: TextStyle(color: Color(0xffff2340), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
               SizedBox(
              height: height*0.05,
            ),
            Text(
                'You lost this round.', style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.1,
            ),
              SizedBox(
              height: height*0.1,
            ),
             Text(
                'Wallet: ' + widget.variables.currentUser.coins.toString() + ' ETB', style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.1,
            ),
            ]))
          
            ])),
      ],
    ),
  );
}
   
   Widget betScreen(var width, var height, AsyncSnapshot snapshot){
  return Scaffold(
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
                height: height*0.05,
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
             SizedBox(
                height: height*0.1,
              ),
             Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Text(
                'Vault Is Empty', style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.05,
            ),
           Text('Would you like to Bet more?', style: TextStyle(color: Color(0xff00ffff), fontSize: 25, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                           SizedBox(
                            height: height*0.1,
                          ),
                          Text('Bet Amount: ' + widget.rate.toString() + ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 30, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          // Text(snapshot.data['betLeft'] == null?'0 ETB':snapshot.data['betLeft'].toString()+ ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          
                          SizedBox(
                            height: height*0.03,
                          ),
                          Text('Wallet: ' + widget.variables.currentUser.coins.toString() + ' ETB', style: TextStyle(color: Color(0xff23ff34), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                         SizedBox(
                            height: height*0.05,
                          ), 
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  _navigator.pop(context); widget.returnBack();
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
           
            GestureDetector(
            onTap: (){
              vaultBet().then((value){
                setState(() {
                  emptyScreen = false;
                });
              });
                         },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Bet', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
           ],
                 ),
             
             
            ]))
             
            ])),
      ],
    ),
  );
}
   


   Widget gameScreen(var width, var height, AsyncSnapshot snapshot){
    List<dynamic> removedList = playerList.where((i) => i!=activeUser).toList();
    // print(removedList);
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
            
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 
                   SizedBox(
                height: height*0.02,
              ),
              activeUser == ''||playerInfos==null
              ?Container(
              height: height*0.15,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                    return profileCircle(width, height, index, playerInfos[ playerList[index]], snapshot);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: playerList.length,
                ),
            )
            :Container(
              height: height*0.15,
              child:
                   ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                  if(index == 0){
                     return profileCircle(width, height, index, playerInfos[activeUser], snapshot);
                  }
                    return profileCircle(width, height, index, playerInfos[ removedList[index - 1]], snapshot);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: removedList.length + 1,
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
                      Stack(
              children: [
                Opacity(
                  opacity: 0.2,
                  child:  Container(
              width: width*0.5,
              height: height*0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white
              ),
            ),
                  ), 
            Container(
              width: width*0.5,
              height: height*0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: ListView(
                children: [
                  SizedBox(
                    height: height*0.02,
                  ),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Bank Vault', style: TextStyle(color: Color(0xff00ffff), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                      Text(snapshot.data['vault'] == null?'0 ETB':snapshot.data['vault'].toString()+ ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                    ],
                  ),
                  SizedBox(
                    height: height*0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       Text('Bet Left', style: TextStyle(color: Color(0xff00ffff), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          // Text(snapshot.data['betLeft'] == null?'0 ETB':snapshot.data['betLeft'].toString()+ ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          Text(betLeftOnline == null?'0 ETB':betLeftOnline.toString()+ ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          
                    ],
                  ),
                   SizedBox(
                    height: height*0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       Text('Wallet', style: TextStyle(color: Color(0xff23ff34), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                          Text(widget.variables.currentUser.coins.toString() + ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                    ],
                  ),
                ],
              ),
            
              ))
              ],
            ),
            
                      randomizing || middleCardDrawn
                ?Center(
                  child: Container(
                    height: height*0.3,
                    child: (randomizing || middleCardDrawn?card(width, height, onlinefinalCard['value'] == null || _start != 0?{'value': value, 'type': type}:{'value': onlinefinalCard['value'], 'type': onlinefinalCard['type']}, 0):cardBack(width, height)),
                  )
                )
                :Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: width*0.1,
                    ),
                  
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Timer', style: TextStyle(color: Color(0xff00ffff), fontSize: 40, fontFamily: 'Muli', fontWeight: FontWeight.w900))
          ,
          SizedBox(
            height: height*0.02,
          ),
          Text(snapshot.data['activeUser'] == widget.variables.currentUser.uid
            ?(timeLeft).toInt().toString()
            :skipTimer.toString(),
             style: TextStyle(color: Color(0xffffffff), fontSize: 50, fontFamily: 'Muli', fontWeight: FontWeight.w900))
          ,
                  ],
                )
                  ],
                ),
                     /*  Container(
                    height: height*0.3,
                    child: (showRandomizing?randomizing||middleCardDrawn?card(width, height, {'value': value, 'type': type}, 0):cardBack(width, height):Center()),
                  ),
                  Container(
                    width: width*0.1,
                  ), */
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  _navigator.pop(context); widget.returnBack();
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
           Container(
            width: width*0.7,
            child: snapshot.data['activeUser'] != widget.variables.currentUser.uid
           ?Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              betPlaced
            ?Text('Bet: ' + controller.text + ' ETB', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
            :Center(),
            SizedBox(
              width: width*0.05,
            ),
            skipButton && skipTimer <= 0
            ?GestureDetector(
            onTap: (){
              changeActiveUser(nextUser);
              if(playerTurns == playerList.length-1 || betLeft == 0){
      roundCompleteLobby(widget.variables.currentUser.uid, widget.lobbyId);
      int cardValue1 = rng.nextInt(13);
      int cardType1 = rng.nextInt(3);
      finalCard({'type': cardType1, 'value': cardValue1});
       Future.delayed(Duration(seconds: 6)).then((value) {
        resetLobby(widget.variables.currentUser.uid, widget.lobbyId, bankVault);
      });
    }
     else{
      print(' not randomizing');
    }
              setState(() {
                skipTimer = 10;
              });
              setState(() {
                skipButton = false;
                shouldSkip = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Next Player', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
            :Container(
              decoration: BoxDecoration(
                color: Color(0xff666666),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Next Player', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            
            ],
           ) 
           :Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               betting
            ?Container(
              decoration: BoxDecoration(
                // color: Color(0xff23ff34),
                // borderRadius: BorderRadius.circular(20),
                border: Border(
      bottom: BorderSide(width: 1.0, color: Colors.white),
    ),
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: height*0.025, ),
                  child: TextFormField(
                    focusNode: focusNode,
                  keyboardType: TextInputType.number,
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                    controller: controller,
                    enabled: true,
                    maxLength: 5,
                    decoration: InputDecoration(
                       enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Colors.transparent),   
                      ),  
              focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),),
                        hintText: 'Place Bet',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 20.0), 
                        ),
                    onChanged: searchQuery),
                ),
              
              ))
            :betPlaced
            ?Center()
            :GestureDetector(
            onTap: (){
              setState(() {
                betting = true;
              });
              focusNode.requestFocus();
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
            ?Column(
              children: [
                GestureDetector(
            onTap: (){
              setState(() {
                betting = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff00ffff),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
            SizedBox(
              height: height*0.01,
            ),
            
                GestureDetector(
            onTap: (){
             
              int bet = int.parse(controller.text);
              int vault = 0;
              if(snapshot.data['vault']!=null){
                vault = snapshot.data['vault'];
              }
              if(bet>widget.variables.currentUser.coins){
                showWalletFlushbar(context);
              }
              else if(bet>vault){
                showVaultFlushbar(context);
              }
              else if (bet==null){
                showValidFlushbar(context);
              }
              else{
                 setState(() {
                betPlaced = true;
                betting = false;
              });
                placeBet(bet, snapshot);
              }
              
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
            
              ]
            ):betPlaced
            ?Text('Bet Placed: ' + controller.text + ' ETB', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
            :GestureDetector(
            onTap: (){
             skipTurn(widget.variables.currentUser.uid, false);
             setState(() {
               skipped = true;
             });
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
           )
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
                  _navigator.pop(context); widget.returnBack();
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
                  if(initialStart){
                    _firebaseProvider.addMoneyToVault(snapshot.data['players'].length * widget.rate, widget.lobbyId);
                  }
                  if(widget.public){
                    _firebaseProvider.startPublicBankeruLobbyGame(widget.creatorId, widget.lobbyId);
                  }
                  else{
                    _firebaseProvider.startBankeruLobbyGame(widget.creatorId, widget.lobbyId);
                  }
                  setState(() {
                    initialStart = false;
                  });
                   int cardValue1 = rng.nextInt(13);
                   int cardValue2 = rng.nextInt(13);
                   int cardType1 = rng.nextInt(3);
                   int cardType2 = rng.nextInt(3);
                  twoCards([{'type': cardType1, 'value': cardValue1}, {'type': cardType2, 'value': cardValue2}]);
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
                  _navigator.pop(context); widget.returnBack(); player.stop(); widget.startBackground();
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
                  //                _bounceController.reset();
                  // _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); widget.returnBack(); player.stop(); widget.startBackground();
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
         /*  setState(() {
            middleCardDrawn = true;
          });
        randomize(); */
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
    Map<String, dynamic> bets = snapshot.data['betsPlaced'];
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Container(
        width: width*0.25,
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
          SizedBox(height: height*0.01,),
          Center(
            child: Text('@'+data['userName'], style: TextStyle(
              color: snapshot.data['activeUser'] == data['uid'] || !snapshot.data['active']
          ?Colors.white:Color(0xff777777), fontFamily:'Muli', fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic
            )),
          ),
          SizedBox(height: height*0.005,),
          snapshot.data['activeUser'] ==data['uid'] || !snapshot.data['active']
          ?Container(
            width: width*0.02,
            height: width*0.02,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active?Color(0xff23ff89):Color(0xffff2389)
            ),
          ):Center(),
          SizedBox(height: height*0.005,),
          bets.containsKey(data['userName'])
          ? Center(
            child: Text(''+ bets[data['userName']].toString() + ' ETB', style: TextStyle(
              color: Colors.yellow, fontFamily:'Muli', fontSize: 12, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic
            )),
          )
          :Center()

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
      _firebaseProvider.stopBankeruLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
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