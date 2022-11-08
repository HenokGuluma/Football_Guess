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

class AddLobby extends StatefulWidget {
  
  UserVariables variables;

  AddLobby({this.variables});

  @override
  _AddLobbyState createState() => _AddLobbyState();
}

class _AddLobbyState extends State<AddLobby>
    with TickerProviderStateMixin {
 
  AnimationController _animationController;
  AnimationController _bounceController;
  TextEditingController _nameController;
  TextEditingController _uidController;
  TextEditingController _rateController;
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
              height: height*0.03,
            ),
            Text(
                'Join a Lobby', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),

               SizedBox(
              height: height*0.03,
            ),
         Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.black),
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Lobby Name',
                      hintStyle: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.grey,
                          fontSize: 20.0),
                      labelText: 'Lobby Name',
                      labelStyle: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 20.0),
                    ),
                    onChanged: changeText),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                  inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')),
              ],
                    style: TextStyle(fontFamily: 'Muli', color: Colors.black),
                    controller: _uidController,
                    maxLines: 3,
                    maxLength: 150,
                    decoration: InputDecoration(
                        hintText: 'Lobby Identifier',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 20.0),
                        labelText: 'Lobby Identifier',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 20.0)),
                    onChanged: updateText),
              ),

              unavailable
              ?Container(
                 
                  // width: width*0.4,
                  height: height*0.03,
                  child: Center(
                    child: Text('Identifier already exists', style: TextStyle(color: Color(0xffff2389), fontSize: 14, fontFamily: 'Muli')),
                  ),
                )
              :available
              ?Container(
                 
                  // width: width*0.4,
                  height: height*0.03,
                  child: Center(
                    child: Text('Identifier Available', style: TextStyle(color: Color(0xff23ff89), fontSize: 14, fontFamily: 'Muli')),
                  ),
                )
              :MaterialButton(
                onPressed:(){
                  _firebaseProvider.fetchLobbyById(_uidController.text).then((value) {
                    if(value!=null){
                      setState(() {
                        unavailable = true;
                      });
                    }
                    else{
                      setState(() {
                        available = true;
                      });
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: checking?Color(0xff777777):Colors.white,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  width: width*0.4,
                  height: height*0.03,
                  child: Center(
                    child: Text(checking?'Checking...':'Check Availability', style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Muli')),
                  ),
                ),
                 ),
             
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                    style: TextStyle(fontFamily: 'Muli', color: Colors.black),
                    controller: _rateController,
                    enabled: false,
                    decoration: InputDecoration(
                        hintText: 'Rate (in ETB) (eg. 50)',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 20.0),
                        labelText: 'Rate Per Game',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 20.0)),
                    onChanged: changeText),
              ),
              
            ],
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
             GestureDetector(
            onTap: (){
              setState(() {
                creating = true;
              });
              Lobby lobby = Lobby(
                uid: _uidController.text,
                name: _nameController.text,
                rate: double.parse(_rateController.text),
                players: [widget.variables.currentUser]
              );
              _firebaseProvider.addLobbyById('id', lobby, widget.variables.currentUser.uid).then((value) {
                widget.variables.setLobby(lobby);
                Navigator.pop(context);
                
                Flushbar(
                  title: 'Created a Lobby',
                  backgroundColor: Color(0xff00ffff),
                  titleText: Text('Successfully created the lobby', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli')),
                );
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: creating?Color(0xff777777):Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text(creating?'Creating Lobby...':'Confirm Lobby', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            )
          ],
         )

          ],
        )
        
      ),
    
        ],
      ));
   
   }

 

}