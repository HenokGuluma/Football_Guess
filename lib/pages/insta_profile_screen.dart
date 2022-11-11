import 'dart:async';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/backend/firebase.dart';

import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/pages/buy_keys.dart';
import 'package:instagram_clone/pages/edit_profile_screen.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class InstaProfileScreen extends StatefulWidget {
  // InstaProfileScreen();
  UserVariables variables;
  InstaProfileScreen({this.variables});

  @override
  _InstaProfileScreenState createState() => _InstaProfileScreenState();
}

class _InstaProfileScreenState extends State<InstaProfileScreen>
    with AutomaticKeepAliveClientMixin {
  var _firebaseProvider = FirebaseProvider();
  bool _isLiked = false;
  List<DocumentSnapshot> list;
  bool loading = true;
  bool logging_out = false;
  NavigatorState _navigator;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
     _navigator = Navigator.of(context);
    /*  retrieveUserDetails().then((value) {
      setState(() {
        loading = false;
      });
    }); */
  }

  String adjustNumbers(int num) {
    if (num >= 1000000) {
      String num2 = (num / 1000000).toStringAsFixed(2) + ' M';
      return num2;
    }
    if (num >= 10000) {
      String num2 = (num / 1000).toStringAsFixed(1) + ' K';
      return num2;
    } else {
      String num2 = num.toString();
      return num2;
    }
  }

  Future<void> retrieveUserDetails(UserVariables variables) async {
    auth.User currentUser = await _firebaseProvider.getCurrentUser();
    User user = await _firebaseProvider.retrieveUserDetails(currentUser);
    setState(() {
      widget.variables.currentUser = user;
      variables.currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
   
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        toolbarHeight: 50,
        // elevation: 1,
        centerTitle: true,
        title: Text(widget.variables.currentUser.userName!=null?widget.variables.currentUser.userName.isEmpty?'Profile':'@'+widget.variables.currentUser.userName:'Profile',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic
                )),
      ),
      body: RefreshIndicator(
          onRefresh: () {
            retrieveUserDetails(widget.variables);
            return Future.delayed(Duration(seconds: 2));
          },
          backgroundColor: Colors.black,
          color: Color(0xff00ffff),
          child: Container(
             decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/profile_background.png')
          )
        ),
            child: ListView(
            cacheExtent: 500000000,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: height * 0.05, bottom: 10.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                        image: DecorationImage(
                          image: ProgressiveImage(
                            placeholder: AssetImage('assets/no_image.png'),
                            // size: 1.87KB
                            //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                            thumbnail: AssetImage('assets/grey.png'),
                            // size: 1.29MB
                            image: widget.variables.currentUser!=null
                            ?CachedNetworkImageProvider(widget.variables.currentUser.photoUrl!=null?widget.variables.currentUser.photoUrl:'')
                                : AssetImage('assets/grey.png'),
                            //image: NetworkImage(widget.variables.currentUser.photoUrl),
                            fit: BoxFit.cover,
                            width: 130,
                            height: 130,
                          ).image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 130,
                      height: 130,
                    ),
                  )),
              Center(
                child: Text(
                    widget.variables.currentUser.userName != null ? widget.variables.currentUser.userName : 'Your Name',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 25.0)),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: height * 0.06,
                    left: width * 0.03,
                    right: width * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Bio: ',
                      style: TextStyle(
                        fontFamily: 'Muli',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    widget.variables.currentUser == null
                        ? Container(
                            width: width * 0.8,
                            child: Text(
                                'Your bio will be displayed here.',
                                style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.start))
                        : Container(
                            width: width * 0.8,
                            child: Text(
                                widget.variables.currentUser.bio.isNotEmpty
                                    ? widget.variables.currentUser.bio
                                    : 'Add your bio by clicking on Edit Profile.',
                                style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: widget.variables.currentUser.bio.isNotEmpty
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.start))
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              GestureDetector(
                child: ProfileButtons('Edit Profile', width, height),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => EditProfileScreen(
                            updateState: (){
                              setState(() {});
                            },
                              variables: widget.variables,
                              currentUser: widget.variables.currentUser,
                              photoUrl: widget.variables.currentUser.photoUrl,
                              email: widget.variables.currentUser.email,
                              bio: widget.variables.currentUser.bio,
                              name: widget.variables.currentUser.userName,
                              phone: widget.variables.currentUser.phone))));
                },
              ),
             GestureDetector(
            child: ProfileButtons('Buy Coins', width, height),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => BuyKeys(variables: widget.variables))));
            },
          ),

          /*  GestureDetector(
            child: ProfileButtons('Terms Of Service', width, height),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => TermsOfService())));
            },
          ), */
              GestureDetector(
                  child: ProfileButtons('Log Out', width, height),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            backgroundColor: Color(0xff240044),
                            title: new Text(
                              'Logging out',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            content: new Text(
                              'Are you sure you want to log out?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Color(0xffff2389),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                //  loggingOutDialog();
                                setState(() {
                                  logging_out = true;
                                });
                                  _firebaseProvider.signOut().then((v) {
                                    widget.variables.reset();
                                    _navigator.pushReplacement(
                                        MaterialPageRoute(builder: (context) {
                                      return MyApp();
                                    }));
                                  });
                                  return print('pressedOK');
                                  // Closes the dialog
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Color(0xff23ff89),
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));

                    }),
              Divider(
                color: Color(0xff00ffff),
                thickness: 0.5,
              ), 

              logging_out
              ?Center()
              :SizedBox(height: 30,),
              logging_out?
              Center(
                child: Column(
                                children: [
                                   JumpingDotsProgressIndicator(color: Color(0xff00ffff), fontSize: 30,),
                                  
                                  SizedBox(height: 10,),
                                  Text(
                              'Logging you out...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 20,)
                                ],
                              ),
              )
              :Center(),

              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                    'Contact us',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 22,
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w900, 
                        decoration: TextDecoration.underline
                        ),
                  ),
                ),
                  SizedBox(height: 20,),
              Row(
                children: [
                  Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Icon(
                Icons.phone,
                size: 20,
                color: Colors.grey,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
               '0923577987',
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),

          SizedBox(width: 15,),
          Row(
            children: [
              Icon(
                Icons.email,
                size: 20,
                color: Colors.grey,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'henimagne@gmail.com',
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),

                ],
              ),
              SizedBox(height: 30,)
            ],
          )),
    
          ));
  }

  Widget ProfileButtons(String text, var width, var height) {
    return Container(
        width: width,
        height: height * 0.08,
        decoration: BoxDecoration(
          color: Colors.black,
          // borderRadius: BorderRadius.circular(15.0),
          // border: Border.all(color: Colors.black)
        ),
        child: Column(
          children: [
            Divider(
              color: Color(0xff00ffff),
              thickness: 0.5,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(text,
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(
                        Icons.arrow_right_outlined,
                        color: Color(0xff00ffff),
                        size: 30,
                      ))
                ]),
          ],
        ));
  }
}
