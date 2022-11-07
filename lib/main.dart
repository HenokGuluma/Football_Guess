import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/new_spinner.dart';
import 'package:instagram_clone/pages/football_menu.dart';
import 'package:instagram_clone/pages/footballers.dart';
import 'package:instagram_clone/pages/main_page.dart';
import 'package:instagram_clone/pages/play_mode.dart';
import 'package:instagram_clone/spinner-wheel.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BetMania",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: 
      PlayMode()
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
