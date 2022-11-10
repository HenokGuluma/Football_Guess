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
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/pages/add_lobby.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/insta_profile_screen.dart';

class LobbyDetails extends StatefulWidget {
 
 UserVariables variables;
 Lobby lobby;

 LobbyDetails({this.variables, this.lobby});
  @override
  _LobbyDetailsState createState() => _LobbyDetailsState();
}

class _LobbyDetailsState extends State<LobbyDetails>
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

  List<List<Map<String, dynamic>>> LobbyDetails = 
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
  AnimationController _animationController;
  AnimationController _bounceController;
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
  double size = 1;
  
  
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
                
           Padding(
            padding: EdgeInsets.only(top: height*0.05),
            child:  Center(
              child: Text(
                widget.lobby.name, style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            )
           )
              ],
            ),

               SizedBox(
              height: height*0.03,
            ),
           
          Padding(
            padding: EdgeInsets.only(top: height*0.05),
            child:  Center(
              child: Text(
                'Lobby Id: '+ widget.lobby.uid, style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            )
           ),
             SizedBox(
              height: height*0.03,
            ),

             Padding(
            padding: EdgeInsets.only(top: height*0.05),
            child:  Center(
              child: Text(
                'Lobby Id: '+ widget.lobby.uid, style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            )
           ),

           SizedBox(
              height: height*0.03,
            ),

            Padding(
            padding: EdgeInsets.only(top: height*0.05),
            child:  Center(
              child: Text(
                'Rate: '+ widget.lobby.rate.toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            )
           ),

            SizedBox(
              height: height*0.03,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 Padding(
            padding: EdgeInsets.only(top: height*0.05),
            child:  Center(
              child: Text(
                'Rate: '+ widget.lobby.rate.toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 15, fontWeight: FontWeight.w900, fontStyle: FontStyle.normal),
              ),
            )
           ),
           menuOption(width, height, widget.lobby.gameCategory, menuImages)
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
               Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyDetails();
                          return Footballers(category: categories[widget.lobby.gameCategory],);
                        },
                        ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.35,
              height: height*0.06,
              child: Center(
                child: Text('Join the lobby', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
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

    Widget menuOption(var width, var height, int index, List<String> images){
    return GestureDetector(
      
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
     
        ],
      )
    );
   }



  Widget lobbyItem(var width, var height, int index){
    return Padding(
      padding: EdgeInsets.only(top: height*0.03, bottom: height*0.03),
      child: GestureDetector(
      onTap: (){
         Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          return FootBallMenu(creating: false,);
                        },
                        ));
      },
      child: Container(
        width: width*0.3,
        height: height*0.25,
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
                image: DecorationImage(
                  image: AssetImage('assets/bankeru_blue.png'),
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
              height: height*0.03,
            ),
            Container(
              width: width*0.45,
              child: Center(
                child: Text(lobbies[index]['name'] , style: TextStyle(fontFamily: 'Muli', color: Color(0xffff4399), fontSize: 20, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis,),
              ),
            ),
            SizedBox(
              height: height*0.01,
            ),
            Container(
              width: width*0.45,
              child: Center(
                child: Text(lobbies[index]['lobbyId']+ '(' + lobbies[index]['price'].toString() + ' ETB)', style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis,),
              ),
            )
          ],
        ),
      ),
    )
    );
    }

   

}