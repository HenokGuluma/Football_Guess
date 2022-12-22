import 'dart:io' as IO;
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/lobby.dart';
import 'package:instagram_clone/models/user.dart';


class FirebaseProvider {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  StorageReference _storageReference;

  Future<void> addDataToDb(auth.User currentUser) async {
    user = User(
        recentActivity: DateTime.utc(2020).millisecondsSinceEpoch,
        uid: currentUser.uid,
        email: currentUser.email,
        userName: '',
        hasLobby: false,
        photoUrl: currentUser.photoURL,
        followers: '0',
        following: '0',
        admin: false,
        bio: '',
        posts: 0,
        phone: '',
        trending: 100,
        coins: 0,
        tokens: 5,
        dailyTimer: DateTime.now().millisecondsSinceEpoch);

    //  Map<String, String> mapdata = Map<String, dynamic>();

    //  mapdata = user.toMap(user);
    String userExists = await fetchUidBySearchedEmail(currentUser.email);
    if (userExists != null) {
      DocumentSnapshot users =
          await _firestore.collection("users").doc(userExists).get();
      if (users['email'] == user.email) {
        return;
      }
    }
   
    _firestore
        .collection("users")
        .doc(currentUser.uid)
        .set({'displayName': currentUser.displayName});

    _firestore
        .collection("email")
        .doc(currentUser.email)
        .set({'email': currentUser.email, 'userId': currentUser.uid});

    _firestore
        .collection("users")
        .doc(currentUser.uid)
        .set(user.toMap(user));

    return _firestore
        .collection("users")
        .doc(currentUser.uid)
        .collection("notifications").doc().set({
          'from': 'Homes',
          'message': 'Welcome to Homes. Browse around to find listings you want to rent.',
          'userId': user.uid,
          'time': DateTime.now().millisecondsSinceEpoch

        });
  }

   Future<User> retrieveUserDetails(auth.User user) async {
    DocumentSnapshot _documentSnapshot =
        await _firestore.collection("users").doc(user.uid).get();
    return User.fromMap(_documentSnapshot.data());
  }

