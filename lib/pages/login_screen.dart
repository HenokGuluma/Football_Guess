import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/pages/lobby_menu.dart';
import 'package:instagram_clone/pages/setup_profile.dart';
import 'package:progress_indicators/progress_indicators.dart';

class LoginScreen extends StatefulWidget {

  String nextStage;
  Function finishStage;
  UserVariables variables;

  LoginScreen({this.nextStage, this.finishStage, this.variables});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  bool loggingIn = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: new Color(0xff1a1a1a),
          brightness: Brightness.dark,
          toolbarHeight: 0,
          centerTitle: true,
          elevation: 1.0,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/general_background.png')
            )
          ),
          child: ListView(children: <Widget>[
          SizedBox(
            height: height * 0.1,
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: Container(
                  height: height * 0.25,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/banker-removed.png'))),
                ),
              )),
          SizedBox(
            height: height * 0.05,
          ),
          Padding(
              padding:  EdgeInsets.only(top: 0.0, bottom: 10.0, left: width*0.05, right: width*0.05),
              child: Center(
                  child: Text(
                "Login in order to play with others",
                style: TextStyle(
                    fontFamily: 'Muli', color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w900), textAlign: TextAlign.center,
              ))),
        
           loggingIn
          ?SizedBox(
            height: height*0.05,
          )
          :SizedBox(
            height: height * 0.1,
          ),
          loggingIn
          ?JumpingDotsProgressIndicator(
            fontSize: 50,
            color: Color(0xff00ffff),
            
          )
          :Center(),
          SizedBox(
            height: height * 0.05,
          ),
          Center(
            child: loggingIn
            ?Container(
                width: width * 0.7,
                height: height * 0.08,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text('Logging you in...',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.white,
                              fontSize: 18.0)),
                )
                )
            :GestureDetector(
              child: Container(
                width: width * 0.7,
                height: height * 0.08,
                decoration: BoxDecoration(
                  color: Color(0xff00ffff),
                  border: Border.all(color: Color(0xff00ffff)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/google_icon.jpg'),
                              )),
                          width: height * 0.06,
                          height: height * 0.06,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text('Sign in with Google',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 18.0)),
                    )
                  ],
                ),
              ),
              onTap: () {
                  setState(() {
                  loggingIn = true;
                });
                _firebaseProvider.signIn().then((user) {
                  if (user != null) {
                    authenticateUser(user);
                  } else {
                    print("Error");
                  }
                });
              },
            ),

            
          ),
          SizedBox(
            height: height*0.05,
          ),
          MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffff2378),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: width*0.3,
                  height: 40,
                  child: Center(
                    child: Text('Go Back', style: TextStyle(color: Colors.white, fontSize:18, fontFamily: 'Muli', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
        ]),
        ));
  }

  void authenticateUser(auth.User user) {
    print("Inside Login Screen -> authenticateUser");
    _firebaseProvider.authenticateUser(user).then((value) {
      if (value) {
        print("VALUE : $value");
        print("INSIDE IF");
        print(widget.variables.keys);
        _firebaseProvider.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return SetupProfile(
              userId: user.uid,
              emailAddress: user.email,
              name: user.displayName,
              finishNavigation: widget.finishStage,
              variables: widget.variables,
            );
          }));
        });
      } else {
        print("INSIDE ELSE");
        print(widget.variables.keys);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
              return LobbyMenu(variables: widget.variables,);
        }));
      }
    });
  }
}
