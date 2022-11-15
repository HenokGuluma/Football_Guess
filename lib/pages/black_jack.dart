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
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/exploding_widget.dart';
import 'package:progress_indicators/progress_indicators.dart';

class BlackJack extends StatefulWidget {

  String category;
  String lobbyId;
  String creatorId;
  int categoryNo;
  bool solo;
  UserVariables variables;
 
  BlackJack({
    this.category, this.lobbyId, this.solo, this.variables, this.creatorId, this.categoryNo,
  });

  @override
  _BlackJackState createState() => _BlackJackState();
}

class _BlackJackState extends State<BlackJack>
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

  int value;
  int color;
  int type;

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
  double gamePlayTimeLeft = 5;
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
    var rng = Random();
  int playerAmount = 0;
  bool setupPlayers = true;
  dynamic playerInfos;
  dynamic playerInfotemp;
  bool resetColor = true;
  List<dynamic> playerList = [];
  List<Widget> drawnCards = [];
  Timer _timer;
  int _start = 100;
  bool randomizing = false;
  bool showRandomizing = true;
   List<int> cards = [];
   List<Map<String, dynamic>> cardValues = [];
   int score = 0;
   bool exploded = false;

void startTimer(var width, var height, Function shatter) {
  
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
        cardValues.add({'value': value, 'type': type});
          setState(() {
            showRandomizing = false;
          });
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
            randomizing = false;
            showRandomizing = true;
            score = score+added;
          });

          if (score+added > 21){
            shatter();
            setState(() {
              exploded = true;
            });
          }
          });
      } else {
        print(_start);
        setState(() {
          _start--;
          value = rng.nextInt(12);
          type = rng.nextInt(3);
        });
      }
    },
  );
}

 @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    // startTimer();
    _timer.cancel();
   
    super.dispose();
  }


  @override
  void initState() {
  
    value = rng.nextInt(12);
    color = rng.nextInt(2);
    type = rng.nextInt(3);
   /*  _navigator = Navigator.of(context);
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
    _slideController.repeat(reverse: false); */

    super.initState();

    /* _colorController.repeat(reverse: false);
    
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
      } */
   /*  
   startCountDown();
   startGamePlayCountDown();
    startSecondCountDown(); */
    // scheduleTimeout(second * 1000);
    
  }

  Future<void> getWinner() async{
    if(!widget.solo){
      setState(() {
      retrievingWinner = true;
    });
   Future.delayed(Duration(seconds: 10)).then((value) {
     _firebaseProvider.getLobbyWinner(widget.lobbyId).then((lobbyWinner) {
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

 void randomize(var width, var height, Function shatter){
    print('daaum');
    setState(() {
      _start = 100;
      randomizing = true;
      showRandomizing = true;
      
    });
    startTimer(width, height, shatter);
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

       if(!gotWinner && playerAmount<1){
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
          playerList = list;
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
    child: gameScreen(width, height)
        );
   
   }

   Widget explodedView(var width, var height){
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
               
                  Text('You Just Exploded', style: TextStyle(color: score==0?Colors.white:Color(0xff00ffff), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                 ,
          SizedBox(height: height*0.1,),
            GestureDetector(
            onTap: (){
              // Navigator.pop(context);
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
           
            
            ])
          ), 
         
          ],
      ));
 
   }

   Widget gameScreen(var width, var height){
    return ShatteringWidget(
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
            height: height*0.08,
          ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
            ),
            Text('Total: ' + score.toString(), style: TextStyle(color: score==0?Colors.white:Color(0xff26ff45), fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900))
                  ],
                 ),
                 SizedBox(
                  height: height*0.08,
                ),
                Center(
                  child: Container(
                    height: height*0.3,
                    child: (showRandomizing?randomizing?card(width, height, {'value': value, 'type': type}, 0):cardBack(width, height, shatter):Center()),
                  )
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
          SizedBox(height: height*0.05,),
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
                child: Text('Submit', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
           
            
            ])
          ), 
         
          ],
      )));
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
    print(typeMap[type]);
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


    print(typeMap[type]); print('babbby');

    return GestureDetector(
         onTap: (){
        randomize(width, height, shatter);
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
          borderRadius: BorderRadius.circular(20)
              ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: width*0.01,
          ),
         Row(
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
          Center(
            child: Container(
                width: width*0.2,
                height: width*0.2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/banker-removed.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
          ),
          Row(
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


    print(typeMap[type]); print('babbby');

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