    Future<bool> authenticateUser(auth.User user) async {
    final QuerySnapshot result = await _firestore
        .collection("users")
        .where("email", isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    if (docs.length == 0) {
      return true;
    } else {
      return false;
    }
  }

    Future<String> fetchUidbyEmail(String email) async {
    final QuerySnapshot result = await _firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
    DocumentSnapshot doc = result.docs[0];
    return doc['uid'];
  }

   Future<String> fetchUidBySearchedEmail(String email) async {
    DocumentSnapshot snapshot =
        await _firestore.collection("emails").doc(email).get();
    if (snapshot.data() != null) {
      return snapshot['uid'];
    }
    return null;
  }

  Future<String> fetchUidBySearchedPhone(String email) async {
    DocumentSnapshot snapshot =
        await _firestore.collection("phones").doc(email).get();
    if (snapshot.data() != null) {
      return snapshot['uid'];
    }
    return null;
  }
  Future<String> fetchUidBySearchedUserName(String email) async {
    DocumentSnapshot snapshot =
        await _firestore.collection("userNames").doc(email).get();
    if (snapshot.data() != null) {
      return snapshot['uid'];
    }
    return null;
  }
  
  Future<DocumentSnapshot> fetchLobbyById(String id) async{
    DocumentSnapshot snapshot = await _firestore.collection("lobbies").doc(id).get();
     if (snapshot.data() != null) {
      return snapshot;
    }
    return null;
  }

Future<User> fetchUserDetailsById(String uid) async {
  if(uid!=null){
     DocumentSnapshot documentSnapshot =
        await _firestore.collection("users").doc(uid).get();
        if(documentSnapshot.data().isNotEmpty){
          return User.fromMap(documentSnapshot.data());
        }
  }
   return User();
    
  }

  Future<void> resetTokens (String userId) async{
    int timer = DateTime.now().millisecondsSinceEpoch + 86400000 ;
    return _firestore.collection("users").doc(userId).update({'tokens': 5, 'dailyTimer': timer});
  }

  Future<Lobby> getLobbyById(String lobbyId) async{
    print(lobbyId); print(' is the lobby id');
    DocumentSnapshot snapshot = await _firestore.collection('lobbies').doc(lobbyId).get();
    if(snapshot.data()==null){
      return Lobby();
    }
    return Lobby.fromMap(snapshot.data());
  }
   Future<Lobby> getPublicLobbyById(String lobbyId) async{
    print(lobbyId); print(' is the lobby id');
    DocumentSnapshot snapshot = await _firestore.collection('publicLobbies').doc(lobbyId).get();
    if(snapshot.data()==null){
      return Lobby();
    }
    return Lobby.fromMap(snapshot.data());
  }

  Future<void> sendCoins(String senderId, String receiverId, int coins) async{
     DocumentSnapshot documentSnapshot =
        await _firestore.collection("users").doc(senderId).get();
       int previousCoins = documentSnapshot.data()['coins'];
       int currentCoins = previousCoins - coins;

    DocumentSnapshot newDocumentSnapshot =
        await _firestore.collection("users").doc(receiverId).get();
       int prevCoins = newDocumentSnapshot.data()['coins'];
       int curCoins = prevCoins + coins;

     await _firestore.collection('users').doc(senderId).update({'coins': currentCoins});
    return _firestore.collection('users').doc(receiverId).update({'coins': curCoins});
  }

 Future<User> getUserById(String userId) async{
    QuerySnapshot snapshot = await _firestore.collection('users').where('userName', isEqualTo: userId).get();
    if(snapshot.docs.isNotEmpty){
       if(snapshot.docs[0].data()==null || snapshot.docs.length ==0){
      return User();
    }
    else{
        return User.fromMap(snapshot.docs[0].data());
    }
    }
    return User();
  }



  Future<DocumentSnapshot> fetchUserNameById(String id) async{
    DocumentSnapshot snapshot = await _firestore.collection("userNames").doc(id).get();
     if (snapshot.data() != null) {
      return snapshot;
    }
    return null;
  }
  

  Future<void> addLobbyById(String id, Lobby lobby, User creatorId) async{
    print(creatorId); print('stage1');
    Map<String, dynamic> setMap = lobby.toMap(lobby);
    Map<String, dynamic> info = {creatorId.uid: creatorId.toMap(creatorId)};
    setMap['playerInfo'] = info;
    setMap['active'] = false;
    setMap['winnings'] = 0;
    setMap['betLeft'] = 0;
    setMap['betsPlaced'] = {};
    setMap['vault'] = 0;
    print(setMap);
    await _firestore.collection('users').doc(creatorId.uid).collection('lobby').doc(id).set(setMap);
    print(creatorId); print('stage2');
    await _firestore.collection('users').doc(creatorId.uid).update({'hasLobby': true, 'lobbyId': lobby.uid});
    print(creatorId); print('stage3');
    setMap['creator'] = creatorId.toMap(creatorId);
    return _firestore.collection("lobbies").doc(id).set(setMap);
  }

   Future<void> addBankeruLobbyById(String id, Lobby lobby, User creatorId) async{
    print(creatorId); print('stage1');
    Map<String, dynamic> setMap = lobby.toMap(lobby);
    Map<String, dynamic> info = {creatorId.uid: creatorId.toMap(creatorId)};
    setMap['playerInfo'] = info;
    setMap['active'] = false;
    setMap['betsPlaced'] = {};
    setMap['roundCompleted'] = false;
    setMap['betLeft'] = 0;
    setMap['vault'] = 0;
    print(setMap);
    await _firestore.collection('users').doc(creatorId.uid).collection('lobby').doc(id).set(setMap);
    print(creatorId); print('stage2');
    await _firestore.collection('users').doc(creatorId.uid).update({'hasLobby': true, 'lobbyId': lobby.uid});
    print(creatorId); print('stage3');
    setMap['creator'] = creatorId.toMap(creatorId);
    return _firestore.collection("lobbies").doc(id).set(setMap);
  }

  Future<void> editLobbyById(String id, Lobby lobby, User creatorId) async{
    print(creatorId); print('stage1');
    Map<String, dynamic> setMap = lobby.toMap(lobby);
    Map<String, dynamic> info = {creatorId.uid: creatorId.toMap(creatorId)};
    setMap['playerInfo'] = info;
    setMap['active'] = false;
    setMap['betLeft'] = 0;
    setMap['betsPlaced'] = {};
    setMap['vault'] = 0;
    print(setMap);
    await _firestore.collection('users').doc(creatorId.uid).collection('lobby').doc(id).update(setMap);
    print(creatorId); print('stage2');
    setMap['creator'] = creatorId.toMap(creatorId);
    return _firestore.collection("lobbies").doc(id).update(setMap);
  }

  Future<void> addPublicLobby(Lobby lobby, int priority) async{
    Map<String, dynamic> setMap = lobby.toMap(lobby);
    setMap['active'] = false;
    setMap['playerInfo'] = {};
    setMap['winnings'] = 0;
    setMap['countDown'] = DateTime.now().millisecondsSinceEpoch;
    setMap['startedCountdown'] = false;
    setMap['priority'] = priority;
    print(setMap);
    return _firestore.collection("publicLobbies").add(setMap).then((value) {
      _firestore.collection("publicLobbies").doc(value.id).update({'uid': value.id});
    });
  }

  Future<void> depositWinning(String userId, int amount) async{
    var increment = FieldValue.increment(amount);
    await _firestore.collection('users').doc(userId).update({'coins': increment});
  }

   Future<void> addBankeruPublicLobby(Lobby lobby) async{
    Map<String, dynamic> setMap = lobby.toMap(lobby);
    setMap['active'] = false;
    setMap['playerInfo'] = {};
    setMap['countDown'] = DateTime.now().millisecondsSinceEpoch;
    setMap['startedCountdown'] = false;
    setMap['betsPlaced'] = {};
    setMap['roundCompleted'] = false;
    setMap['betLeft'] = 0;
    setMap['vault'] = 0;
    print(setMap);
    return _firestore.collection("publicLobbies").add(setMap).then((value) {
      _firestore.collection("publicLobbies").doc(value.id).update({'uid': value.id});
    });
  }


  Future<void> editPublicLobby(Lobby lobby) async{
    Map<String, dynamic> setMap = lobby.toMap(lobby);
    setMap['active'] = false;
    setMap['playerInfo'] = {};
    setMap['countDown'] = DateTime.now().millisecondsSinceEpoch;
    setMap['startedCountdown'] = false;
    print(setMap);
    return _firestore.collection("publicLobbies").doc(lobby.uid).update(setMap);
  }

  Future<List<Lobby>> getPublicLobbies() async {
    QuerySnapshot snap = await _firestore.collection('publicLobbies').get();
    List<Lobby> returnedList = [];
    for (int i =0; i<snap.docs.length; i++){
      Lobby newLobby = Lobby.fromDoc(snap.docs[i]);
      newLobby.uid = snap.docs[i].id;
      returnedList.add(newLobby);
    }
    return returnedList;
  }

  Future<List<Lobby>> getPublicLobbiesCategory(int type, int category) async {
    QuerySnapshot snap = await _firestore.collection('publicLobbies').where("gameType", isEqualTo: type).where("gameCategory", isEqualTo: category).get();
    List<Lobby> returnedList = [];
    for (int i =0; i<snap.docs.length; i++){
      Lobby newLobby = Lobby.fromDoc(snap.docs[i]);
      newLobby.uid = snap.docs[i].id;
      returnedList.add(newLobby);
    }
    return returnedList;
  }

  Future<void> addUserToLobby (User user, String lobbyId, int rate) async{
    print(rate); print(' is the rate');
    DocumentSnapshot snap = await _firestore.collection('lobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
    Map<String, dynamic> playerInfo = snap.data()['playerInfo'];
     var increment = FieldValue.increment(rate);
    if(!playerList.contains(user.uid)){
      playerList.add(user.uid);
      Map<String, dynamic> userMap = user.toMap(user);
      userMap['active'] = true;
      userMap['idle'] = true;
      playerInfo[user.uid] = userMap;
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo, 'winnings': increment};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
    await _firestore.collection('users').doc(user.uid).update({'coins': user.coins - rate});
    return;
  }

 

   Future<void> addUserToPublicLobby (User user, String lobbyId, int rate) async{
    DocumentSnapshot snap = await _firestore.collection('publicLobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
    Map<String, dynamic> playerInfo = {};
    if(snap.data()['playerInfo']!=null){
      playerInfo = snap.data()['playerInfo'];
    }
    if(!playerList.contains(user.uid)){
      playerList.add(user.uid);
      Map<String, dynamic> userMap = user.toMap(user);
      userMap['active'] = true;
      userMap['idle'] = true;
      playerInfo[user.uid] = userMap;
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
    await _firestore.collection('users').doc(user.uid).update({'coins': user.coins - rate});
    return;
  }
  Future<void> addUserToClosestLobby (User user, String lobbyId, int rate) async{
    print(rate); print(' is the rate');
    DocumentSnapshot snap = await _firestore.collection('lobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
    Map<String, dynamic> playerInfo = snap.data()['playerInfo'];
    if(!playerList.contains(user.uid)){
      playerList.add(user.uid);
      Map<String, dynamic> userMap = user.toMap(user);
      userMap['active'] = true;
      userMap['idle'] = true;
      playerInfo[user.uid] = userMap;
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
    // await _firestore.collection('users').doc(user.uid).update({'coins': user.coins - rate});
    return;
  }

 

   Future<void> addUserToClosestPublicLobby (User user, String lobbyId, int rate) async{
    DocumentSnapshot snap = await _firestore.collection('publicLobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
    Map<String, dynamic> playerInfo = {};
    if(snap.data()['playerInfo']!=null){
      playerInfo = snap.data()['playerInfo'];
    }
    if(!playerList.contains(user.uid)){
      playerList.add(user.uid);
      Map<String, dynamic> userMap = user.toMap(user);
      userMap['active'] = true;
      userMap['idle'] = true;
      playerInfo[user.uid] = userMap;
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
    // await _firestore.collection('users').doc(user.uid).update({'coins': user.coins - rate});
    return;
  }

   Future<void> addUserToBankeruLobby (User user, String lobbyId, int rate) async{
    DocumentSnapshot snap = await _firestore.collection('lobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
    Map<String, dynamic> playerInfo = snap.data()['playerInfo'];
    if(!playerList.contains(user.uid)){
      playerList.add(user.uid);
      Map<String, dynamic> userMap = user.toMap(user);
      userMap['active'] = true;
      userMap['idle'] = true;
      playerInfo[user.uid] = userMap;
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
    await _firestore.collection('users').doc(user.uid).update({'coins': user.coins - rate});
    return;
  }

   Future<void> addUserToBankerPublicLobby (User user, String lobbyId, int rate) async{
    DocumentSnapshot snap = await _firestore.collection('publicLobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
    Map<String, dynamic> playerInfo = {};
    if(snap.data()['playerInfo']!=null){
      playerInfo = snap.data()['playerInfo'];
    }
    if(!playerList.contains(user.uid)){
      playerList.add(user.uid);
      Map<String, dynamic> userMap = user.toMap(user);
      userMap['active'] = true;
      userMap['idle'] = true;
      playerInfo[user.uid] = userMap;
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
    await _firestore.collection('users').doc(user.uid).update({'coins': user.coins - rate});
    return;
  }

   Future<void> setAutomaticTime(String lobbyId) async{
    var now = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('publicLobbies').doc(lobbyId).update({'countDown': now+30000, 'startedCountdown': true});
    return;
  }
    Future<void> setTimerFalse(String lobbyId) async{
    var now = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('publicLobbies').doc(lobbyId).update({'startedCountdown': false});
    return;
  }

  Future<void> submitUserScore(User user, String lobbyId, int score) async{
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('lobbies').doc(lobbyId).collection('playerScores').doc(user.uid).set({'userId': user.uid, 'score': score, 'userName': user.userName, 'time': currentTime });
  }

  Future<void> submitPublicUserScore(User user, String lobbyId, int score) async{
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('publicLobbies').doc(lobbyId).collection('playerScores').doc(user.uid).set({'userId': user.uid, 'score': score, 'userName': user.userName, 'time': currentTime });
  }

  Future<void> submitBlackUserScore(User user, String lobbyId, int score, bool exploded) async{
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('lobbies').doc(lobbyId).collection('playerScores').doc(user.uid).set({'userId': user.uid, 'score': score, 'exploded': exploded, 'userName': user.userName, 'time': currentTime });
  }

  Future<void> submitBlackPublicUserScore(User user, String lobbyId, int score, bool exploded) async{
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    await _firestore.collection('publicLobbies').doc(lobbyId).collection('playerScores').doc(user.uid).set({'userId': user.uid, 'score': score, 'exploded': exploded, 'userName': user.userName, 'time': currentTime });
  }

  Future<DocumentSnapshot> getLobbyWinner(String lobbyId) async{
    QuerySnapshot snapshot = await _firestore.collection('lobbies').doc(lobbyId).collection('playerScores').orderBy('score', descending: true).limit(1).get();
    return snapshot.docs[0];
  }

    Future<DocumentSnapshot> getClosestLobbyWinner(String lobbyId) async{
    QuerySnapshot snapshot = await _firestore.collection('lobbies').doc(lobbyId).collection('playerScores').orderBy('score', descending: true).limit(1).get();
    return snapshot.docs[0];
  }
  Future<DocumentSnapshot> getPublicLobbyWinner(String lobbyId) async{
    QuerySnapshot snapshot = await _firestore.collection('publicLobbies').doc(lobbyId).collection('playerScores').orderBy('score', descending: false).limit(1).get();
    return snapshot.docs[0];
  }
   Future<DocumentSnapshot> getPublicClosestLobbyWinner(String lobbyId) async{
    QuerySnapshot snapshot = await _firestore.collection('publicLobbies').doc(lobbyId).collection('playerScores').orderBy('score', descending: false).limit(1).get();
    return snapshot.docs[0];
  }

  Future<DocumentSnapshot> getBlackLobbyWinner(String lobbyId) async{
    QuerySnapshot snapshot = await _firestore.collection('lobbies').doc(lobbyId).collection('playerScores').orderBy('score', descending: true).orderBy('time', descending: false).limit(1).get();
    QuerySnapshot snapshot2 = await _firestore.collection('lobbies').doc(lobbyId).collection('playerScores').orderBy('time', descending: false).where('exploded', isEqualTo: false).limit(1).get();
    DocumentSnapshot documentSnapshot;
    if(snapshot2.docs.length<1){
      documentSnapshot = snapshot.docs[0];
    }
    else{
      documentSnapshot = snapshot2.docs[0];
    }
    return documentSnapshot;
  }
  Future<DocumentSnapshot> getBlackPublicLobbyWinner(String lobbyId) async{
    QuerySnapshot snapshot = await _firestore.collection('publicLobbies').doc(lobbyId).collection('playerScores').orderBy('score', descending: true).orderBy('time', descending: false).limit(1).get();
    QuerySnapshot snapshot2 = await _firestore.collection('publicLobbies').doc(lobbyId).collection('playerScores').orderBy('time', descending: false).where('exploded', isEqualTo: false).limit(1).get();
    DocumentSnapshot documentSnapshot;
    if(snapshot2.docs.length<1){
      documentSnapshot = snapshot.docs[0];
    }
    else{
      documentSnapshot = snapshot2.docs[0];
    }
    return documentSnapshot;
  }


   Future<void> removeUserFromLobby (User user, String lobbyId) async{
    DocumentSnapshot snap = await _firestore.collection('lobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
     Map<String, dynamic> playerInfo = snap.data()['playerInfo'];
    if(playerList.contains(user.uid)){
      playerList.remove(user.uid);
    }
    if(playerInfo.containsKey(user.uid)){
       playerInfo.remove(user.uid);
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }

  Future<void> removeUserFromBankeruLobby (User user, String lobbyId) async{
    DocumentSnapshot snap = await _firestore.collection('lobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
     Map<String, dynamic> playerInfo = snap.data()['playerInfo'];
     Map<String, dynamic> betsPlaced = snap.data()['betsPlaced'];
    if(playerList.contains(user.uid)){
      playerList.remove(user.uid);
    }
    if(playerInfo.containsKey(user.uid)){
       playerInfo.remove(user.uid);
    }
    if(betsPlaced.containsKey(user.uid)){
       betsPlaced.remove(user.uid);
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo, 'betsPlaced': betsPlaced};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }

     Future<void> removeUserFromPublicLobby (User user, String lobbyId) async{
    DocumentSnapshot snap = await _firestore.collection('publicLobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
     Map<String, dynamic> playerInfo = snap.data()['playerInfo'];
    if(playerList.contains(user.uid)){
      playerList.remove(user.uid);
    }
    if(playerInfo.containsKey(user.uid)){
       playerInfo.remove(user.uid);
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
  }

    Future<void> removeUserFromPublicBankeruLobby (User user, String lobbyId) async{
    DocumentSnapshot snap = await _firestore.collection('publicLobbies').doc(lobbyId).get();
    List<dynamic> playerList = snap.data()['players'];
     Map<String, dynamic> playerInfo = snap.data()['playerInfo'];
     Map<String, dynamic> betsPlaced = snap.data()['betsPlaced'];
    if(playerList.contains(user.uid)){
      playerList.remove(user.uid);
    }
    if(playerInfo.containsKey(user.uid)){
       playerInfo.remove(user.uid);
    }
    Map<String, dynamic> updateMap = {'players': playerList, 'playerInfo': playerInfo, 'betsPlaced': betsPlaced};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
  }

  Future<void> startLobbyGame (String userId, String lobbyId) async{
    await _firestore.collection('lobbies').doc(lobbyId).collection('playerScores').get().then((documentList) {
      for (DocumentSnapshot ds in documentList.docs){
        ds.reference.delete();
      }
    });
    Map<String, dynamic> updateMap = {'active': true};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }

  Future<void> startBankeruLobbyGame (String userId, String lobbyId) async{
   
    Map<String, dynamic> updateMap = {'active': true, 'activeUser': userId, 'roundCompleted': false};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }

  Future<void> startPublicBankeruLobbyGame (String userId, String lobbyId) async{
   
    Map<String, dynamic> updateMap = {'active': true, 'activeUser': userId, 'roundCompleted': false};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
  }

  Future<void> addMoneyToVault (int amount, String lobbyId) async{
    Map<String, dynamic> updateMap = {'vault': amount, 'betLeft': amount};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }

   Future<void> startPublicLobbyGame (String userId, String lobbyId) async{
    await _firestore.collection('publicLobbies').doc(lobbyId).collection('playerScores').get().then((documentList) {
      for (DocumentSnapshot ds in documentList.docs){
        ds.reference.delete();
      }
    });
    Map<String, dynamic> updateMap = {'active': true};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
  }

  Future<void> stopLobbyGame (String userId, String lobbyId) async{
    Map<String, dynamic> updateMap = {'active': false};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }

   Future<void> stopBankeruLobbyGame (String userId, String lobbyId) async{
    Map<String, dynamic> updateMap = {'active': false, 'betsPlaced': {}};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }

  Future<void> sendSpinList(List<String> players, String lobbyId) async{
    Map<String, dynamic> updateMap = {'active': true, 'spinList': players};
    await _firestore.collection('lobbies').doc(lobbyId).update(updateMap);
  }
   Future<void> sendPublicSpinList(List<String> players, String lobbyId) async{
    Map<String, dynamic> updateMap = {'active': true, 'spinList': players};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
  }

   Future<void> stopPublicLobbyGame (String userId, String lobbyId) async{
    Map<String, dynamic> updateMap = {'active': false, 'startedCountdown': false};
    await _firestore.collection('publicLobbies').doc(lobbyId).update(updateMap);
  }

    void addPhone(String phone, String userId) async{
    await _firestore.collection('phones').doc(phone).set({'phone': phone, 'userId': userId});
  }

   Future<List<DocumentSnapshot>> getAllPhones() async {
       var phones = await _firestore
        .collection('phones')
        .get();
    return phones.docs;
  }
   Future<void> editPhone(String phone, String previousPhone, String userId) async{
    await _firestore.collection('phones').doc(previousPhone).delete();
    await _firestore.collection('phones').doc(phone).set({'phone': phone, 'userId': userId});
  }

  Future<void> editUserName(String userName, String previousUserName, String userId) async{
    await _firestore.collection('userNames').doc(previousUserName).delete();
    await _firestore.collection('userNames').doc(userName).set({'userName': userName, 'userId': userId});
  }

  Future<void> editLobbyName(String userName, String previousUserName) async{
    await _firestore.collection('lobbies').doc(previousUserName).delete();
    await _firestore.collection('lobbies').doc(userName).set({'lobbyId': userName});
  }

  void addUserName(String userName, String userId) async{
    print('adding userName');
    await _firestore.collection('userNames').doc(userName).set({'userName': userName, 'userId': userId});
  }

  Future<void> updatePhoto(String photoUrl, String uid) async {
    print('updating photo');
    Map<String, dynamic> map = Map();
    map['photoUrl'] = photoUrl;
    return _firestore.collection("users").doc(uid).update(map);
  }

  Future<void> updateDetails(
      String uid, String name, String bio, String email, String phone) async {
    Map<String, dynamic> map = Map();
    map['userName'] = name;
    map['bio'] = bio;
    // map['email'] = email;
    map['phone'] = phone;
    _firestore.collection('phones').doc(phone).set({'phone': phone, 'userId': uid});
    return _firestore.collection("users").doc(uid).update(map);
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<auth.User> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      accessToken: _signInAuthentication.accessToken,
      idToken: _signInAuthentication.idToken,
    );

    final auth.User user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  Future<String> uploadImageToStorage(IO.File imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<String> uploadImagesToStorage(Uint8List imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
     StorageUploadTask storageUploadTask = _storageReference.putData(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

    Future<auth.User> getCurrentUser() async {
    auth.User currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

}