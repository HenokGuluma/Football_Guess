import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Footballers extends StatefulWidget {

  String category;
  String lobbyId;
  String creatorId;
  bool solo;
  UserVariables variables;
 
  Footballers({
    this.category, this.lobbyId, this.solo, this.variables, this.creatorId
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
  AnimationController _animationController;
  AnimationController _slideController;
    AnimationController _bounceController;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  PageController _pageController;
  Animation _animation;
  bool animate = false;
  bool correctPicked = false;
  int currentPage = 0;
  bool finished = false;
  int second = 6;
  double timeLeft = 6;
  double resetValue = 6;
  double gamePlayTimeLeft = 5;
  double divider = 6;
  bool defeated = false;
  bool wrongClick = false;
  int gamePlayDuration = 0;
  bool disposed = false;
  bool gameStarted = false;
  bool startDown = false;
  double size = 1;
  bool lastPlayer = false;

 @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    setState(() {
      disposed = true;
    });
    super.dispose();
  }


  @override
  void initState() {
    
    
    _pageController = PageController(initialPage: currentPage, viewportFraction: 1);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
     _slideController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(seconds: second),
      // value: timeLeft.toDouble(),
    )..addListener(() {
        setState(() {});
      });
      // _slideController.reset();
    _slideController.repeat(reverse: false);

    super.initState();
    
    _animationController.repeat(reverse: true);
    // _animationController.reset();
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });

      _bounceController = AnimationController(

      duration: Duration(milliseconds: 500),

      vsync: this,

      upperBound: 1.2,
      lowerBound: 1

    );
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
    // scheduleTimeout(second * 1000);
    
  }

  void startCountDown(){
    Timer.periodic(Duration(milliseconds: 100), (timer) { 
      if(disposed){
        print('stage1');
      }

      else if(!gameStarted){

      }
      else if (wrongClick){
        
      }
      else if(timeLeft >0){
        setState(() {
          timeLeft = timeLeft-0.1;
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
        print('stage1');
      }
      else if(!startDown && !widget.solo){
        print('stage2');
      }
      else if(gamePlayTimeLeft >0){
         print('stage3');
        setState(() {
          gamePlayTimeLeft = gamePlayTimeLeft-1;
          // _slideController.value = (timeLeft-1).toDouble();
        });
      }
      
      else{
         print('stage4');
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
      else if(disposed){

      }
      else if (gamePlayDuration >=60){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 1.5;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=50){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 2.0;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=40){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 2.5;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=30){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 3;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if(gamePlayDuration >=15){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          gamePlayDuration = gamePlayDuration+1;
          resetValue = 4;
          // _slideController.value = (timeLeft-1).toDouble();
        });
      }
      
      else{
        // print(gamePlayDuration.toString() + ' is the duration');
        gamePlayDuration = gamePlayDuration+1;
      }
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
          _firebaseProvider.removeUserFromLobby(widget.variables.currentUser.uid, widget.lobbyId).then((value) {
      _firebaseProvider.submitUserScore(widget.variables.currentUser.uid, widget.lobbyId, currentPage*10);
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
    child: !widget.solo
    ?StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection("lobbies").doc(widget.lobbyId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // List<dynamic> players = snapshot.data['players'];
        // print(lastPlayer);
        if(snapshot.hasData){
          if(snapshot.data['players'].length<2){
            lastPlayer = true;
          }
          if(snapshot.data['active']){
             startDown = true;
            
          }
           
          else{
             startDown = false;
            
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
                    return profileCircle(width, height, index);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: profileNames.length,
                ),
            ),
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
                _firebaseProvider.addUserToLobby(widget.variables.currentUser.uid, widget.lobbyId);
                setState(() {
                  timeLeft = 5.5;
                  // _slideController.value = 5.5;
                  defeated = false;
                  resetValue = 6;
                  gamePlayDuration=0;
                  divider = 6;
                  finished = false;
                  wrongClick = false;
                  gameStarted = false;
                  gamePlayTimeLeft = 5;
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
                  Navigator.pop(context);
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
                    child: Text('Go Back', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          ],
        )
        ,
            )
          ],
        ):Column(
          children: [
            SizedBox(
              height: height*0.08,
            ),
            Container(
              height: height*0.15,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                    return profileCircle(width, height, index);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: profileNames.length,
                ),
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
            width: width*0.9,
            child:  LinearProgressIndicator(
             /*  color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555), */
              minHeight: 5,
              
              backgroundColor: Colors.transparent,
              value: timeLeft == divider?1:(timeLeft/(divider-1)).toDouble(),
              // value: _slideController.value,
              valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
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
                  itemCount: (footballers.length)*10,
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelect(width, height, index, item, snapshot),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
            Center(
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
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
              valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
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
                  itemCount: (footballers.length)*10,
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelect(width, height, index, item, snapshot),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
            Center(
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            )

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
                  height: height*0.2,
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
                gamePlayTimeLeft.toInt().toString(), style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 45, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          
              ],
            )
            )
            : widget.variables.currentUser.uid == widget.creatorId
            ? Container(
              height: height*0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                height: height*0.16,
              ),
                    Container(
                      height: height*0.4,
                      child: Column(
                        children: [
                          MaterialButton(
                onPressed: (){
                  _firebaseProvider.startLobbyGame(widget.creatorId, widget.lobbyId);
                },
                child:  Container(
              width: width*0.35*(pow(size, 0.5)),
              height: width*0.35*pow(size, 0.5),
              child: Center(
                child: Text(
                'Start', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 38, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
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
               MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
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
                    child: Text('Go Back', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
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
                  Navigator.pop(context);
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
                    child: Text('Go Back', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
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
             Container(
              height: height*0.15,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                    return profileCircle(width, height, index);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: profileNames.length,
                ),
            ),
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
                  _firebaseProvider.addUserToLobby(widget.variables.currentUser.uid, widget.lobbyId);
                }
                setState(() {
                  timeLeft = 5.5;
                  // _slideController.value = 5.5;
                  defeated = false;
                  resetValue = 6;
                  gamePlayDuration=0;
                  divider = 6;
                  finished = false;
                  wrongClick = false;
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
                  Navigator.pop(context);
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
                    child: Text('Go Back', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          ],
        )
        ,
            )
          ],
        ):Column(
          children: [
            SizedBox(
              height: height*0.08,
            ),
            Container(
              height: height*0.15,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) { 
                    return profileCircle(width, height, index);
                    //return CircularProgressIndicator();
                  },
                scrollDirection: Axis.horizontal,
                itemCount: profileNames.length,
                ),
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
            width: width*0.9,
            child:  LinearProgressIndicator(
             /*  color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555), */
              minHeight: 5,
              
              backgroundColor: Colors.transparent,
              value: timeLeft == divider?1:(timeLeft/(divider-1)).toDouble(),
              // value: _slideController.value,
              valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
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
                  itemCount: (footballers.length)*10,
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelect(width, height, index, item, null),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
            Center(
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            )

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
              valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
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
                  itemCount: (footballers.length)*10,
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelect(width, height, index, item, null),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
            Center(
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            )

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
                  height: height*0.2,
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
                gamePlayTimeLeft.toInt().toString(), style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
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

   bool compare(var first, var second){
    return first>second;
   }

   Widget profileCircle(var width, var height, int index){
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Container(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(profilePics[index])
              )
            ),
            width: width*0.1,
      height: width*0.1,
          ),
          SizedBox(height: height*0.02,),
          Center(
            child: Text('@'+profileNames[index], style: TextStyle(
              color: Colors.white, fontFamily:'Muli', fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic
            )),
          ),
          SizedBox(height: height*0.01,),
          Container(
            width: width*0.02,
            height: width*0.02,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff23ff89)
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
    _firebaseProvider.removeUserFromLobby(widget.variables.currentUser.uid, widget.lobbyId).then((value) {
      _firebaseProvider.submitUserScore(widget.variables.currentUser.uid, widget.lobbyId, currentPage*10);
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