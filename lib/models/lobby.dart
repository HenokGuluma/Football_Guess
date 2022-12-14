import 'package:cloud_firestore/cloud_firestore.dart';

class Lobby {

  String uid;
  String name;
  double rate;
  String activeUser;
  List<dynamic> players;
  int creationDate;
  String creatorName;
  String creatorId;
  int winnings;
  Map<String, dynamic> creator;
  int gameType;
  int gameCategory;

   Lobby({this.uid, this.activeUser, this.winnings, this.name, this.rate, this.creationDate, this.players, this.gameCategory, this.creator, this.gameType, this.creatorId, this.creatorName});

    Map toMap(Lobby lobby) {
    var data = Map<String, dynamic>();
    data['uid'] = lobby.uid;
    data['name'] = lobby.name;
    data['activeUser'] = lobby.activeUser;
    data['rate'] = lobby.rate;
    data['winnings'] = lobby.winnings;
    data['players'] = lobby.players;
    data['creationDate'] = lobby.creationDate;
    data['creatorName'] = lobby.creatorName;
    data['creatorId'] = lobby.creatorId;
    data['gameType'] = lobby.gameType;
    data['creator'] = lobby.creator;
    data['gameCategory'] = lobby.gameCategory;
    return data;
  }

  Lobby.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.activeUser = mapData['activeUser'];
    this.rate = mapData['rate'];
    this.players = mapData['players'];
    this.winnings = mapData['winnings'];
    this.creationDate = mapData['creationDate'];
    this.creatorId = mapData['creatorId'];
    this.creatorName = mapData['creatorName'];
    this.gameCategory = mapData['gameCategory'];
    this.gameType = mapData['gameType'];
    this.creator = mapData['creator'];
  }

  Lobby.fromDoc(DocumentSnapshot doc){
      this.uid = doc['uid'];
      this.name = doc['name'];
      this.rate = doc['rate'];
      this.winnings = doc['winnings'];
      this.activeUser = doc['activeUser'];
      this.players = doc['players'];
      this.creationDate = doc['creationDate'];
      this.creatorId = doc['creatorId'];
      this.creatorName = doc['creatorName'];
      this.gameCategory = doc['gameCategory'];
      this.gameType = doc['gameType'];
      this.creator = doc['creator'];
  }
}

