import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/pages/add_lobby.dart';
import 'package:instagram_clone/pages/add_public_lobby.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/insta_profile_screen.dart';
import 'package:instagram_clone/pages/lobby_details.dart';
import 'package:just_audio/just_audio.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Joining extends StatefulWidget {
 
 UserVariables variables;
 Function stopBackground;
 int gameType;
 int gameCategory;
 int rate;

 Joining({this.variables, this.rate, this.stopBackground, this.gameCategory, this.gameType});
  @override
  _JoiningState createState() => _JoiningState();
}

class _JoiningState extends State<Joining>
    with TickerProviderStateMixin {
  
  List<String> menuImages = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png'];
  List<String> modes = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png', 'assets/blackjack-option.png', 'assets/bank_vault.png', 'assets/roulette.png', 'assets/jackpot.png'];
  List<String> modeNames = ['Rapid-Jersey', 'Rapid-Goals', 'Rapid-Age', 'Rapid-Height', 'BlackJack', 'Bankeru', 'Spinner', 'JackPot',];
  List<String> rateChoices = ['100 ETB', '50 ETB', '20 ETB', '5 ETB'];
  List<String> rateNames = ['Legends', 'Pro', 'Plus', 'Basic'];
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  Lobby publicLobby;
  bool loading = true;
  Timer _timer;
  bool disposed = false;
  bool navigated = false;
  
  
  @override
  void initState() {
    print(' game type is'); print(widget.gameType);
    super.initState();
    startSkipTimer();
    getPublicLobby();
  }

 


getPublicLobby(){
  _firebaseProvider.getPublicLobbyWithSpecs(widget.gameType, widget.gameCategory, widget.rate).then((lobby) {
    setState(() {
      publicLobby = lobby;
      loading = false;
    });
  });
}

void startSkipTimer() {
  
  const oneSec = const Duration(milliseconds: 100);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      
    if(!loading && publicLobby!=null && !navigated){
      setState(() {
        navigated = true;
      });
        // print('eeerrrrooooorrrrrrrrr');
         Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          return LobbyDetails(variables: widget.variables, lobby: publicLobby, rate: widget.rate, public: true, stopBackground: widget.stopBackground,);
                        },
                        ));
      }
      else{
        
      }
      
    },
  );
}

@override

  void dispose() {
    super.dispose();

  }
   

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage('assets/lobby.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          Container(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           
             Center(
              child: Text(
                'Searching for available lobby...', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center
              ),
            ),
            SizedBox(
              height: height*0.1,
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffff2389),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.3,
              height: height*0.06,
              child: Center(
                child: Text('Go Back', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),

          ],
        )
        
      ),
    
        ],
      ));
   
   }

   

}