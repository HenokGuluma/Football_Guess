import 'dart:async';
import 'dart:collection';
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
import 'package:instagram_clone/models/exploding_widget.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:just_audio/just_audio.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ClosestMultiplayer extends StatefulWidget {

  String category;
  String lobbyId;
  bool public;
  int rate;
  String creatorId;
  int categoryNo;
  bool solo;
  UserVariables variables;
  Function startBackground;
  Function returnBack;
 
  ClosestMultiplayer({
    this.category, this.lobbyId, this.public, this.returnBack, this.solo, this.rate, this.variables, this.startBackground, this.creatorId, this.categoryNo,
  });

  @override
  ClosestMultiplayerState createState() => ClosestMultiplayerState();
}

class ClosestMultiplayerState extends State<ClosestMultiplayer>
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

  final player = AudioPlayer(); 
  final cancel = AudioPlayer();
  final selectPlayer = AudioPlayer();
  final winnerPlayer = AudioPlayer();

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

  String sound = 'assets/glass.mp3';

  int value;
  int color;
  int type;

  AnimationController _animationController;
  AnimationController _slideController;
  AnimationController _colorController;
  TextEditingController _controller = TextEditingController();
  int choiceNumber;
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
  int second = 6;
  bool submitting = false;
  bool submitted = false;
  double timeLeft = 6;
  double resetValue = 6;
  double gamePlayTimeLeft = 3;
  double divider = 6;
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
  bool countingSecond = false;
   bool automaticCountDown = false;
  bool automaticCounting = false;
  int automaticCount = 0;
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
  Timer _firstTimer;
  Timer _secondTimer;
  Timer _thirdTimer;
  Timer _fourthTimer;
  Timer _fifthTimer;
  int _start = 100;
  int _firstStart = 500;
  int _secondStart = 400;
  int _thirdStart = 300;
  int _fourthStart = 200;
  int _fifthStart = 100;
  bool randomizing = false;
  bool showRandomizing = true;
  int firstNum = 0;
  int secondNum = 0;
  int thirdNum = 0;
  int fourthNum = 0;
  int fifthNum = 0;
  int randomizedNumber;
   List<int> cards = [];
   List<Map<String, dynamic>> cardValues = [];
   int score = 0;
   int addedScore = 0;
   bool exploded = false;
   bool perfectScore = false;
   bool gameOver = false;
   double totalWinnings = 0;
   bool checking = false;
   int randomized = 0;


Future<void> setupSound() async{
    await player.setAsset('assets/glass.mp3');
    await selectPlayer.setAsset('assets/sound-effects/option-click-confirm.wav');
    await cancel.setAsset('assets/sound-effects/option-click.wav');
    await winnerPlayer.setAsset('assets/sound-effects/winner.mp3');
    selectPlayer.setVolume(0.1);
    cancel.setVolume(0.1);
    cancel.play();
    cancel.stop();
    winnerPlayer.setVolume(0.5);
    winnerPlayer.play();
    winnerPlayer.stop();
  }

  depositWinning(double amount){
    User newUser = widget.variables.currentUser;
      newUser.coins = widget.variables.currentUser.coins + amount.toInt();
      widget.variables.setCurrentUser(newUser);
      setState(() {
        
      });
    _firebaseProvider.depositWinning(widget.variables.currentUser.uid, amount.toInt()).then((value) {
    });
  }

  Future<bool> checkNumber(int number) async {
    DocumentSnapshot snap;
    if(widget.public){
      snap = await _firestore.collection('publicLobbies').doc(widget.lobbyId).collection('initialGuesses').doc(number.toString()).get();
    }
    else{
      snap = await _firestore.collection('lobbies').doc(widget.lobbyId).collection('initialGuesses').doc(number.toString()).get();
    }
    if(snap.exists){
      return true;
    }
   submitInitial(number);
   return false;
  }

