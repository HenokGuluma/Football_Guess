import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/new_spinner.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/main_page.dart';
import 'package:instagram_clone/pages/play_mode.dart';
import 'package:instagram_clone/spinner-wheel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

    FirebaseProvider _firebaseProvider = FirebaseProvider();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bankeru",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: FutureBuilder(
          future: _firebaseProvider.getCurrentUser(),
          builder: (context, AsyncSnapshot<auth.User> snapshot) {
            if (snapshot.hasData) {
             return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserVariables>(
            create: (context) => UserVariables())
      ],
      child: PlayMode(loggedIn: true, email: snapshot.data.email, uid: snapshot.data.uid,),
    );
            } else {
              return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserVariables>(
            create: (context) => UserVariables())
      ],
      child: PlayMode(loggedIn: false, email: null,),
    );
            }
          },
        )
      
      // MainPage(),
    );
  }
}

class UserVariables extends ChangeNotifier {
  int keys = 0;
  User currentUser = User();
  List<String> unlockedListings = [];
  Map<String, Image> cachedImages = {};
  List<String> phoneList = [];
  Lobby lobby;
  bool trial = false;

  void addkeys(int amount) {
    keys += amount;
  }

  void removekeys(int amount) {
    keys -= amount;
  }

   void updatePhones (List<String> phones){
    phoneList = phones;
  }

  void setLobby (Lobby newLobby){
    lobby = newLobby;
  }

  void setCurrentUser(User _user) {
    currentUser = _user;
  }

  void setTrial(bool trialPeriod){
    trial = trialPeriod;
  }

  void unlockListing(String listing) {
    unlockedListings.add(listing);
  }

  void setImages(Map<String, Image> images) {
    cachedImages = images;
  }


  void reset() {
    keys = 0;
    User currentUser = User();
    List<String> unlockedListings = [];
  }
}
