import 'dart:async';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
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
import 'package:instagram_clone/pages/setup_profile.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class PlayMode extends StatefulWidget {
 

  @override
  _PlayModeState createState() => _PlayModeState();
}

class _PlayModeState extends State<PlayMode>
    with TickerProviderStateMixin {
  List<String> modes = ['assets/group.jpg', 'assets/solo.jpg'];
  List<String> options = ['Squad-Mode', 'Solo-Mode'];
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  AnimationController _animationController;
  AnimationController _slideController;
  PageController _pageController;
  Animation _animation;
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
  
  
  @override
  void initState() {
    super.initState();
    getCurrentUser().then((value) {
      loading = false;
    });
  }

  
  Timer scheduleTimeout(milliseconds) =>
    Timer(Duration(milliseconds: milliseconds), handleTimeout);

void handleTimeout() {  // callback function
  setState(() {
    defeated = true;
  });
}

    Future<void> getCurrentUser() async {
     auth.User thisUser = await _firebaseProvider.getCurrentUser();
    User user = await _firebaseProvider.fetchUserDetailsById(thisUser.uid);
    setState(() {
      currentUser = user;
    });
  }
   

  @override
  Widget build(BuildContext context) {
    UserVariables variables = Provider.of<UserVariables>(context, listen: false);
    if(currentUser.uid!=null){
      variables.setCurrentUser(currentUser);
    }
     var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
 
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/game_play.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          loading
          ?Container(
            width: width,
            height: height,
            child: Column(
              children: [
                Center(
            child: Text(
                'Preparing Game', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,)

              ],
            )
          )
          :Container(
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
            height: height*0.7,
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

   bool compare(int first, int second){
    return first>second;
   }

   void finishNavigation(){
     Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          return LobbyMenu();
                        },
                        ));
   }

   Widget menuOption(var width, var height, int index, List<String> images, UserVariables variables){
    return GestureDetector(
      onTap: (){
        if (index == 1){
            Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return FootBallMenu();
                        },
                        ));
        }
        else if(variables.currentUser.uid==null || variables.currentUser.uid.isEmpty){
          print(variables.keys); print (' is the keys');
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return  LoginScreen(finishStage: finishNavigation, variables: variables,);
                        },
                        ));
        }
        else{
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return LobbyMenu(variables: variables,);
                        },
                        ));
        }
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