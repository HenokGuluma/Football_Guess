import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/pages/add_lobby.dart';
import 'package:instagram_clone/pages/add_public_lobby.dart';
import 'package:instagram_clone/pages/bankeru_multiplayer.dart';
import 'package:instagram_clone/pages/black_jack_multiplayer.dart';
import 'package:instagram_clone/pages/closest_number_multiplayer.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/insta_profile_screen.dart';
import 'package:instagram_clone/pages/lobby_details.dart';
import 'package:instagram_clone/pages/spinning_wheel.dart';
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
   List<String> categoryId = ['jersey', 'goals', 'age', 'height'];
  List<String> rateNames = ['Legends', 'Pro', 'Plus', 'Basic'];
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  Lobby publicLobby;
  bool loading = true;
  Timer _timer;
  bool disposed = false;
  bool navigated = false;
    final cancel = AudioPlayer();
  final selectPlayer = AudioPlayer();
  
  
  @override
  void initState() {
    print(' game type is'); print(widget.gameType);
    super.initState();
    startSkipTimer();
    getPublicLobby();
    setupSound();
  }

   Future<void> setupSound() async{
    await selectPlayer.setAsset('assets/sound-effects/option-click-confirm.wav');
    await cancel.setAsset('assets/sound-effects/option-click.wav');
    selectPlayer.setVolume(0.1);
    cancel.setVolume(0.1);
    cancel.play();
    cancel.stop();
  }

 


getPublicLobby(){
  _firebaseProvider.getPublicLobbyWithSpecs(widget.gameType, widget.gameCategory, widget.rate).then((lobby) {
    setState(() {
      publicLobby = lobby;
    });
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {
        loading = false;
      });
    });
  });
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
        'You do not have enough balance in your wallet to join this lobby.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black), textAlign: TextAlign.center
      )),
    )..show(context);
  }

void startSkipTimer() {
  
  const oneSec = const Duration(milliseconds: 100);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) {
      
    if(publicLobby.uid!=null && !navigated){
      setState(() {
        navigated = true;
      });
        selectPlayer.play();
              print(publicLobby.gameCategory); print(' is the category');
              if(widget.variables.currentUser.coins < publicLobby.rate.toInt()){
                showFlushbar(context);
              }
              else {
                if(publicLobby.gameType == 4){
                  _firebaseProvider.addUserToClosestPublicLobby(widget.variables.currentUser, publicLobby.uid, widget.rate).then((value) {
                
                 Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                         
                          return ClosestMultiplayer(category: '0', public: true,  returnBack: returnBack, rate: publicLobby.rate.toInt(), lobbyId: publicLobby.uid, solo: false, variables: widget.variables, categoryNo: 0, creatorId: publicLobby.creatorId);
                          },
                        )).then((value) {
                         
                        });
              });
                }
                else{
                 _firebaseProvider.addUserToPublicLobby(widget.variables.currentUser, publicLobby.uid, widget.rate).then((value) {
                widget.stopBackground();
                 Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          if(publicLobby.gameType == 0){
                            return Footballers(public: true, returnBack: returnBack, category: categoryId[publicLobby.gameCategory], lobbyId: publicLobby.uid, solo: false, creatorId: publicLobby.creatorId, variables: widget.variables, categoryNo: publicLobby.gameCategory, rate: publicLobby.rate.toInt(),);
                          }
                          else if (publicLobby.gameType ==1){
                           
                            return BlackJackMultiplayer(public: true, returnBack: returnBack, category: '0', lobbyId: publicLobby.uid, solo: false, variables: widget.variables, categoryNo: 0, creatorId: publicLobby.creatorId, rate: publicLobby.rate.toInt(),);
                          }
                          else if (publicLobby.gameType ==2){
                            return BankeruMultiplayer(public: true, returnBack: returnBack, category: '0', lobbyId: publicLobby.uid, solo: false, variables: widget.variables, categoryNo: 0, creatorId: publicLobby.creatorId, rate: publicLobby.rate.toInt());
                          }
                          return SpinningBaby(public: true, returnBack: returnBack, category: '0', lobbyId: publicLobby.uid, solo: false, variables: widget.variables, categoryNo: 0, creatorId: publicLobby.creatorId, rate: publicLobby.rate.toInt());
                          },
                        )).then((value) {
                         
                        });
              });
              }
              }
              

              User newUser = widget.variables.currentUser;
              int wallet = newUser.coins;
              wallet = wallet - widget.rate;
              widget.variables.setCurrentUser(newUser);
              
              Future.delayed(Duration(seconds: 1)).then((value) {
                selectPlayer.stop();
              });
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

  returnBack(){
    Navigator.pop(context);
    print('returnedddd');
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
           
             loading
             ?Center(
              child: Text(
                'Searching for available lobby...', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center
              ),
            )
            :publicLobby==null
            ?Center(
              child: Text(
                'No available lobbies at the time.', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center
              ),
            )
            :Center(
              child: Text(
                'Joining the lobby momentarily', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), textAlign: TextAlign.center
              ),
            )
            ,
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