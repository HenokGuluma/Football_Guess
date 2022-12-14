import 'dart:async';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
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
import 'package:instagram_clone/pages/footballers.dart';
import 'package:just_audio/just_audio.dart';

class FootBallMenu extends StatefulWidget {
 
  bool creating;
  bool public;
  String uid;
  String name;
  String rate;
  bool editing;
  User thisUser;
  int gameCategory;
  int priority;
  UserVariables variables;
  Function pauseBackground;
  Function startBackground;


  FootBallMenu({this.creating, this.priority, this.editing, this.public, this.uid, this.name, this.rate, this.gameCategory, this.thisUser, this.variables, this.pauseBackground, this.startBackground});
  @override
  _FootBallMenuState createState() => _FootBallMenuState();
}

class _FootBallMenuState extends State<FootBallMenu>
    with TickerProviderStateMixin {
  List<List<String>> images = 
  [['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png']
  ];

  FirebaseProvider _firebaseProvider = FirebaseProvider();

  List<String> categories = ['Jersey No.', 'Goals', 'Age', 'Height'];
  List<String> categoryId = ['jersey', 'goals', 'age', 'height'];
  int selectedIndex;

  List<String> menuImages = ['assets/football2.jpg', 'assets/football3.jpg','assets/football4.jpg',  'assets/football1.png'];

  List<List<Map<String, dynamic>>> FootBallMenu = 
  [
    [
      {'name': 'Alexis Sanchez', 'age': 33, 'image':'assets/Alexis-Sanchez.png' },
      {'name': 'Paul Pogba', 'age': 29, 'image':'assets/Paul-Pogba.png' },
    ],
    [
      {'name': 'Lionel Messi', 'age': 35, 'image':'assets/Lionel-Messi.png' },
       {'name': 'Christiano Ronaldo', 'age': 37, 'image':'assets/Christiano-Ronaldo.png'},
    ],
    
    [
      {'name': 'Kylian Mbappe', 'age': 23, 'image':'assets/Kylian-Mbappe.png' },
      {'name': 'Bukayo-Saka', 'age': 21, 'image':'assets/Bukayo-Saka.png' },
    ],
     [
      {'name': 'Karim Benzema', 'age': 34, 'image':'assets/Karim-Benzema.png'},
      {'name': 'Luka Modric', 'age': 37, 'image':'assets/Luca-Modric.png' },
    ],
   
    [
      {'name': 'Sadio Mane', 'age': 31, 'image':'assets/Sadio-Mane.png' },
      {'name': 'Mohammed Salah', 'age': 30, 'image':'assets/Mohammed-Salah.png' },
    ]
  ];
  AnimationController _fadeController;
  final player = AudioPlayer(); 
  var cancel = AudioPlayer();
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
  bool creating = false;
  
  
  @override
  void initState() {
    super.initState();
    if(widget.gameCategory!=null){
      selectedIndex = widget.gameCategory;
    }
    _fadeController = AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    _animation = Tween(begin: 1.0, end: 0.0).animate(_fadeController);
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

  }

@override
  void dispose() {
    // TODO: implement dispose
    _fadeController.dispose();
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
                image: AssetImage('assets/stadium.png'),
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
              height: height*0.05,
            ),
            Text(
                'Pick a Category', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
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
            child:  GridView.count(
  primary: false,
  padding: const EdgeInsets.all(5),
  crossAxisSpacing: 0,
  mainAxisSpacing: height*0.03,
  crossAxisCount: 2,
  children: <Widget>[
   menuOption(width, height, 0, menuImages),
   menuOption(width, height, 1, menuImages),
   menuOption(width, height, 2, menuImages),
   menuOption(width, height, 3, menuImages),
  ],
),
          ), 

          SizedBox(height: height*0.02,),
           !widget.creating
            ?GestureDetector(
            onTap: (){
               cancel.play();
              Navigator.pop(context);
              Future.delayed(Duration(seconds: 1)).then((value) {
                cancel.stop();
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
                child: Text('Go Back', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
          :Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                 GestureDetector(
            onTap: (){
               cancel.play();
              Navigator.pop(context);
              Future.delayed(Duration(seconds: 1)).then((value) {
                cancel.stop();
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
                child: Text('Go Back', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
            selectedIndex==null
            ?Container(
              decoration: BoxDecoration(
                color: Color(0xff777777),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text('Confirm Lobby', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )
            :creating
            ?Container(
              decoration: BoxDecoration(
                color: Color(0xff777777),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.45,
              height: height*0.06,
              child: Center(
                child: Text('Confirming Lobby', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            )
            :GestureDetector(
            onTap: (){
             print('dammmmn');
              setState(() {
                creating = true;
              });
              Lobby lobby = Lobby(
                uid: widget.uid,
                name: widget.name,
                rate: double.parse(widget.rate),
                players: [],
                gameType: 0,
                gameCategory: selectedIndex,
                creationDate: DateTime.now().millisecondsSinceEpoch,
                creatorId: widget.variables.currentUser.uid,
                creatorName: widget.variables.currentUser.userName,
              );
              print(widget.variables.currentUser.uid); print(' is the user');
            if(widget.public){
                if(widget.editing){
                   _firebaseProvider.editPublicLobby(lobby).then((value) {
                
                Flushbar(
                  title: 'Created a Lobby',
                  backgroundColor: Color(0xff00ffff),
                  titleText: Text('Successfully edited the lobby', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli')),
                );

                widget.pauseBackground();

                 Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => MyApp())),
                              (Route<dynamic> route) => false,
                            );
              });
                }
                else{
                 _firebaseProvider.addPublicLobby(lobby, widget.priority).then((value) {
                
                Flushbar(
                  title: 'Created a Lobby',
                  backgroundColor: Color(0xff00ffff),
                  titleText: Text('Successfully created the lobby', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli')),
                );

                 widget.pauseBackground();

                 Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => MyApp())),
                              (Route<dynamic> route) => false,
                            );
              });
              }
              }
              else{
                 if(widget.editing){
                  _firebaseProvider.editLobbyById(widget.uid, lobby, widget.thisUser).then((value) {
                widget.variables.setLobby(lobby);
                
                
                Flushbar(
                  title: 'Created a Lobby',
                  backgroundColor: Color(0xff00ffff),
                  titleText: Text('Successfully edited the lobby', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli')),
                );

                 widget.pauseBackground();

                 Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => MyApp())),
                              (Route<dynamic> route) => false,
                            );
              });
                 }
                 else{
                  _firebaseProvider.addLobbyById(widget.uid, lobby, widget.thisUser).then((value) {
                widget.variables.setLobby(lobby);
                
                 widget.pauseBackground();
                Flushbar(
                  title: 'Created a Lobby',
                  backgroundColor: Color(0xff00ffff),
                  titleText: Text('Successfully created the lobby', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli')),
                );

                 Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => MyApp())),
                              (Route<dynamic> route) => false,
                            );
              });
                 }
              }
             
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff23ff89),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text('Confirm Lobby', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
            
            ],
          ),
       

          ],
        )
        
      ),
    
        ],
      ));
   }

   bool compare(int first, int second){
    return first>second;
   }

   Widget menuOption(var width, var height, int index, List<String> images){
    return GestureDetector(
      onTap: (){
        if(widget.creating){
          setState(() {
            selectedIndex = index;
          });
        }
        else{
          // _fadeController.forward();
          player.play();
          // widget.pauseBackground();
          Future.delayed(Duration(milliseconds: 300)).then((value) {
              Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          return Footballers(category: categoryId[index], solo: true, public: false, categoryNo: index, startBackground: widget.startBackground, pauseBackground: widget.pauseBackground,);
                        },
                        ));
          });

          Future.delayed(Duration(seconds: 1)).then((value) {
            player.stop();
          });
        
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
        width: width*0.4,
        height: width*0.8,
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
        height: width*0.6,
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
        width: width*0.4,
        height: width*0.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
         
        ),
        child: Center(
          child: Text(categories[index], style: TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Muli', fontWeight: FontWeight.w900),)
        ),
      ),
      selectedIndex == index
      ?Container(
        width: width*0.4,
        height: width*0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
         
        ),
        child: Center(
          child: Icon(Icons.check, size: 40, color: Color(0xff23ff89),)
          ),
      )
      :Center(),
        ],
      )
    );
   }


   

}