void startTimer(int numValue) {
  const oneSec = const Duration(milliseconds: 10);
  _firstTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      var added = 0;

      if (_firstStart == 0) {
        timer.cancel();
        cards.add(value);
        cardValues.add({'value': value, 'type': type});
          setState(() {
            showRandomizing = false;
            firstNum = numValue;             
          });
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            if(winner!=null){
              if(widget.variables.currentUser.userName == winner.data()['userName']){
            depositWinning(totalWinnings);  
          winnerPlayer.play();
          setState(() {
            
          });
        }
            }
            else{
              print('shiaaat');
            }
            
          });

          Future.delayed(Duration(milliseconds: 1000)).then((value) {
            
             setState(() {
            randomizing = false;
            showRandomizing = true;
            gameOver = true;      
           
          });
          stopGame();
        // winnerPlayer.play();
         Future.delayed(Duration(milliseconds: 3000)).then((value) {
           winnerPlayer.stop();
          });
          
          
          });
      } else {
        int randomNum = Random().nextInt(9);
        // print(_start);
        setState(() {
          _firstStart--;
          firstNum = randomNum;
        });
      }
    },
  );
}

void startSecondTimer(int numValue) {
  const oneSec = const Duration(milliseconds: 10);
  _secondTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      var added = 0;
     
      if (_secondStart == 0) {
        timer.cancel();
        cards.add(value);
        cardValues.add({'value': value, 'type': type});
          setState(() {
            showRandomizing = false;
            secondNum = numValue;             
          });
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            
             setState(() {
            randomizing = false;
            showRandomizing = true;
           
          });
          
          });
      } else {
        int randomNum = Random().nextInt(9);
        // print(_start);
        setState(() {
          _secondStart--;
          secondNum = randomNum;
        });
      }
    },
  );
}

void startThirdTimer(int numValue) {
  const oneSec = const Duration(milliseconds: 10);
  _thirdTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      var added = 0;
     
      if (_thirdStart == 0) {
        timer.cancel();
        cards.add(value);
        cardValues.add({'value': value, 'type': type});
          setState(() {
            showRandomizing = false;
            thirdNum = numValue;    
          });
          Future.delayed(Duration(milliseconds: 1000)).then((value) {
            
             setState(() {
            randomizing = false;
            showRandomizing = true; 
          });
          
          });
      } else {
        int randomNum = Random().nextInt(9);
        // print(_start);
        setState(() {
          _thirdStart--;
          thirdNum = randomNum;
        });
      }
    },
  );
}

void startFourthTimer(int numValue) {
  const oneSec = const Duration(milliseconds: 10);
  _fourthTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      var added = 0;
     
      if (_fourthStart == 0) {
        timer.cancel();
        cards.add(value);
        cardValues.add({'value': value, 'type': type});
          setState(() {
            showRandomizing = false;
            fourthNum = numValue;             
          });
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            
             setState(() {
            randomizing = false;
            showRandomizing = true;
           
          });
          
          });
      } else {
        int randomNum = Random().nextInt(9);
        // print(_start);
        setState(() {
          _fourthStart--;
          fourthNum = randomNum;
        });
      }
    },
  );
}
void startFifthTimer(int numValue) {
  const oneSec = const Duration(milliseconds: 10);
  _fifthTimer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      var added = 0;
     
      if (_fifthStart == 0) {
        timer.cancel();
        cards.add(value);
        cardValues.add({'value': value, 'type': type});
          setState(() {
            showRandomizing = false;
            fifthNum = numValue;             
          });
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            
             setState(() {
            randomizing = false;
            showRandomizing = true;
           
          });
          
          });
      } else {
        int randomNum = Random().nextInt(9);
        // print(_start);
        setState(() {
          _fifthStart--;
          fifthNum = randomNum;
        });
      }
    },
  );
}

