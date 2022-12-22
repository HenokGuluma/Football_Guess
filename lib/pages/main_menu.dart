import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/pages/bankeru.dart';
import 'package:instagram_clone/pages/black_jack.dart';
import 'package:instagram_clone/pages/buy_coins.dart';
import 'package:instagram_clone/pages/closest_number.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/pay_for_coins.dart';
import 'package:instagram_clone/pages/select_lobby.dart';
import 'package:instagram_clone/pages/send_coins.dart';
import 'package:instagram_clone/pages/spinning_wheel.dart';
import 'package:just_audio/just_audio.dart';


class GameMenu extends StatefulWidget {
  bool creating;
  bool editing;
  bool public;
  String uid;
  String name;
  String rate;
  int priority;
  User thisUser;
  UserVariables variables;
  Function pauseBackground;
  Function startBackground;
  


  GameMenu({this.creating, this.editing, this.priority, this.public, this.uid, this.name, this.rate, this.thisUser, this.variables, this.pauseBackground, this.startBackground});

  @override
  GameMenuState createState() => GameMenuState();
}

class GameMenuState extends State<GameMenu> {
  File _image;
  File imageFile;
  bool creating = false;
  final picker = ImagePicker();
  var selectPlayer = AudioPlayer();
  var cancel = AudioPlayer();
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  bool like;
  int counter = 0;
  List<String> modes = ['assets/rapidBall.png', 'assets/blackjack-option.png', 'assets/bank_vault.png', 'assets/roulette.png', 'assets/jackpot.png' ];
  List<String> modesSolo = ['assets/rapidBall.png', 'assets/blackjack-option.png', 'assets/bank_vault.png', 'assets/jackpot.png'];
  List<String> options = ['RapidBall', 'Black Jack', 'Bankeru', 'Spinner', 'Jackpot'];
   List<String> optionsSolo = ['RapidBall', 'Black Jack', 'Bankeru', 'Jackpot'];
  Map<int, double> optionsMap = {1: 25, 3: 50, 5: 75, 10: 100};

  List<bool> balls = [true, true, true, true, true];
  List<DocumentSnapshot> keyOrderList = [];
  List<DocumentSnapshot> pendingOrderList = [];
  int selectedIndex;

  @override
  void initState() {
    super.initState();
    setupSound();
  }

  @override
  void dispose() {
    super.dispose();
    
  }

  Future<void> setupSound() async{
    await selectPlayer.setAsset('assets/sound-effects/option-click-confirm.wav');
    selectPlayer.setVolume(0.1);
    selectPlayer.play();
    selectPlayer.stop();
     await cancel.setAsset('assets/sound-effects/option-click.wav');
    cancel.setVolume(0.1);
    cancel.play();
    cancel.stop();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      
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
                'Pick a Game Category', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
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
   menuOption(width, height, 0, modes, widget.variables),
   SizedBox(height: height*0.08,),
   menuOption(width, height, 1, modes, widget.variables),
   SizedBox(height: height*0.08,),
   menuOption(width, height, 2, modes, widget.variables),
    widget.creating?SizedBox(height: height*0.08,):Center(),
    widget.creating?menuOption(width, height, 3, modes, widget.variables):Center(),
    widget.creating?SizedBox(height: height*0.08,):Center(),
   widget.creating?menuOption(width, height, 4, modes, widget.variables):Center()
   ],
),
          ),
          SizedBox(height: height*0.03,),
Center(
    child: /* GestureDetector(
            onTap: (){
              Navigator.pop(context);
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
            ), */
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
                gameType: selectedIndex,
                gameCategory: 0,
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
   )
  
          ],
        )
        
      ),
    
        ],
      ),);
  }

     Widget menuOption(var width, var height, int index, List<String> images, UserVariables variables){
    return GestureDetector(
      onTap: (){
        selectPlayer.play();
        if (index == 1){
            if(widget.creating){
              setState(() {
                selectedIndex = 1;
              });
            }
            else{
               Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return BlackJack(solo: true,);
                        },
                        ));
            }
           
        }
        else if (index == 2){
           if(widget.creating){
            setState(() {
              selectedIndex = 2;
            });
           }
           else{
             Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return Bankeru(solo: true,);
                        },
                        ));
           }
        }
        else if (index == 3){
           if(widget.creating){
            setState(() {
              selectedIndex = 3;
            });
           }
           else{
             Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return ClosestNumber(variables: widget.variables);
                        },
                        ));
           }
        }
        else if (index == 4){
           
            setState(() {
              selectedIndex = 4;
            });
          
        }
        else{
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return FootBallMenu(
                            public: widget.public,
                            priority: widget.priority,
                            creating: widget.creating,
                            editing: widget.editing,
                            uid: widget.uid,
                            name: widget.name,
                            rate: widget.rate,
                            thisUser: widget.variables.currentUser,
                            variables: widget.variables,
                            pauseBackground: widget.pauseBackground,
                            startBackground: widget.startBackground,
                          );
                        },
                        ));
        }
        Future.delayed(Duration(seconds: 1)).then((value){
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
            image: AssetImage(widget.creating?images[index]:modesSolo[index]),
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
          child: Text(widget.creating?options[index]:optionsSolo[index], style: TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Muli', fontWeight: FontWeight.w900),)
        ),
      ),
      index==selectedIndex
      ?Container(
        width: width*0.7,
        height: width*0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
         
        ),
        child: Center(
          child: Icon(Icons.check, size: 40, color: Color(0xff23ff89),)
          ),
      ):Center()
        ],
      )
    );
   }


   


  Widget UnlockOptions(int amount, int price, var width) {
    return GestureDetector(
        onTap: () {
          print('The option that you chose is ' + price.toString());
           Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => PayForCoins(variables: widget.variables, SubTotal: price.toDouble(), coins: amount,))));
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: width * 0.2,
            height: width * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SvgPicture.asset("assets/key.svg",
                      width: 20, height: 20, color: Colors.yellow),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    amount != 1
                        ? amount.toString() + ' coins'
                        : amount.toString() + ' coin',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff00ffff),
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
                  ),
                ]),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'for ' + price.toString() + ' ETB',
                  style: TextStyle(
                      fontFamily: 'Muli', color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ));
  }
}
