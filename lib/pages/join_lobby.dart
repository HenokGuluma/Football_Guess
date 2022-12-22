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

class JoinLobby extends StatefulWidget {
 
 UserVariables variables;
 Function stopBackground;
 int gameType;
 int gameCategory;

 JoinLobby({this.variables, this.stopBackground, this.gameCategory, this.gameType});
  @override
  _JoinLobbyState createState() => _JoinLobbyState();
}

class _JoinLobbyState extends State<JoinLobby>
    with TickerProviderStateMixin {
  List<List<String>> images = 
  [['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png']
  ];

  List<Map<String, dynamic>> lobbies = 
  [{'name':'Mangwams', 'lobbyId': '@mangwams', 'price': 10}, 
  {'name':'Suicide-Squad', 'lobbyId': '@suicideSquad', 'price': 50},
  {'name':'Garri-Jema', 'lobbyId': '@garriJema', 'price': 25},
 {'name':'Planet-Doom', 'lobbyId': '@planetDoom', 'price': 100}];

  List<String> categories = ['Number', 'Goals', 'Age', 'Height'];
  List<String> categoryId = ['jersey', 'goals', 'age', 'height'];

  List<String> menuImages = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png'];
  List<String> modes = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png', 'assets/blackjack-option.png', 'assets/bank_vault.png', 'assets/roulette.png', 'assets/jackpot.png'];
  List<String> modeNames = ['Rapid-Jersey', 'Rapid-Goals', 'Rapid-Age', 'Rapid-Height', 'BlackJack', 'Bankeru', 'Spinner-Wheel', 'JackPot',];
  List<String> rateChoices = ['100 ETB', '50 ETB', '20 ETB', '5 ETB'];
  List<String> rateNames = ['Legends', 'Pro', 'Plus', 'Basic'];
  AnimationController _animationController;
  AnimationController _bounceController;
  PageController _pageController;
  var _firebaseProvider = FirebaseProvider();
  var cancel = AudioPlayer();
   var player = AudioPlayer();
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
  double size = 1;
  List<Lobby> publicLobbies = [];
  bool loading = false;
  
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500), upperBound: 1.2, lowerBound: 1);
     _animationController.repeat(reverse: true);
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
_animationController.addListener(() {

      setState(() {
           size = _animationController.value;
      });

     });
    //  getPublicLobbies();
     setupSound();
  }

  
  Timer scheduleTimeout(milliseconds) =>
    Timer(Duration(milliseconds: milliseconds), handleTimeout);

void handleTimeout() {  // callback function
  setState(() {
    defeated = true;
  });
}

 Future<void> setupSound() async{
    await player.setAsset('assets/sound-effects/option-click-confirm.wav');
    await cancel.setAsset('assets/sound-effects/option-click.wav');
    player.setVolume(0.1);
    cancel.setVolume(0.1);
    cancel.play();
    cancel.stop();

  }

getPublicLobbies(){
  _firebaseProvider.getPublicLobbiesCategory(widget.gameType, widget.gameCategory).then((list) {
    List<dynamic> arrangedList = list;
    arrangedList.sort((a, b) => a.rate.compareTo(b.rate));
    setState(() {
      publicLobbies = arrangedList.reversed.toList();
      loading = false;
    });
  });
}

@override

  void dispose() {

    _bounceController.dispose();
    _animationController.dispose();
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
             SizedBox(
              height: height*0.01,
            ),
            Stack(
              children: [
                Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: IconButton(
                onPressed: (){
                  player.play();
                    Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return JoinLobby();
                          return InstaProfileScreen(variables: widget.variables,);
                        },
                        ));
                        Future.delayed(Duration(seconds: 1)).then((value) {
                          player.stop();
                        });
                },
                icon: Container(
                  
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.variables.currentUser.photoUrl!=null?widget.variables.currentUser.photoUrl:''),
                      fit: BoxFit.cover
                    )
                  ),
                  width: height*0.05,
                  height: height*0.05,
                ),
              )),
            ),
           Padding(
            padding: EdgeInsets.only(top: height*0.05),
            child:  Center(
              child: Text(
                'Join a Lobby', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            )
           )
              ],
            ),

               SizedBox(
              height: height*0.03,
            ),
           
            /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                lobbyItem(width, height, 0, menuImages),
                lobbyItem(width, height, 1, menuImages),
                lobbyItem(width, height, 2, menuImages),
              ],
            ) */
          Container(
            width: width,
            height: height*0.75,
            child:  loading
            ?Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Center(
            child: Text(
                'Getting Public Lobbies', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
                ],
              ),
            )
            :Container(
              height: height*0.75,
              width: width*0.9,
              child: Center(
                child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // A grid view with 3 items per row
          crossAxisCount: 2,
          childAspectRatio: 0.9
        ),
        itemCount: rateChoices.length,
        itemBuilder: (_, index) {
          return lobbyItem(width, height, index);
        },
      ),
              ),
            )
          ), 

         
         widget.variables.currentUser.admin
         ?Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             GestureDetector(
            onTap: (){
              cancel.play();
              Navigator.pop(context);
              Future.delayed(Duration(seconds: 1)).then((value){
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
                child: Text('Go Back', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
             GestureDetector(
            onTap: (){
              player.play();
               Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return JoinLobby();
                          return  AddPublicLobby(variables: widget.variables);
                        },
                        ));
                         Future.delayed(Duration(seconds: 1)).then((value) {
                          player.stop();
                        });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text('Create a Lobby', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
          ],
         )
         :GestureDetector(
            onTap: (){
               cancel.play();
              Navigator.pop(context);
              Future.delayed(Duration(seconds: 1)).then((value){
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

  Widget lobbyItem(var width, var height, int index){
    // Lobby lobby = publicLobbies[index];
    return Padding(
      padding: EdgeInsets.only(top: width*0.03, bottom: width*0.03),
      child: GestureDetector(
      onTap: (){
        player.play();
        print(widget.stopBackground); print(' is the background');
        /*  Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          return LobbyDetails(variables: widget.variables, lobby: lobby, public: true, stopBackground: widget.stopBackground);
                        },
                        )); */
                         Future.delayed(Duration(seconds: 1)).then((value) {
                          player.stop();
                        });
      },
      child: Container(
        width: width*0.3,
        height: width*0.45,
        child: Column(
          children: [
            SizedBox(
              width: width*0.3,
              height: width*0.3,
              child: Column(
                children: [
                  Container(
              width: width*0.25*(pow(size, 0.5)),
              height: width*0.25*pow(size, 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage(widget.gameType==0?menuImages[widget.gameCategory]:modes[widget.gameType]),
                  fit: BoxFit.cover
                ),
                 boxShadow: [BoxShadow(
            color: Color(0xff00ffff),
            blurRadius: pow(_animation.value, 5)/200000,
            spreadRadius: pow(_animation.value, 5)/200000
          )],
              ),
            ),
                ],
              )
            ),
            SizedBox(
              height: width*0.03,
            ),
            Container(
              width: width*0.45,
              child: Center(
                child: Text(widget.gameType==0?modeNames[widget.gameCategory] + rateNames[index]:modeNames[widget.gameType] + rateNames[index], style: TextStyle(fontFamily: 'Muli', color: Color(0xffff4399), fontSize: 20, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis,),
              ),
            ),
            SizedBox(
              height: height*0.01,
            ),
            Container(
              width: width*0.45,
              child: Center(
                child: Text(rateChoices[index].toString() + ' ETB', style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis,),
              ),
            )
          ],
        ),
      ),
    )
    );
    }

   

}