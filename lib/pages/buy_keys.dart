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
import 'package:instagram_clone/pages/pay_for_keys.dart';


class BuyKeys extends StatefulWidget {
  final UserVariables variables;

  BuyKeys({this.variables});

  @override
  BuyKeysState createState() => BuyKeysState();
}

class BuyKeysState extends State<BuyKeys> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  bool like;
  int counter = 0;
  List<Map<String, int>> options = [
    {'amount': 1, 'price': 40},
    {'amount': 3, 'price': 90},
    {'amount': 5, 'price': 120},
    {'amount': 10, 'price': 200}
  ];
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
          toolbarHeight: 50,
          backgroundColor: Colors.black,
          title: Text(
            'Buy Coins',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
          actions: [
            Row(
              children: [
                 SvgPicture.asset('assets/key.svg', color: Colors.yellow, height: 15, width: 15,),
                Text(
            ' Wallet: ',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
           Text(
            widget.variables.currentUser.keys.toString(),
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(width: 15,)
           
              ],
            )
          ],
        ),
        
        backgroundColor: Color(0xffe1e1e1),
        body:  Center(
            child: Container(
          width: width*0.8,
          child: ListView(
              
              children: [
          SizedBox(height: height * 0.05),
         /*  Center(
              child: Text(
            'Number of keys in your wallet: ' +
                widget.variables.currentUser.keys.toString(),
            style: TextStyle(
                fontFamily: 'Muli',
                color: Color(0xff444444),
                fontSize: 20,
                fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          )),
          SizedBox(height: height * 0.05), */
          Container(
              width: width * 0.6,
              height: width*0.75,
              child: Center(
                child: GridView.builder(
                    itemCount: options.length,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2),
                    cacheExtent: 5000000,

                    // ignore: missing_return
                    itemBuilder: ((context, index) {
                      return UnlockOptions(options[index]['amount'],
                          options[index]['price'], width);
                    })),
              )),
          SizedBox(height: height * 0.01),
          Center(
              child: Text(
            'Select the option you want.',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 18),
          )), 
          Column(
            children: [
              SizedBox(height: 60,),
              Text(
            pendingOrderList.length>0
          ?'Pending Key Orders':'No pending key orders',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 18),
          ),
              SizedBox(height: 5,),
            
          ]),
          SizedBox(height: 30,),
          Column(
            children: [
              Text(
            keyOrderList.length>0
          ?'All Key Orders':'No key Orders yet.',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 18),
          ),
              SizedBox(height: 5,),
            
            ],
          )
        ]),
        
          )));
  }


  Widget UnlockOptions(int amount, int price, var width) {
    return GestureDetector(
        onTap: () {
          print('The option that you chose is ' + price.toString());
           Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => PayForKeys(variables: widget.variables, SubTotal: price.toDouble(), keys: amount,))));
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
