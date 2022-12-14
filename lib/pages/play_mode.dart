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
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/lobby_menu.dart';
import 'package:instagram_clone/pages/login_screen.dart';
import 'package:instagram_clone/pages/main_menu.dart';
import 'package:instagram_clone/pages/select_lobby.dart';
import 'package:instagram_clone/pages/setup_profile.dart';
import 'package:just_audio/just_audio.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class PlayMode extends StatefulWidget {
 
  bool loggedIn;
  String email;
  String uid;

  PlayMode({this.loggedIn, this.email, this.uid});
  
  @override
  _PlayModeState createState() => _PlayModeState();
}

class _PlayModeState extends State<PlayMode>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<String> modes = ['assets/group.jpg', 'assets/solo.jpg'];
  List<String> options = ['Squad-Mode', 'Solo-Mode'];
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  AnimationController _animationController;
  AnimationController _slideController;
  PageController _pageController;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Animation _animation;
  var selectPlayer = AudioPlayer();
  var player = AudioPlayer();
  bool loggedIn;
  bool animate = false;
  bool correctPicked = false;
  int currentPage = 0;
  bool finished = false;
  int second = 6;
  double timeLeft = 6;
  double resetValue = 6;
  double divider = 6;
  bool defeated = false;
  bool wrongClick = false;
  int gamePlayDuration = 0;
  User currentUser = User();
  bool loading = true;
  List<String> phoneList = [];
  bool changeBackground = false;
  List<String> backgroundTracks = [
    'assets/sound-effects/adderall.mp3', 'assets/sound-effects/just-a-lil-bit.mp3', 'assets/sound-effects/middle.mp3',
    'assets/sound-effects/roses.mp3', 'assets/sound-effects/you-like-it.mp3', 'assets/sound-effects/sugar.mp3', 'assets/sound-effects/on&on.mp3', 'assets/sound-effects/runaway.mp3',
    'assets/sound-effects/this-girl.mp3', 'assets/sound-effects/spectre.mp3',
  ];
  

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
     //stop your audio player
     player.pause();
    }
    else if (state == AppLifecycleState.resumed){
      player.play();
    }
    else if (state == AppLifecycleState.inactive){
      player.stop();
    }
    else{
      print(state.toString());
    }
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
     loggedIn = widget.loggedIn;
     getCurrentUser().then((value) {
      setState(() {
        loading = false;
      });
    });

    Future.delayed(Duration(seconds: 5)).then((value) {
      setState(() {
        loading = false;
      });
    });
   
  /*  }
   else{
    setState(() {
      loading = false;
    });
    print('nope');
   } */
   setupSound().then((value) {
    playBackGroundMusic();
   });
  }

  playBackGroundMusic() async{
    Future.delayed(Duration(seconds: 2)).then((value) async {
      await player.play().then((value) {
        setState(() {
          changeBackground = true;
        });
      // selectSound();
    });
    });
    
  }

  pauseBackgroundMusic(){
    player.stop();
  }

  startBackgroundMusic() async{
    int index = Random().nextInt(9);
    await player.setAsset(backgroundTracks[index]);
    player.play();
  }

     Future<void> setupSound() async{
    int index = Random().nextInt(9);
    await selectPlayer.setAsset('assets/sound-effects/option-click-confirm.wav');
    await player.setAsset(backgroundTracks[index]);
    player.setVolume(0.1);
    selectPlayer.setVolume(0.1);
    selectPlayer.play();
    selectPlayer.stop();
  }

  selectSound() async{
    int index = Random().nextInt(9);
    await player.setAsset(backgroundTracks[index]);
    if(changeBackground){
      playBackGroundMusic();
      setState(() {
        changeBackground = false;
      });
    }
    
  }

  Timer scheduleTimeout(milliseconds) =>
    Timer(Duration(milliseconds: milliseconds), handleTimeout);

