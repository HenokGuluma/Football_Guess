import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/pages/add_lobby.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/insta_profile_screen.dart';
import 'package:instagram_clone/pages/lobby_details.dart';
import 'package:instagram_clone/pages/lobby_menu.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SelectLobby extends StatefulWidget {
 
 UserVariables variables;

 SelectLobby({this.variables});
  @override
  _SelectLobbyState createState() => _SelectLobbyState();
}

class _SelectLobbyState extends State<SelectLobby>
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

  List<List<Map<String, dynamic>>> SelectLobby = 
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
  Lobby searchedLobby;
  PageController _pageController;
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  TextEditingController controller = TextEditingController();
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
  bool searching = false;
  
  
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
        child: ListView(
          /* mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center, */
          children: [
             SizedBox(
              height: height*0.02,
            ),
            Stack(
              children: [
                Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: IconButton(
                onPressed: (){
                  FocusScope.of(context).unfocus();
                    Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return SelectLobby();
                          return InstaProfileScreen(variables: widget.variables,);
                        },
                        ));
                },
                icon: Container(
                  
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: widget.variables.currentUser.photoUrl!=null
                      ?CachedNetworkImageProvider(widget.variables.currentUser.photoUrl)
                      :AssetImage('assets/grey.png')
                      ,
                      fit: BoxFit.cover
                    )
                  ),
                  width: height*0.05,
                  height: height*0.05,
                ),
              )),
            ),
           Padding(
            padding: EdgeInsets.only(top: height*0.15),
            child:  Center(
              child: Text(
                'Select a Lobby', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            )
           )
              ],
            ),

               SizedBox(
              height: height*0.03,
            ),
           
          
          Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: width*0.08,
                        ),
                        Container(
                      width: width * 0.6,
                      height: height*0.06,
                      decoration: BoxDecoration(
                          color: Color(0xfff1f1f1),
                          // border: Border.all(color: Colors.grey, width: 0.5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: <Widget>[
                          Center(
                            child: IconButton(
                              alignment: Alignment.topRight,
                              icon: SvgPicture.asset("assets/search.svg",
                                  width: 15, height: 15, color: Colors.black),
                            ),
                          ),
                          Center(
                              child: Container(
                            width: width * 0.4,
                            height: 30,
                            padding: EdgeInsets.only(left: 5, top: 0),
                            child: TextField(
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                              controller: controller,
                              cursorColor: Colors.black,
                              autofocus: false,
                              focusNode: FocusNode(),
                              cursorHeight: 20,
                              maxLength: 20,
                              cursorWidth: 0.5,
                              onChanged: searchQuery,
                              decoration: InputDecoration(
                                  hintText: 'Search by lobby Id',
                                  // contentPadding: EdgeInsets.only(bottom: 20),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff999999),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900)),
                            ),
                          )),
                       
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width*0.02,
                    ),
                    GestureDetector(
            onTap: (){
              setState(() {
                searching = true;
              });
              _firebaseProvider.getLobbyById(controller.text).then((lobby) {
                setState(() {
                  searchedLobby = lobby;
                  searching = false;
                });
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff00ffff),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.2,
              height: height*0.05,
              child: Center(
                child: Text('Search', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
                      ],
                    ))),

                    SizedBox(height: height*0.12,),

                  
           

         Center(
          child: 
          searching
          ?Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
            child: Text(
                'Searching for lobby', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
          ),
          JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 70,),
          
              ],
            )
          :searchedLobby==null
          ?GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
               Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return SelectLobby();
                          return  LobbyMenu(variables: widget.variables,);
                        },
                        ));
            },
            child:Container(
            width: width*0.4,
            height: width*0.4,
            child: Column(
              children: [
                Container(
                  child: Center(
                    child: Container(
                    width: width*0.2,
                    child: Text('Public Lobbies', style: TextStyle(color: Colors.black, fontSize: width*0.06, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                  )),
              width: width*0.35*(pow(size, 0.5)),
              height: width*0.35*pow(size, 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                /*  boxShadow: [BoxShadow(
            color: Color(0xff00ffff),
            blurRadius: pow(_animation.value, 5)/200000,
            spreadRadius: pow(_animation.value, 5)/200000
          )], */
              ),
            ),
         
              ],
            ),
          ))
          :searchedLobby.uid ==null
          ?Container(
            height: height*0.15,
            child: Center(
            child: Text('No lobby with that Id', style: TextStyle(color: Colors.white, fontSize: width*0.06, fontFamily: 'Muli', fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                  
          ),
          )
          :lobbyItem(width, height, searchedLobby)
          ),

          SizedBox(
            height: searchedLobby!=null?height*0.07:height*0.12,
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
              FocusScope.of(context).unfocus();
               Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return SelectLobby();
                          return  AddLobby(variables: widget.variables,);
                        },
                        ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff23ff89),
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
         ),

         SizedBox(
          height: height*0.05,
         ),

        
          ],
        )
        
      ),
    
        ],
      ));
   
   }

   void searchQuery(String text){
    setState(() {
      
    });
   }

  Widget lobbyItem(var width, var height, Lobby snapshot){
    return Padding(
      padding: EdgeInsets.only(top: 0, bottom: 0),
      child: GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
         Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          return LobbyDetails(variables: widget.variables, lobby: snapshot);
                        },
                        ));
      },
      child: Container(
        width: width*0.5,
        height: height*0.3,
        child: Column(
          children: [
            SizedBox(
              width: width*0.28,
              height: width*0.28,
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
                child: Text(snapshot.name , style: TextStyle(fontFamily: 'Muli', color: Color(0xffff4399), fontSize: 20, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis,),
              ),
            ),
            SizedBox(
              height: height*0.01,
            ),
            Container(
              width: width*0.45,
              child: Center(
                child: Text(snapshot.uid+ '(' + snapshot.rate.toString() + ' ETB)', style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis,),
              ),
            )
          ],
        ),
      ),
    )
    );
    }

   

}