submitScore(){
  if(widget.public){
    _firebaseProvider.submitPublicUserScore(widget.variables.currentUser, widget.lobbyId, score);
  }
  else{
    _firebaseProvider.submitUserScore(widget.variables.currentUser, widget.lobbyId, score);
  }
}


 @override
  void dispose() {
    // _pageController.dispose();
    // _animationController.dispose();
    // _slideController.dispose();
    // _bounceController.dispose();
    // startTimer();
    // _timer.cancel();
    _firstTimer.cancel();
    _secondTimer.cancel();
    _thirdTimer.cancel();
    _fourthTimer.cancel();
    _fifthTimer.cancel();

   
    super.dispose();
  }


  @override
  void initState() {
  
    value = rng.nextInt(12);
    color = rng.nextInt(2);
    type = rng.nextInt(3);
  
     _navigator = Navigator.of(context);

     startCountDown();
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
     
    super.initState();

    
  }

  

  Future<void> getWinner(int score) async{
    if(!widget.solo){
      setState(() {
      retrievingWinner = true;
    });
     Future.delayed(Duration(seconds: 2)).then((value) {
      if(widget.public){
        _firebaseProvider.submitClosestPublicUserScore(widget.variables.currentUser, choiceNumber, widget.lobbyId, score);
      }
      else{
        _firebaseProvider.submitClosestUserScore(widget.variables.currentUser, choiceNumber, widget.lobbyId, score);
      }
      
     });
   Future.delayed(Duration(seconds: 4)).then((value) {

     _firebaseProvider.getClosestLobbyWinner(widget.lobbyId).then((lobbyWinner) {
      if(lobbyWinner!=null){
        setState(() {
          winner = lobbyWinner;
          retrievingWinner = false;
        });
      }
    });
   });
    }
    else{

    }
  }

 void randomize(int number){
    // print('daaum');
    setState(() {
      _firstStart = 600;
      _secondStart = 500;
      _thirdStart = 400;
      _fourthStart = 300;
      _fifthStart = 200;
      randomizing = true;
      showRandomizing = true;
      
    });
    int fifthDigit = 0;
    int fourthDigit = 0;
    int thirdDigit = 0;
    int secondDigit = 0;
    int firstDigit = 0;
    if(number.toString().length==5){
      firstDigit = int.parse(number.toString()[4]);
      secondDigit = int.parse(number.toString()[3]);
      thirdDigit = int.parse(number.toString()[2]);
      fourthDigit = int.parse(number.toString()[1]);
      fifthDigit = int.parse(number.toString()[0]);
    }
    if(number.toString().length==4){
      firstDigit = int.parse(number.toString()[3]);
      secondDigit = int.parse(number.toString()[2]);
      thirdDigit = int.parse(number.toString()[1]);
      fourthDigit = int.parse(number.toString()[0]);
    }
    if(number.toString().length==3){
      firstDigit = int.parse(number.toString()[2]);
      secondDigit = int.parse(number.toString()[1]);
      thirdDigit = int.parse(number.toString()[0]);
    }
    if(number.toString().length==2){
      firstDigit = int.parse(number.toString()[1]);
      secondDigit = int.parse(number.toString()[0]);
    }
    if(number.toString().length==1){
      firstDigit = int.parse(number.toString()[0]);
    }
    startTimer(firstDigit);
    startSecondTimer(secondDigit);
    startThirdTimer(thirdDigit);
    startFourthTimer(fourthDigit);
    startFifthTimer(fifthDigit);
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
      /* else if(!startDown && !widget.solo){
       
      } */
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
              // The state that has changed here is the animation object???s value.
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

       if(!gotWinner && shouldGetWinner && !disposed){
        print('bounceshakbawbaw');
        setState(() {
          gotWinner = true;
        });
        getWinner(score);
      }

      if(setupPlayers && playerInfotemp!=null){
        List<dynamic> list =  playerInfotemp.entries.map( (entry) => entry.value).toList();
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
    print('stopped game');
     widget.public?_firebaseProvider.resetPublicClosestGame(widget.variables.currentUser.uid, widget.lobbyId):_firebaseProvider.resetClosestGame(widget.variables.currentUser.uid, widget.lobbyId);
  }

    void showFlushbar(BuildContext context) {
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
        'That number was already submitted. Please choose a different number.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black), textAlign: TextAlign.center
      )),
    )..show(context);
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
            if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
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

submitInitial(int initial)async{
  var increment = FieldValue.increment(1);
  if(widget.public){
    await _firestore.collection('publicLobbies').doc(widget.lobbyId).collection('initialGuesses').doc(initial.toString()).set({'userName': widget.variables.currentUser.userName, 'guess': initial});
    await _firestore.collection('publicLobbies').doc(widget.lobbyId).collection('initialGuesses').doc('playerAmount').update({'playerAmount': increment});
  }
  else{
    await _firestore.collection('lobbies').doc(widget.lobbyId).collection('initialGuesses').doc(initial.toString()).set({'userName': widget.variables.currentUser.userName, 'guess': initial});
    await _firestore.collection('lobbies').doc(widget.lobbyId).collection('initialGuesses').doc('playerAmount').update({'playerAmount': increment});
  }
  await _firestore.collection('users').doc(widget.variables.currentUser.uid).update({'coins': widget.variables.currentUser.coins - widget.rate});
  User newUser = widget.variables.currentUser;
  newUser.coins = widget.variables.currentUser.coins - widget.rate;
  widget.variables.setCurrentUser(newUser);
  setState(() {
    
  });
  print(widget.variables.currentUser.coins);
  print(' is the coins');

}

