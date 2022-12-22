import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/main_menu.dart';

class AddPublicLobby extends StatefulWidget {
  
  UserVariables variables;

  AddPublicLobby({this.variables});

  @override
  AddPublicLobbyState createState() => AddPublicLobbyState();
}

class AddPublicLobbyState extends State<AddPublicLobby>
    with TickerProviderStateMixin {
 
  AnimationController _animationController;
  AnimationController _bounceController;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _uidController= TextEditingController();
  TextEditingController _priorityController = TextEditingController();
  TextEditingController _rateController = TextEditingController();
  PageController _pageController;
  FirebaseProvider _firebaseProvider = FirebaseProvider();
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
  bool creating = false;
  bool available = false;
  bool checking = false;
  bool unavailable = false;
  bool userNameLongEnough = false;
  bool userNameShort = false;
  
  
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

  }

  
  Timer scheduleTimeout(milliseconds) =>
    Timer(Duration(milliseconds: milliseconds), handleTimeout);

void handleTimeout() {  // callback function
  setState(() {
    defeated = true;
  });
}

@override

  void dispose() {

    _bounceController.dispose();
    _animationController.dispose();
    super.dispose();

  }

    changeText(String text) {
    setState(() {});
  }

  updateText(String text) {
    setState(() {
      unavailable = false;
      available = false;
    });
    if(text.length>=7){
      setState(() {
        userNameShort = false;
        userNameLongEnough = true;
      });
    }
    else if (text.length>0 && text.length<7){
       setState(() {
        userNameShort = true;
        userNameLongEnough = false;
      });
    }
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
        child: ListView(
         /*  mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, */
          children: [
             SizedBox(
              height: height*0.1,
            ),
            Center(
              child: Text(
                'Create a Lobby', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            ),

               SizedBox(
              height: height*0.08,
            ),
         Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                    controller: _nameController,
                    autofocus: true,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: 'Lobby Name',
                      hintStyle: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.grey,
                          fontSize: 20.0),
                      labelText: 'Lobby Name',
                      labelStyle: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                    onChanged: changeText),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                    controller: _priorityController,
                    enabled: true,
                    maxLength: 5,
                    decoration: InputDecoration(
                      
                        hintText: 'Priority',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 20.0),
                        labelText: 'Priority',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 20.0)),
                    onChanged: changeText),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                    controller: _rateController,
                    enabled: true,
                    maxLength: 5,
                    decoration: InputDecoration(
                      
                        hintText: 'Rate (in ETB) (eg. 50)',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 20.0),
                        labelText: 'Rate (in ETB)',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 20.0)),
                    onChanged: changeText),
              ),
              
            ],
          ),

          SizedBox(
            height: height*0.05,
          ),
        
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
             _nameController.text.isNotEmpty && _rateController.text.isNotEmpty
             ?GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
               Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return SelectLobby();
                          return GameMenu(
                            public: true,
                            creating: true,
                            priority: int.parse(_priorityController.text),
                            editing: false,
                            uid: _uidController.text,
                            name: _nameController.text,
                            rate: _rateController.text,
                            thisUser: widget.variables.currentUser,
                            variables: widget.variables,
                          );
                        },
                        ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: creating?Color(0xff777777):Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text(creating?'Creating Lobby...':'Choose Game', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
            :Container(
              decoration: BoxDecoration(
                color: Color(0xff777777),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text('Choose Game', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
          ],
         )

          ],
        )
        
      ),
    
        ],
      ));
   
   }

 

}