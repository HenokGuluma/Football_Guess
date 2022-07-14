import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/profile_picture_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:progressive_image/progressive_image.dart';

class EditProfileScreen extends StatefulWidget {
  final String photoUrl, email, bio, name, phone;
  UserVariables variables;
  User currentUser;

  EditProfileScreen(
      {this.photoUrl,
      this.currentUser,
      this.email,
      this.bio,
      this.name,
      this.phone,
      this.variables});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var _repository = Repository();
  auth.User currentUser;
  User currentuser;
  TextEditingController _nameController;
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  StorageReference _storageReference;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Name');
    _nameController.text = widget.name;
    _bioController.text = widget.bio;
    _emailController.text = widget.email;
    _phoneController.text = widget.phone;
    currentuser = widget.currentUser;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: new Color(0xff1a1a1a),
        toolbarHeight: 40.0,
        elevation: 1,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'Muli', color: Colors.white),
        ),
        leading: GestureDetector(
          child: Icon(Icons.close, color: Colors.white),
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          _nameController.text.isEmpty ||
                  _bioController.text.isEmpty ||
                  _phoneController.text.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.done, color: Color(0xff444444)))
              : GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.done, color: Color(0xff00ffff)),
                  ),
                  onTap: () {
                    _repository
                        .updateDetails(
                            currentuser.uid,
                            _nameController.text,
                            _bioController.text,
                            _emailController.text,
                            _phoneController.text)
                        .then((v) {
                      print('boom');

                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                      showFloatingFlushbar(context);
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: ((context) => InstaHomeScreen())
                      // ));
                    });
                  },
                )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
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
                            // image: AssetImage('assets/listing_1.jpg'),
                            image: CachedNetworkImageProvider(widget.photoUrl),
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
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => Profile_picture(
                                  currentUser: currentuser,
                                  profileSetup: false,
                                ))));
                  }),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text('Change Photo',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => Profile_picture(
                                profileSetup: false,
                                original: false,
                                currentUser: currentuser,
                              ))));
                },
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.black),
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
                          color: Colors.black,
                          fontSize: 16.0),
                    ),
                    onChanged: updateText),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.black),
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
                            color: Colors.black,
                            fontSize: 16.0)),
                    onChanged: updateText),
              ),
              Divider(
                color: Colors.black,
                thickness: 0.5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'Private Information',
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                  style: TextStyle(fontFamily: 'Muli', color: Colors.black),
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
                          color: Colors.black,
                          fontSize: 16.0)),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: TextFormField(
                    style: TextStyle(fontFamily: 'Muli', color: Colors.black),
                    controller: _phoneController,
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
                            color: Colors.black,
                            fontSize: 16.0)),
                    onChanged: updateText),
              )
            ],
          )
        ],
      ),
    );
  }

  updateText(String text) {
    setState(() {});
  }

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
        style: TextStyle(fontFamily: 'Muli', color: Color(0xff00ffff)),
      )),
    )..show(context);
  }

  Future<String> uploadImagesToStorage(Uint8List imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putData(imageFile);
    /*storageUploadTask.events.listen((event) {
      setState(() {
        _progress= event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });*/
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