submitRandomized(int randomized) async{
  DocumentSnapshot snap;
  if(widget.public){
    snap = await _firestore.collection('publicLobbies').doc(widget.lobbyId).collection('initialGuesses').doc('playerAmount').get();
  }
  else{
    snap = await _firestore.collection('lobbies').doc(widget.lobbyId).collection('initialGuesses').doc('playerAmount').get();
  }
  int playerAmount = snap['playerAmount'];
  double winnings = (playerAmount * widget.rate)*0.95;
  int winningUpdate = winnings.toInt();
  if(widget.public){
    await _firestore.collection('publicLobbies').doc(widget.lobbyId).update({'randomized': randomized, 'active': true, 'winnings': winningUpdate});
  }
  else{
    await _firestore.collection('lobbies').doc(widget.lobbyId).update({'randomized': randomized, 'active': true, 'winnings': winningUpdate});;
  }
  setState(() {
    totalWinnings = winnings;
  });
}

submitFinal(int finalNum, int winnings)async{
  if(widget.public){
    await _firestore.collection('publicLobbies').doc(widget.lobbyId).collection('initialGuesses').add({'userName': widget.variables.currentUser.userName, 'guess': finalNum});
  }
  else{
    await _firestore.collection('lobbies').doc(widget.lobbyId).collection('initialGuesses').add({'userName': widget.variables.currentUser.userName, 'guess': finalNum});
  }
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
             SizedBox(
                height: height*0.05,
              ),
              gotWinner
              ?winner!=null
          ?widget.variables.currentUser.userName != winner.data()['userName']
              ?Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                'The Winner is: ', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            SizedBox(
              height: height*0.02,
            ),
            winnerWidget(width, height, winner, snapshot),
           
              SizedBox(
              height: height*0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
            onTap: (){
              // Navigator.pop(context);
              setState(() {
                submitted = false;
                submitting = false;
                finished = false;
                exploded = false;
                perfectScore = false;
                gotWinner = false;
                winner = null;
                gameOver = false;
                cardValues = [];
                score = 0;
                choiceNumber = null;
                shouldGetWinner = false;
                randomizedNumber = null;
                _controller.text = '';
                firstNum = 0;
                secondNum = 0;
                thirdNum = 0;
                fourthNum = 0;
                fifthNum = 0;
                timeLeft = 6;
              });
              // _firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId, widget.rate);_firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId, widget.rate);
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
            ),
            SizedBox(height: height*0.05,),
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
                                  _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
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
              ],
            )
            
            
            ]))
          :Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Text(
                'Congratulations', style: TextStyle(color: Color(0xff63ff00), fontFamily: 'Muli', fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.1,
            ),
           Text(
                'You have won with guess: ' + choiceNumber.toString(), style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.08,
            ),
             Text(
                'Jackpot Number: ' + snapshot.data['randomized'].toString(), style: TextStyle(color: Colors.yellow, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.07,
            ),
            Text(
                'Wallet: ' + widget.variables.currentUser.coins.toString() + ' ETB', style: TextStyle(color: Color(0xffffffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
            onTap: (){
              // Navigator.pop(context);
              setState(() {
                submitted = false;
                submitting = false;
                finished = false;
                exploded = false;
                perfectScore = false;
                gotWinner = false;
                winner = null;
                gameOver = false;
                cardValues = [];
                score = 0;
                choiceNumber = null;
                randomizedNumber = null;
                _controller.text = '';
                firstNum = 0;
                shouldGetWinner = false;
                secondNum = 0;
                thirdNum = 0;
                fourthNum = 0;
                fifthNum = 0;
                timeLeft = 6;
              });
              // _firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId, widget.rate);_firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId, widget.rate);
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
            ),
            SizedBox(height: height*0.05,),
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
                                  _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
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
              ],
            )
            ]))
          :Center(
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
          ])
          )
          :Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Waiting for others to finish', style: TextStyle(color: Color(0xffffffff), fontSize: 25, fontFamily: 'Muli', fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
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
                                  _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
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
              ],
            ),
          )
          ,
            ])),
      ],
    ),
  );
}
   
