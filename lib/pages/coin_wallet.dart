import 'dart:async';
import 'dart:io';
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


class CoinWallet extends StatefulWidget {
  final UserVariables variables;

  CoinWallet({this.variables});

  @override
  CoinWalletState createState() => CoinWalletState();
}

class CoinWalletState extends State<CoinWallet> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  bool like;
  int counter = 0;
  List<String> modes = ['assets/buy-coins.png', 'assets/withdraw.png', 'assets/send-coins.png'];
  List<String> options = ['Deposit', 'Widthdraw','Send cash'];
  Map<int, double> optionsMap = {1: 25, 3: 50, 5: 75, 10: 100};

  List<bool> balls = [true, true, true, true, true];
  List<DocumentSnapshot> keyOrderList = [];
  List<DocumentSnapshot> pendingOrderList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    
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
            'Wallet',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900),
          ),
          actions: [
            Row(
              children: [
                //  SvgPicture.asset('assets/coin.svg', color: Color(0xff00ffff), height: 20, width: 20,),
                Text(
            ' Wallet: ',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900),
          ),
           Text(
            widget.variables.currentUser.coins.toString() + ' ETB',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900),
          ),
          SizedBox(width: 15,)
           
              ],
            )
          ],
        ),
        
        backgroundColor: Color(0xffe1e1e1),
        body:  Center(
            child: Container(
              
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/coin-background.png'),
                  fit: BoxFit.cover
                )
              ),
          width: width,
          child: ListView(
              
              children: [
          SizedBox(height: height * 0.05),
            menuOption(width, height, 0, modes, widget.variables),
   SizedBox(height: height*0.08,),
   menuOption(width, height, 1, modes, widget.variables),
   SizedBox(height: height*0.08,),
   menuOption(width, height, 2, modes, widget.variables),
   SizedBox(height: height*0.08,),

        ]),
        
          )));
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
