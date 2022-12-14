import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/pay_for_coins.dart';
import 'package:instagram_clone/pages/select_lobby.dart';


class BuyCoins extends StatefulWidget {
  final UserVariables variables;

  BuyCoins({this.variables});

  @override
  BuycoinsState createState() => BuycoinsState();
}

class BuycoinsState extends State<BuyCoins> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  bool like;
  int counter = 0;
  List<String> modes = ['assets/buy-coins.png', 'assets/send-coins.png'];
  List<String> options = ['Buy Coins', 'Send coins'];
  Map<int, double> optionsMap = {1: 25, 3: 50, 5: 75, 10: 100};

  List<bool> balls = [true, true, true, true, true];
  List<DocumentSnapshot> keyOrderList = [];
  List<DocumentSnapshot> pendingOrderList = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    
  }

   void searchQuery(String text){
    setState(() {
      
    });
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
            'Desposit cash',
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
          SizedBox(height: height * 0.2),
          Container(
              width: width*0.5,
              height: height*0.05,
              child: Center(
                child: Text('Enter amount to Deposit', style: TextStyle(color: Color(0xff00ffff), fontSize: 25, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            SizedBox(height: height * 0.04),
          Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20)
                                ),
                            width: width * 0.5,
                            height: 40,
                            padding: EdgeInsets.only(left: 5, top: 0),
                            child: Center(
                              child: TextField(
                                 inputFormatters: <TextInputFormatter>[
   // for below version 2 use this
 FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), 
// for version 2 and greater youcan also use this
 FilteringTextInputFormatter.digitsOnly

  ],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                              controller: controller,
                              cursorColor: Colors.white,
                              autofocus: false,
                              focusNode: FocusNode(),
                              cursorHeight: 20,
                              maxLength: 20,
                              cursorWidth: 0.5,
                              onChanged: searchQuery,
                              
                              decoration: InputDecoration(
                                
                                  hintText: 'Amount to Deposit',
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                            ),
                          
                            ))),
                          SizedBox(
                            height: height*0.1,
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: width*0.5),
                            child: MaterialButton(
            onPressed: (){
             
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff00ffff),
                borderRadius: BorderRadius.circular(20)
              ),
              width: width*0.5,
              height: height*0.07,
              child: Center(
                child: Text('Proceed to Payment', style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
              ),
            ),
            ),
                          )

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
                          return FootBallMenu(creating: false,);
                        },
                        ));
        }
        else{
          Navigator.push(context, MaterialPageRoute( 
          builder: (BuildContext context) {
                          // return LobbyMenu();
                          return SelectLobby(variables: variables,);
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