Widget submittedScreen(var width, var height, AsyncSnapshot snapshot){
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
                height: height*0.2,
              ),
               Container(
                width: width*0.9,
                child: Center(
                child: Text(
                'You have submitted your Score', style: TextStyle(color: Color(0xff63ff00), fontFamily: 'Muli', fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center
              ),
               ),
               ),
               SizedBox(
                height: height*0.1,
              ),
              Text(
                'Final Score: '+ score.toInt().toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
              SizedBox(
                height: height*0.05,
              ),
              GestureDetector(
            onTap: (){
              // Navigator.pop(context);
              setState(() {
                exploded = false;
                perfectScore = false;
                submitted = false;
                submitting = false;
                finished = false;
                gotWinner = false;
                winner = null;
                gameOver = false;
                cardValues = [];
                choiceNumber = null;
                randomizedNumber = null;
                _controller.text = '';
                firstNum = 0;
                secondNum = 0;
                thirdNum = 0;
                fourthNum = 0;
                fifthNum = 0;
                score = 0;
                shouldGetWinner = false;
                timeLeft = 6;
              });
              // _firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId, widget.rate);_firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId, widget.rate);
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
            ),
            ])),
      ],
    ),
  );
}


Widget startScreen(var width, var height, AsyncSnapshot snapshot){
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
          Container(
                      height: height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
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
            SizedBox(
              height: height*0.1,
            ),
                          startDown
                          ?Container(
              height: height*0.35,
              width: width,
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
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
            ):snapshot.data['players'].length<1
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
              SizedBox(
                height: height*0.1,
              ),

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
                                  if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  Navigator.pop(context);
                                 _bounceController.reset();
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
                      ),
                    ),
            ],
    ),
  );
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
             shouldGetWinner = true;
             score = (snapshot.data['randomized'] - choiceNumber).abs();
          }
           
          else{
             startDown = false;
            
          }


        }
       
        return gameOver?finalScreen(width, height, snapshot):closestScreen(width, height, snapshot);})
        );
   
   }
  
   Widget perfectScoreWidget(var width, var height){
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
            height: height*0.3,
          ),
               
                  Center(
                    child: Text('You got a perfect Score', style: TextStyle(color: Color(0xff12ff23), fontSize: 40, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center,),
                  )
                 ,
          SizedBox(height: height*0.1,),
            Text('Score: 21', style: TextStyle(color: Color(0xffffffff), fontSize: 30, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                 ,
          SizedBox(height: height*0.1,),
            /* GestureDetector(
            onTap: (){
              // Navigator.pop(context);
              setState(() {
                exploded = false;
                perfectScore = false;
                gotWinner = false;
                finished = false;
                winner = null;
                cardValues = [];
                score = 0;
                timeLeft = 6;
              });
              _firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId);_firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId);
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
            ),
            SizedBox(height: height*0.05,), */
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
                                  widget.public?_firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId):_firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                                  if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
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
           
            
            ])
          ), 
         
          ],
      ));
 
   }

   Widget explodedView(var width, var height, AsyncSnapshot snapshot){
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
        SizedBox(
            height: height*0.05,
          ),
               
                 !finished
                 ?Column(
                  children: [
                     Text('You Just Exploded', style: TextStyle(color: Color(0xff00ffff), fontSize: 40, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                 ,
          SizedBox(height: height*0.1,),
          Text('The total was: '+ score.toString(), style: TextStyle(color: Color(0xffff2389), fontSize: 25, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                 ,
                 SizedBox(height: height*0.05,),
            Text('Score: '+ (score - addedScore).toString(), style: TextStyle(color: Color(0xffffffff), fontSize: 30, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                 ,
         
                  ],
                 )
                 : Center(),
            SizedBox(height: height*0.05,),   
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               /* GestureDetector(
            onTap: (){
              // Navigator.pop(context);
              setState(() {
                exploded = false;
                cardValues = [];
                finished = false;
                gotWinner = false;
                winner = null;
                score = 0;
                timeLeft = 6;
              });
              _firebaseProvider.addUserToLobby(widget.variables.currentUser, widget.lobbyId);
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
            ),
             */
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
                                  if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  Navigator.pop(context);
                                //  _bounceController.reset();
                  // _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); widget.returnBack();
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

            ],
           )
           
            
            ])
          ), 
         
          ],
      ));
 
   }

   Widget winnerScreen(var width, var height, AsyncSnapshot snapshot){
    
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
            
            child: ListView(
              children: [
                 SizedBox(
                height: height*0.05,
              ),
                 widget.variables.currentUser.userName == winner.data()['userName']
                 ?winnerWidget(width, height, winner, snapshot)
                 :Row(
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
              
            _controller.text.length>0 && !submitted &&!checking && int.parse(_controller.text)>=1 && int.parse(_controller.text)<=50000
            ?GestureDetector(
              onTap: (){
                setState(() {
                  choiceNumber = int.parse(_controller.text);
                  checking = true;
                });
                checkNumber(choiceNumber).then((value) {
                  if(value){
                    showFlushbar(context);
                    checking = false;
                  }
                  else{
                    setState(() {
                      checking = false;
                      submitted = true;
                    });
                  }
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
                child: Text('Submit', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
            :checking
            ?Container(
              decoration: BoxDecoration(
                color: Color(0xff444444),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Checking...', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )
            :Container(
              decoration: BoxDecoration(
                color: Color(0xff444444),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Submitted', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )
                  ],
                )
                
                ]
              )
            ), 
            
            ])
          );
   }


   Widget closestScreen(var width, var height, AsyncSnapshot snapshot){
    List<dynamic> playerLists = [];
    if(snapshot.data!=null){
      playerLists = snapshot.data['players'];
    }
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
            
            child: ListView(
              children: [
                 SizedBox(
                height: height*0.05,
              ),
                 playerInfos!=null
                 ?Container(
              height: height*0.15,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                    return profileCircle(width, height, index, playerInfos[playerLists[index]], snapshot);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: playerLists.length,
                ),
            )
            :Container(
              height: height*0.15,
            )
            ,
                    SizedBox(
                height: height*0.05,
              ),
               Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Container(
                      width: width*0.2,
                      height: width*0.35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff444444))
                      ),
                      child: Center(
                        child: Text(fifthNum.toString(), style: TextStyle(
                                  color: Color(0xff23ff34),
                                  fontFamily: 'Muli',
                                  fontSize: 105,
                                  fontWeight: FontWeight.w900),),
                      )
                    ),
                     Container(
                      width: width*0.2,
                      height: width*0.35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff444444))
                      ),
                      child: Center(
                        child: Text(fourthNum.toString(), style: TextStyle(
                                  color: Color(0xff23ff34),
                                  fontFamily: 'Muli',
                                  fontSize: 105,
                                  fontWeight: FontWeight.w900),),
                      )
                    ),
                   Container(
                      width: width*0.2,
                      height: width*0.35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff444444))
                      ),
                      child: Center(
                        child: Text(thirdNum.toString(), style: TextStyle(
                                  color: Color(0xff23ff34),
                                  fontFamily: 'Muli',
                                  fontSize: 105,
                                  fontWeight: FontWeight.w900),),
                      )
                    ),
                    Container(
                      width: width*0.2,
                      height: width*0.35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff444444))
                      ),
                      child: Center(
                        child: Text(secondNum.toString(), style: TextStyle(
                                  color: Color(0xff23ff34),
                                  fontFamily: 'Muli',
                                  fontSize: 105,
                                  fontWeight: FontWeight.w900),),
                      )
                    ),
                    Container(
                      width: width*0.2,
                      height: width*0.35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff444444))
                      ),
                      child: Center(
                        child: Text(firstNum.toString(), style: TextStyle(
                                  color: Color(0xff23ff34),
                                  fontFamily: 'Muli',
                                  fontSize: 105,
                                  fontWeight: FontWeight.w900),),
                      )
                    ),
                  ],
                ),
                SizedBox(
                  height: height*0.05,
                ),
                
                submitted
                ?MaterialButton(
                  onPressed: (){
                    int num = Random().nextInt(50000);
                    setState(() {
                      randomizedNumber = num;
                    });
                    randomize(num);
                    print(widget.rate);
                    print(snapshot.data['players']);
                    submitRandomized(num);
                  },
                  child:  Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Randomize', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
                  )
                  : MaterialButton(
                    onPressed: (){},
                    child: Container(
              decoration: BoxDecoration(
                color: Color(0xff444444),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Randomize', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )),
                SizedBox(
                  height: height*0.1,
                ),
               submitted
               ?Center(
                child: Text(choiceNumber!=null?choiceNumber.toString():'000',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 86,
                                  fontWeight: FontWeight.w900),
                            ),
               )
                            :Column(
                              children: [
                                Container(
                              // constraints: BoxConstraints(maxWidth: width*0.5),
                              width: width*0.5,
                              height: height*0.1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent)
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: height*0.00),
                                  child: TextFormField(
                                    
                                    // textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.number,
                  inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
              ],
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontWeight: FontWeight.w900, fontSize: 45),
                    textAlign: TextAlign.center,
                    controller: _controller,
                    maxLength: 5,
                    
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                  bottom: height*0.02,  // HERE THE IMPORTANT PART
                ),
                        enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Color(0xff00ffff)),   
                      ),  
              focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff00ffff)),
                   ),
                        hintText: 'Choice',
                        
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 45.0),
                            
                        // labelText: 'Choose from 1 to 400',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 20.0)),
                    ),
                              
                                )),
                            ),
                
                              ],
                            ),
                           _controller.text.length<1
                           ?Center()
                           :int.parse(_controller.text)<1 || int.parse(_controller.text)>50000
                           ?Center(
                            child: Text(
                              'Enter a valid number between 1 and 50000',
                              style: TextStyle(
                                  color: Color(0xffff2345),
                                  fontFamily: 'Muli',
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ), 
                           )
                           :Center()
                           ,
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
              
            _controller.text.length>0 && !submitted &&!checking && int.parse(_controller.text)>=1 && int.parse(_controller.text)<=50000
            
            ?GestureDetector(
              onTap: (){
                setState(() {
                  choiceNumber = int.parse(_controller.text);
                  checking = true;
                });
                checkNumber(choiceNumber).then((value) {
                  if(value){
                    showFlushbar(context);
                    checking = false;
                  }
                  else{
                    setState(() {
                      checking = false;
                      submitted = true;
                    });
                  }
                });
                // submitInitial(choiceNumber);
              },
              child: Container(
              decoration: BoxDecoration(
                color: Color(0xff23ff34),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Submit', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
             :checking
            ?Container(
              decoration: BoxDecoration(
                color: Color(0xff444444),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Checking...', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )
            :_controller.text.length>0 && int.parse(_controller.text)>=1 && int.parse(_controller.text)<=50000
            ?Container(
              decoration: BoxDecoration(
                color: Color(0xff444444),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Submitted', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ):Container(
              decoration: BoxDecoration(
                color: Color(0xff444444),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Submit', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )
                  ],
                )
                
                ]
              )
            ), 
            
            ])
          );
   }

   Widget gameScreen(var width, var height, AsyncSnapshot snapshot){
    return 
    !gameStarted
    ?startScreen(width, height, snapshot)
    :exploded && !finished
    ?explodedView(width, height, snapshot)
    :perfectScore && !finished
    ?perfectScoreWidget(width, height)
    :submitted && !finished
    ?submittedScreen(width, height, snapshot)
    :finished
    ?finalScreen(width, height, snapshot)
    :ShatteringWidget(
            builder: (shatter) => Scaffold(
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
                
                randomizing
                ?Center(
                  child: Container(
                    height: height*0.3,
                    child: (showRandomizing?randomizing?card(width, height, {'value': value, 'type': type}, 0):cardBack(width, height, shatter):Center()),
                  )
                )
                :Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: width*0.05,
                    ),
                    Center(
                  child: Container(
                    height: height*0.3,
                    child: (showRandomizing?randomizing?card(width, height, {'value': value, 'type': type}, 0):cardBack(width, height, shatter):Center()),
                  )
                ),
                Container(
                  width: width*0.25,
                  child: Text('Time: '+timeLeft.toInt().toString(), style: TextStyle(color: Color(0xff00ffff), fontSize: 20, fontFamily: 'Muli', fontWeight: FontWeight.w900))
          ,
                )
                  ],
                ),
                SizedBox(
                  height: height*0.05,
                ),
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
            SizedBox(
              height: height*0.03,
            ),
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                                  if(lastPlayer && widget.public){
                                    _firebaseProvider.stopPublicLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  else if(lastPlayer){
                                    _firebaseProvider.stopLobbyGame(widget.variables.currentUser.uid, widget.lobbyId);
                                  }
                                  Navigator.pop(context);
                                //  _bounceController.reset();
                  // _animationController.reset();
                  setState(() {
                    disposed = true;
                  });
                  // handleTimeout();
                  _navigator.pop(context); widget.returnBack();
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
            submitting
            ? Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Submitting...', style: TextStyle(color: Color(0xff333333), fontSize: 16, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )
            :GestureDetector(
            onTap: (){
             setState(() {
               submitting = true;
               submitted = true;
             });
             if(widget.public){
              print('publiccc');
                _firebaseProvider.submitPublicUserScore(widget.variables.currentUser, widget.lobbyId, score).then((value) {
                  _firebaseProvider.removeUserFromPublicLobby(widget.variables.currentUser, widget.lobbyId);
                  setState(() {
                    submitting = false;               
             });
             Future.delayed(Duration(seconds: 2)).then((value) {
              setState(() {
                finished = true;
              });
             });
                });
               }
               else{
                print('non public');
                _firebaseProvider.submitUserScore(widget.variables.currentUser, widget.lobbyId, score).then((value) {
                   _firebaseProvider.removeUserFromLobby(widget.variables.currentUser, widget.lobbyId);
                  setState(() {
                    submitting = false;               
             });
             Future.delayed(Duration(seconds: 2)).then((value) {
              setState(() {
                finished = true;
              });
             });
                });
               }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Submit', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
            Text('Total: ' + score.toString(), style: TextStyle(color: score==0?Colors.white:Color(0xff26ff45), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                  ],
                 ),
          SizedBox(height: height*0.05,),
            
           
            
            ])
          ), 
         
          ],
      )
      )
      );
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

  
   Widget cardBack(var width, var height, Function shatter){
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
            timeLeft = 6;
            countingSecond = false;
          });
        
        
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


    Color cardColor = Colors.black;

    if(type ==2 || type ==3){
      cardColor = Colors.red;
    }

    return Padding(
      padding: EdgeInsets.only(left: cardValues.length>4?index*width*0.1:index*width*0.15),
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
          borderRadius: BorderRadius.circular(15),
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

   Widget winnerWidget(var width, var height, DocumentSnapshot winner, AsyncSnapshot snapshot){
    Map<String, dynamic> userMap = snapshot.data['playerInfo'];
    return Column(
      children: [
        Container(
            width: width,
            //  height: height*0.12,
            child: Column(
              children: [
                Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: userMap[winner['userName']]['photoUrl']==null
                ?AssetImage('assets/grey.png')
                :CachedNetworkImageProvider(userMap[winner['userName']]['photoUrl']),
                fit: BoxFit.cover,
              )
            ),
            width: width*0.2,
      height: width*0.2,
          ),
          SizedBox(
            height: height*0.01,
          ),
                Container(
                  child: Center(
                    child: Container(
                    width: width,
                    child: Text('@'+winner['userName'], style: TextStyle(color: Color(0xff63ff00), fontSize: 30, fontFamily: 'Muli', fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                  )),
              width: width,
              // height: height*0.1,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent
                 
              ),
            ),
            SizedBox(
              height: height*0.1,
            ),
             Text(
                'Jackpot Number: ' + snapshot.data['randomized'].toString(), style: TextStyle(color: Colors.yellow, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            
              SizedBox(
              height: height*0.02,
            ),
            Container(
                  child: Center(
                    child: Container(
                    width: width,
                    child: Text('Winnings: '+ totalWinnings.toString() + ' ETB', style: TextStyle(color: Color(0xffffffff), fontSize: width*0.08, fontFamily: 'Muli', fontWeight: FontWeight.w900, fontStyle: FontStyle.normal), textAlign: TextAlign.center),
                  )),
              width: width,
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
          
    ]);
   }

   Widget congratsWidget(var width, var height, DocumentSnapshot winner){
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
                    child: Text('CONGRATULATIONS', style: TextStyle(color: Color(0xff63ff00), fontSize: width*0.09, fontFamily: 'Muli', fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
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
            child: Text('Your Score: '+ winner['score'].toString(), style: TextStyle(color: Colors.white, fontSize: width*0.06, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          ),
           SizedBox(height: height*0.03,),
          Center(
            child: Text('Wallet: '+ winner['score'].toString(), style: TextStyle(color: Colors.white, fontSize: width*0.06, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center),
          ),
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
          print('wrong click');
        }
        
        else if(correct){
          setState(() {
            correctPicked = true;
            currentPage = currentPage+1;
             _colorController = AnimationController(duration: Duration(seconds: resetValue.toInt()), vsync: this);
           colorAnimation = ColorTween(begin: Color(0xff63ff00), end: Color(0xffff2389)).animate(_colorController)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object???s value.
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