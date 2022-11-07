import 'package:flutter/material.dart';
import 'package:instagram_clone/models/uno_card.dart';
import 'package:instagram_clone/models/uno_game.dart';
import 'dart:math' as math;

class UnoGameWidget extends StatefulWidget {
  UnoGameWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UnoGameWidgetState createState() => _UnoGameWidgetState();
}

class _UnoGameWidgetState extends State<UnoGameWidget> {
  UnoGame game;

  @override
  initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    this.setState(() {
      game = null;
      game = UnoGame();
      game.prepareGame();
      game.playTurn(this);
    });
  }

  @override
  Widget build(BuildContext context) {
    game.calculateScores();
    // Size screen = MediaQuery.of(context).size;
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
      color: Colors.white,
                height: size.height,
                width: size.width,
                child: Stack(
                 
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child:  Container(
                      width: size.width*0.3,
                      
                      // color: Colors.brown,
                      child: game.players[1].hand.toWidget(),
                    ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        child:  game.players[2].hand.toWidget(),
                        width: size.width*0.5,
                      ),
                    ),
                   
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        child: game.players[0].hand.toWidget(),
                        width: size.width*0.5,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        child: game.players[3].hand.toWidget(),
                        width: size.width*.5,
                      ),
                    ),

                     Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: playTable(context),
                        width: size.width*0.5,
                      ),
                    ),
                    
                  ],
                ),
              )
           ,
    ) ;
  }

  Widget playTable(context) {
    // Size screen = MediaQuery.of(context).size;
    return DragTarget<UnoCard>(
      onWillAccept: (UnoCard card) {
        return game.canPlayCard(card);
      },
      onAccept: (UnoCard card) {
        if (game.playCard(card)) {
          game.playTurn(this);
        }
        this.setState(() {});
      },
      builder: (context, list1, list2) {
        return Container(
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
          //   color: game.getPlayingColor(),
          // ),
          height: 120,
          width: 250,
          child: playArea(),
        );
      },
    );
  }

  Widget playArea() {
    if (game.isGameOver()) {
      return gameOverWidget();
    } else {
      return cardsAndDeck();
    }
  }

  Widget colorChoice(String title, Color color, CardColor cardColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0, top: 2.0),
      child: SizedBox(
        height: 25,
        child: FloatingActionButton(
          backgroundColor: color,
          child: Text(title),
          onPressed: () {
            print("Human chose: $cardColor");
            game.setColor(cardColor);
            game.playTurn(this);
            this.setState(() {});
          },
        ),
      ),
    );
  }

  Widget gameOverWidget() {
    return Container(
      color: Colors.lightBlue[900],
      child: Center(
        child: Column(
          children: [
            Text(
              "Game Over!",
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            FloatingActionButton(
              child: Text(
                "Play again",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                this.setState(() {
                  this.game.playNextRound();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget cardsAndDeck() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(10.0),
              //   bottomLeft: Radius.circular(10.0),
              // ),
              color: Colors.transparent,
            ),
            child: Center(
              child: game.currentCard().toWidget(),
            ),
          ),
        ),
        Container(
          height: 30,
          width: 30,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                width: 30,
                height: 30,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi *
                      (game.turnDirection == TurnDirection.clockwise ? 2 : 1)),
                  child: Image.asset(
                    "lib/static/images/rotation.png",
                    color: game.getPlayingColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: game.needsColorDecision()
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        colorChoice("", Colors.red, CardColor.red),
                        colorChoice("", Colors.blue, CardColor.blue),
                        colorChoice("", Colors.yellow, CardColor.yellow),
                        colorChoice("", Colors.green, CardColor.green),
                      ],
                    ),
                  )
                : GestureDetector(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 350),
                      child: game.deck.toWidget(),
                    ),
                    onTap: () {
                      if (game.isHumanTurn()) {
                        this.setState(() {
                          game.drawCardFromDeck();
                          game.playTurn(this);
                        });
                      } else {
                        print("Not your turn!");
                      }
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
