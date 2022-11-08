
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {

   String uid;
   String email;
   String photoUrl;
   String userName;
   String followers;
   String following;
   int posts;
   int trending;
   String bio;
   String phone;
   bool hasLobby;
   int keys;
   int dailyTimer;
   int recentActivity;

   User({this.uid, this.email, this.photoUrl, this.userName, this.hasLobby, this.followers, this.following, this.bio, this.posts, this.phone, this.trending, this.keys, this.dailyTimer, this.recentActivity});

    Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['email'] = user.email;
    data['photoUrl'] = user.photoUrl;
    data['userName'] = user.userName;
    data['followers'] = user.followers;
    data['following'] = user.following;
    data['hasLobby'] = user.hasLobby;
    data['trending'] = user.trending;
    data['bio'] = user.bio;
    data['posts'] = user.posts;
    data['phone'] = user.phone;
    data['dailyTimer'] = user.dailyTimer;
    data['recentActivity'] = user.recentActivity;
    data['keys'] = user.keys;
    return data;
  }

  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.email = mapData['email'];
    this.photoUrl = mapData['photoUrl'];
    this.userName = mapData['userName'];
    this.followers = mapData['followers'];
    this.following = mapData['following'];
    this.trending = mapData['trending'];
    this.bio = mapData['bio'];
    this.posts = mapData['posts'];
    this.phone = mapData['phone'];
    this.dailyTimer = mapData['dailyTimer'];
    this.recentActivity = mapData['recentActivity'];
    this.keys = mapData['keys'];
    this.hasLobby = mapData['hasLobby'];
  }

  User.fromDoc(DocumentSnapshot doc){
      this.uid = doc['uid'];
      this.userName=  doc['userName'];
      this.photoUrl = doc['photoUrl'];
      this.email = doc['email'];
      this.bio = doc['bio'] ?? '';
      this.posts = doc['posts'];
      this.followers = doc['followers'];
      this.following = doc['following'];
      this.trending = doc['trending'];
      this.phone = doc['phone'];
      this.dailyTimer = doc['dailyTimer'];
      this.recentActivity = doc['recentActivity'];
      this.keys = doc['keys'];
      this.hasLobby = doc['hasLobby'];
  }
}