void handleTimeout() {  // callback function
  setState(() {
    defeated = true;
  });
}

    Future<void> getCurrentUser() async {
      print(widget.loggedIn); print (' is logged in');
      print(widget.email); print('Emmmmail');
    //  auth.User thisUser = await _firebaseProvider.getCurrentUser();
   await Future.delayed(Duration(seconds: 2));
   
     if(widget.loggedIn){
      User user = await _firebaseProvider.fetchUserDetailsById(widget.uid);
    setState(() {
      currentUser = user;
    });

      if(user.dailyTimer < DateTime.now().millisecondsSinceEpoch){
        _firebaseProvider.resetTokens(currentUser.uid);
        User newUser = currentUser;
        newUser.tokens = 5;
        setState(() {
          currentUser = newUser;
        });
      }
     }
     else{
      return;
     }

     getPhones();
    
  }

  
    Future<void> getPhones (){
    _firebaseProvider.getAllPhones().then((phoneNumbers) {
      List<String> phones = [];
      for(int i=0; i<phoneNumbers.length; i++){
        String phone = phoneNumbers[i].id;
        phones.add(phone);
      }
      setState(() {
              phoneList = phones;
              
              // loadingPhones = false;
            });
    });
    return null;
  }
   

  @override
  Widget build(BuildContext context) {
    UserVariables variables = Provider.of<UserVariables>(context, listen: false);
    if(currentUser.uid!=null){
      print('kaballllllam');
      // variables.setCurrentUser(currentUser);
    }
    else{
      print(' oh noooo');
    }
     var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if(widget.uid !=null){
       return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(widget.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          variables.setCurrentUser(User.fromDoc(snapshot.data));
        }
        variables.updatePhones(phoneList);
        return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/profile_background.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          loading
          ?Container(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
            child: Text(
                'Preparing Game', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
           Center(
            child: Text(
                'Sit back and Relax', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
          ),
              ],
            )
          )
          :
          Container(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             SizedBox(
              height: height*0.05,
            ),
            Text(
                'Pick a Game Mode', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.05,
            ),
            /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                menuOption(width, height, 0, menuImages),
                menuOption(width, height, 1, menuImages),
                menuOption(width, height, 2, menuImages),
              ],
            ) */
          Container(
            width: width,
            height: height*0.6,
            child:  ListView(
  padding: const EdgeInsets.all(5),
  children: <Widget>[
   menuOption(width, height, 0, modes, variables),
   SizedBox(height: height*0.08,),
   menuOption(width, height, 1, modes, variables),
  ],
),
          )

          ],
        )
        
      ),
    
        ],
      ));
   
      }
      );
    }
    else{
      return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/profile_background.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          loading
          ?Container(
            width: width,
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
            child: Text(
                'Preparing Game', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
           Center(
            child: Text(
                'Sit back and Relax', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
          ),
              ],
            )
          )
          :
          Container(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             SizedBox(
              height: height*0.05,
            ),
            Text(
                'Pick a Game Mode', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.05,
            ),
            /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                menuOption(width, height, 0, menuImages),
                menuOption(width, height, 1, menuImages),
                menuOption(width, height, 2, menuImages),
              ],
            ) */
          Container(
            width: width,
            height: height*0.6,
            child:  ListView(
  padding: const EdgeInsets.all(5),
  children: <Widget>[
   menuOption(width, height, 0, modes, variables),
   SizedBox(height: height*0.08,),
   menuOption(width, height, 1, modes, variables),
  ],
),
          )

          ],
        )
        
      ),
    
        ],
      ));
   
    }
   
   }

   bool compare(int first, int second){
    return first>second;
   }

   void finishNavigation(UserVariables variables){
    setState(() {
      loggedIn = true;
    });
     Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          return SelectLobby(variables: variables,);
                        },
                        ));
   }

   Widget menuOption(var width, var height, int index, List<String> images, UserVariables variables){
    return GestureDetector(
      onTap: (){
        selectPlayer.play();
        Future.delayed(Duration(milliseconds: 200)).then((value) {
           if (index == 1){
            Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return GameMenu(variables: variables, public: false, editing: false, creating: false, pauseBackground: pauseBackgroundMusic, startBackground: startBackgroundMusic,);
                        },
                        ));
        }
        else if(!loggedIn && variables.currentUser.uid==null ){
          print(variables.currentUser.uid); print (' is the uid');
          print(widget.loggedIn); print (' is loggedddd in');
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return  LoginScreen(finishStage: finishNavigation, variables: variables, pauseBackground: pauseBackgroundMusic, startBackground: startBackgroundMusic,);
                        },
                        ));
        }
         else if(widget.email!=null && variables.currentUser==null){
          print(variables.keys); print (' is the keys');
          print(widget.email);
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return  SetupProfile(userId: widget.uid, emailAddress: widget.email,
                          name: variables.currentUser.userName, finishNavigation: finishNavigation, variables: variables,pauseBackground: pauseBackgroundMusic, startBackground: startBackgroundMusic,
                          );
                        },
                        ));
        }
        else{
          print(widget.loggedIn); print (' is loggedddd in');
          print(widget.email);
          print(variables.currentUser.uid);
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return SelectLobby(variables: variables, pauseBackground: pauseBackgroundMusic, startBackground: startBackgroundMusic,);
                        },
                        ));
        }
        });
        Future.delayed(Duration(seconds: 1)).then((value) {
          selectPlayer.stop();
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
        width: width*0.7,
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
        width: width*0.7,
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
        width: width*0.7,
        height: width*0.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
         
        ),
        child: Center(
          child: Text(options[index], style: TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Muli', fontWeight: FontWeight.w900),)
        ),
      ),
        ],
      )
    );
   }


   

}