import 'dart:io' as IO;
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
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
        photoUrl: currentUser.photoURL,
        followers: '0',
        following: '0',
        bio: '',
        posts: 0,
        phone: '',
        trending: 100,
        keys: 0,
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

    void addPhone(String phone, String userId) async{
    await _firestore.collection('phones').doc(phone).set({'phone': phone, 'userId': userId});
  }

  Future<void> updatePhoto(String photoUrl, String uid) async {
    Map<String, dynamic> map = Map();
    map['photoUrl'] = photoUrl;
    return _firestore.collection("users").doc(uid).update(map);
  }

  Future<void> updateDetails(
      String uid, String name, String bio, String email, String phone) async {
    Map<String, dynamic> map = Map();
    map['displayName'] = name;
    map['bio'] = bio;
    map['email'] = email;
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