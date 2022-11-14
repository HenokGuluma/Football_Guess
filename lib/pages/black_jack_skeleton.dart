import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/pages/buy_coins.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/pay_for_coins.dart';
import 'package:instagram_clone/pages/select_lobby.dart';
import 'package:instagram_clone/pages/send_coins.dart';


class BlackJack extends StatefulWidget {
  final UserVariables variables;

  BlackJack({this.variables});

  @override
  BlackJackState createState() => BlackJackState();
}

class BlackJackState extends State<BlackJack> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  bool like;
  int counter = 0;
  List<String> modes = ['assets/buy-coins.png', 'assets/send-coins.png'];
  List<String> options = ['Buy Coins', 'Send coins'];
  Map<int, double> optionsMap = {1: 25, 3: 50, 5: 75, 10: 100};
  List<Widget> cardWidget = [];
  List<int> cards = [];
  double size = 1;

  List<bool> balls = [true, true, true, true, true];
  List<DocumentSnapshot> keyOrderList = [];
  List<DocumentSnapshot> pendingOrderList = [];
  Timer _timer;
  int timeLeft = 300;
  int value;
  Random rng = Random();
  bool randomizing = false;
  bool showRandomizing = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    
  }

  void startTimer(var width, var height){
    _timer = Timer.periodic(
      Duration(milliseconds: 10), (timer) {
        if(timeLeft==0){
          _timer.cancel();
          // cardWidget.add(card(width, height, value));
          cards.add(value);
          setState(() {
            showRandomizing = false;
          });
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
            randomizing = false;
            showRandomizing = true;
          });
          });
        }
        else{
          setState(() {
            timeLeft-=1;
            value = rng.nextInt(10);
          });
        }
       });
  }

  void randomize(var width, var height){
    print('daaum');
    setState(() {
      timeLeft = 300;
      randomizing = true;
      showRandomizing = true;
      
    });
    startTimer(width, height);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      
        appBar: AppBar(
          brightness: Brightness.dark,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
          toolbarHeight: 70,
          backgroundColor: Colors.black,
          title: Text(
            'Black Jack',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900),
          ),
         
        ),
        
        backgroundColor: Color(0xffe1e1e1),
        body:  Center(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/coin-background.png'),
                  fit: BoxFit.cover
                )
              ),
          width: width,
          child: Center(
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 SizedBox(
                  height: height*0.02,
                ),
                Center(
                  child: Container(
                    height: height*0.3,
                    child: (showRandomizing?randomizing?card(width, height, value, 0):cardBack(width, height, value):Center()),
                  )
                ),
                SizedBox(
                  height: height*0.05,
                ),
                Container(
              width: width,
              height: height*0.3,
              child: Stack(
            alignment: Alignment.center,
              // scrollDirection: Axis.horizontal,
              children: 
                cards.map((item) {
                                      return card(width, height, item, cards.indexOf(item));
                                    }).toList()
              
        
          ),
            ), 
            
            ])
          ))));
  }

  Widget card(var width, var height, int value, int index){
    return Padding(
      padding: EdgeInsets.only(left: index*width*0.12),
      child: GestureDetector(
      onTap: (){

      },
      child: Container(
      width: width*0.4*size,
      height: height*0.3*size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
        color: Colors.white,
         boxShadow: [BoxShadow(
            color: Color(0xffffffff),
            blurRadius: width*0.01,
            spreadRadius: width*0.01
          )],
      ),
      child: Center(
        child: Text(value.toString(), style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 45, fontWeight: FontWeight.w900)),
      ),
    ),
    )
  ,
    );}

   Widget cardBack(var width, var height, int value){
    return MaterialButton(
      onPressed: (){
        if(cardWidget.length >1){
         
        }
        randomize(width, height);
      },
      child: Container(
      width: width*0.4*size,
      height: height*0.3*size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.brown,
        
      ),
      child: Center(
        child: Text('Randomize', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    ),
      );
  }

     Widget menuOption(var width, var height, int index, List<String> images, UserVariables variables){
    return GestureDetector(
      onTap: (){
        if (index == 1){
            Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return SendCoins(variables: variables,);
                        },
                        ));
        }
        else{
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return BuyCoins(variables: variables,);
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