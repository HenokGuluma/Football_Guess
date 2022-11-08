import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/backend/firebase.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/pages/lobby_menu.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/user.dart';


class SetupProfile extends StatefulWidget {
  final String userId;
  final String emailAddress;
  final String name;
  Function finishNavigation;
  UserVariables variables;

  SetupProfile({this.userId, this.emailAddress, this.name, this.finishNavigation, this.variables});

  @override
  _SetupProfileState createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  FirebaseProvider _firebaseProvider = FirebaseProvider();
  auth.User currentUser;
  User currentuser;
  TextEditingController _nameController;
  final _bioController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  StorageReference _storageReference;
  bool checkingUsername = false;
  bool usernameExists = false;
  bool usernameChecked = false;
  bool usernameTooShort = false;
  bool finishingUp = false;
  bool loadingPhones = true;
  List<String> phoneList = [];
  bool phoneExists = false;
  bool userNameExists = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Name');
    if (widget.emailAddress != null) {
      _emailController.text = widget.emailAddress;
    }
    if (widget.name != null) {
      _nameController.text = widget.name;
    }

  }

  File imageFile;

  Future<File> _pickImage(String action) async {
    File selectedImage;

    action == 'Gallery'
        ? selectedImage =
            await ImagePicker.pickImage(source: ImageSource.gallery)
        : await ImagePicker.pickImage(source: ImageSource.camera);

    return selectedImage;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: new Color(0xff1a1a1a),
        toolbarHeight: 40.0,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Setup Profile',
          style: TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/general_background.png')
          )
        ),
        child: ListView(
        children: [
          Column(
            children: <Widget>[
              GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                        image: DecorationImage(
                          image: imageFile != null
                              ? FileImage(File(imageFile.path))
                              : AssetImage('assets/grey.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 130,
                      height: 130,
                    ),
                  ),
                  onTap: () async {
                    var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);

                    setState(() {
                      imageFile = File(image.path);
                    });
                  }),
              GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text('Choose Photo',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () async {
                    var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);

                    setState(() {
                      imageFile = File(image.path);
                    });
                  })
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white),
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.grey,
                          fontSize: 16.0),
                      labelText: 'Name',
                      labelStyle: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.white,
                          fontSize: 16.0),
                    ),
                    onChanged: changeText),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white),
                    controller: _bioController,
                    maxLines: 3,
                    maxLength: 150,
                    decoration: InputDecoration(
                        hintText: 'Bio',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 16.0),
                        labelText: 'Bio',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 16.0)),
                    onChanged: changeText),
              ),
              Divider(
                color: Colors.white,
                thickness: 0.5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'Private Information',
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white),
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                        hintText: 'Email address',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 16.0),
                        labelText: 'Email address',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 16.0)),
                    onChanged: changeText),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white),
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    autofocus: false,
                    decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.grey,
                            fontSize: 16.0),
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 16.0)),
                    onChanged: changeText),
              ),
              
              phoneList.contains(_phoneController.text)
              ?Center(
                child: Text('The phone number already exists.',
                 style: TextStyle(color: Color(0xffff0066), fontFamily: 'Muli', fontSize: 14, fontWeight: FontWeight.w900),),
              ):
              _phoneController.text.length>10
              ?Center(
                child: Text('Please enter a valid phone number.',
                 style: TextStyle(color: Color(0xffff0066), fontFamily: 'Muli', fontSize: 14, fontWeight: FontWeight.w900),),
              )
              :Center(),
              SizedBox(
                height: size.height * 0.03,
              ),
              finishingUp
                  ? Center(
                      child: Container(
                          width: size.width * 0.4,
                          height: size.height * 0.07,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              'Finishing Up ...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Muli', fontWeight: FontWeight.w900),
                            ),
                          )))
                  : _nameController.text.isEmpty ||
                          _bioController.text.isEmpty ||
                          _phoneController.text.isEmpty ||
                          imageFile == null||phoneList.contains(_phoneController.text)
                          ||_phoneController.text.length!=10
                      ? Center(
                          child: Container(
                          width: 150,
                          constraints:
                              BoxConstraints(maxWidth: size.width * 0.5),
                          height: size.height * 0.07,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text(
                            'Finish',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontFamily:'Muli', fontWeight: FontWeight.w900),
                          )),
                        ))
                      : Center(
                          child: GestureDetector(
                          child: Container(
                            width: size.width * 0.4,
                            height: size.height * 0.07,
                            decoration: BoxDecoration(
                                color: Color(0xff00ffff),
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                                child: Text(
                              'Finish',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18, fontFamily:'Muli', fontWeight: FontWeight.w900 ),
                            )),
                          ),
                          onTap: () {
                            setState(() {
                              finishingUp = true;
                            });
                            compressImage().then((compressedImage) {
                              uploadImagesToStorage(compressedImage)
                                  .then((url) {
                                _firebaseProvider
                                    .updatePhoto(url, widget.userId)
                                    .then((v) {
                                      _firebaseProvider.addPhone(_phoneController.text, widget.userId);
                                  _firebaseProvider
                                      .updateDetails(
                                          widget.userId,
                                          _nameController.text,
                                          _bioController.text,
                                          _emailController.text,
                                          _phoneController.text)
                                      .then((value) {
                                 
                                   Navigator.pop(context);
                                   User _user = User();
                                   
                                   _user = User(
                                      recentActivity: DateTime.utc(2020).millisecondsSinceEpoch,
                                      uid: widget.userId,
                                      email: _emailController.text,
                                      userName: '',
                                      hasLobby: false,
                                      photoUrl: url,
                                      followers: '0',
                                      following: '0',
                                      bio: '',
                                      posts: 0,
                                      phone: '',
                                      trending: 100,
                                      keys: 0,
                                      dailyTimer: DateTime.now().millisecondsSinceEpoch);
                                   widget.variables.setCurrentUser(_user);
                                   widget.finishNavigation();
                                  });
                                });
                              });
                            });
                          },
                        )),
              SizedBox(
                height: size.height * 0.08,
              )
            ],
          ),
        ],
      ),
      )
    );
  }

  changeText(String text) {
    setState(() {});
  }

  changeUserName(String text) {
    if (text.length < 6 && text.length > 0) {
      setState(() {
        usernameTooShort = true;
      });
    } else if (text.length == 0) {
      setState(() {
        checkingUsername = false;
        usernameExists = false;
        usernameChecked = false;
        usernameTooShort = false;
      });
    } else {}
  }

  checkUserName(String text) async {}

  void showFloatingFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 0,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Colors.black, Colors.black],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: Text(
        'You have successfully updated your profile.',
        style: TextStyle(fontFamily: 'Muli', color: Color(0xfff2029e)),
      )),
    )..show(context);
  }

 Future<String> uploadImagesToStorage(Uint8List imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
     StorageUploadTask storageUploadTask = _storageReference.putData(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  /*void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.copyResizeCropSquare(image, 500);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = newim2;
    });
    print('done');
  }*/
  Future<Uint8List> compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    //Im.copyResizeCropSquare(image, 500);
    var result = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 25,
    );
    print('done');
    return result;
  }
}
