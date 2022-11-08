import 'dart:async';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:animated_check/animated_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';
import 'package:flutter_countdown_timer/countdown.dart';

class Footballers extends StatefulWidget {

  String category;
 
  Footballers({
    this.category
  });

  @override
  _FootballersState createState() => _FootballersState();
}

class _FootballersState extends State<Footballers>
    with TickerProviderStateMixin {
  List<List<String>> images = 
  [['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png']
  ];

  List<List<Map<String, dynamic>>> footballers = 
  [
    [
      {'name': 'Alexis Sanchez', 'age': 33, 'image':'assets/Alexis-Sanchez.png', 'height': 1.68, 'jersey': 4, 'goals': 326 },
      {'name': 'Paul Pogba', 'age': 29, 'image':'assets/Paul-Pogba.png', 'height': 1.81, 'jersey': 6, 'goals': 216 },
    ],
    [
      {'name': 'Lionel Messi', 'age': 35, 'image':'assets/Lionel-Messi.png', 'height': 1.7, 'jersey': 30, 'goals': 750 },
       {'name': 'Christiano Ronaldo', 'age': 37, 'image':'assets/Christiano-Ronaldo.png', 'height': 1.82, 'jersey': 7, 'goals': 780},
    ],
    
    [
      {'name': 'Kylian Mbappe', 'age': 23, 'image':'assets/Kylian-Mbappe.png', 'height': 1.79, 'jersey': 7, 'goals': 160 },
      {'name': 'Bukayo-Saka', 'age': 21, 'image':'assets/Bukayo-Saka.png', 'height': 1.78, 'jersey': 10, 'goals': 89 },
    ],
     [
      {'name': 'Karim Benzema', 'age': 34, 'image':'assets/Karim-Benzema.png', 'height': 1.78, 'jersey': 9, 'goals': 280},
      {'name': 'Luka Modric', 'age': 37, 'image':'assets/Luca-Modric.png', 'height': 1.76, 'jersey': 16, 'goals': 72 },
    ],
   
    [
      {'name': 'Sadio Mane', 'age': 31, 'image':'assets/Sadio-Mane.png', 'height': 1.78, 'jersey': 19, 'goals': 276 },
      {'name': 'Mohammed Salah', 'age': 30, 'image':'assets/Mohammed-Salah.png', 'height': 1.77, 'jersey': 10, 'goals': 306 },
    ]
  ];
  AnimationController _animationController;
  AnimationController _slideController;
  PageController _pageController;
  Animation _animation;
  bool animate = false;
  bool correctPicked = false;
  int currentPage = 0;
  bool finished = false;
  int second = 6;
  double timeLeft = 6;
  double resetValue = 6;
  double divider = 6;
  bool defeated = false;
  bool wrongClick = false;
  int gamePlayDuration = 0;
  bool disposed = false;
  
 @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _slideController.dispose();
    setState(() {
      disposed = true;
    });
    super.dispose();
  }


  @override
  void initState() {
    
    
    _pageController = PageController(initialPage: currentPage, viewportFraction: 1);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
     _slideController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(seconds: second),
      // value: timeLeft.toDouble(),
    )..addListener(() {
        setState(() {});
      });
      // _slideController.reset();
    _slideController.repeat(reverse: false);

    super.initState();
    
    _animationController.repeat(reverse: true);
    _animationController.reset();
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });
    
    startCountDown();
    startSecondCountDown();
    // scheduleTimeout(second * 1000);
    
  }

  void startCountDown(){
    Timer.periodic(Duration(milliseconds: 100), (timer) { 
      if (wrongClick){
        
      }
      else if(timeLeft >0){
        setState(() {
          timeLeft = timeLeft-0.1;
          // _slideController.value = (timeLeft-1).toDouble();
        });
      }
      
      else{
        handleTimeout();
      }
    });
  }

  void startSecondCountDown(){
    Timer.periodic(Duration(milliseconds: 1000), (timer) { 
      if(disposed){

      }
      else if (gamePlayDuration >=60){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 1.5;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=50){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 2.0;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=40){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 2.5;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if (gamePlayDuration >=30){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          resetValue = 3;
          gamePlayDuration = gamePlayDuration+1;
        });
      }
      else if(gamePlayDuration >=15){
        // print(gamePlayDuration.toString() + ' is the duration');
        setState(() {
          gamePlayDuration = gamePlayDuration+1;
          resetValue = 4;
          // _slideController.value = (timeLeft-1).toDouble();
        });
      }
      
      else{
        // print(gamePlayDuration.toString() + ' is the duration');
        gamePlayDuration = gamePlayDuration+1;
      }
    });
  }


void handleTimeout() {  // callback function
  setState(() {
          animate = true;
          wrongClick = true;
          _animationController.repeat(reverse: true);
           _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });
        });
        Future.delayed(Duration(seconds: 5)).then((value) {
          setState(() {
            defeated = true;
            
          });
        });
}
   

  @override
  Widget build(BuildContext context) {
     var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
 
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/stadium.png'),
                fit: BoxFit.cover
              )
            ),
          ),
          Container(
        width: width,
        height: height,
        child: defeated || finished
        ?Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height*0.05,),
            Padding(
              padding: EdgeInsets.only(top: height*0.05, left: width*0.05),
              child: Center()
              ),
            SizedBox(height: height*0.15,),
            Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                'Nice Effort', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 45, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            SizedBox(
              height: height*0.1,
            ),
            Text(
                'Your final Score is: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),
              ),
              SizedBox(
              height: height*0.1,
            ),
            MaterialButton(
              onPressed: (){
                setState(() {
                  timeLeft = 5.5;
                  // _slideController.value = 5.5;
                  defeated = false;
                  resetValue = 6;
                  gamePlayDuration=0;
                  divider = 6;
                  finished = false;
                  wrongClick = false;
                  correctPicked = false;
                  animate = false;
                  currentPage = 0;
                  _animationController.reset();
                  _slideController.reset();
                  _slideController.repeat(reverse: false);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
                ),
                width: width*0.45,
                height: width*0.12,
                child: Center(
                  child: Text(
                'Try Again', style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 22, fontWeight: FontWeight.w900),
              ),
                ),
              ),
            ),
            SizedBox(height: height*0.05,),
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
          ],
        )
        ,
            )
          ],
        ):Column(
          children: [
            SizedBox(
              height: height*0.15,
            ),
            Container(
              width: width*0.8,
              height: height*0.08,
             
              child: Center(
              child: Text(
                widget.category == 'age'?'Who is Older?':widget.category == 'height'
                ?'Who is taller?':widget.category == 'jersey'?'Who has higher Jersey Number?':'Who has more goals?',
                 style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
            ),
            ),
            SizedBox(
              height: height*0.08,
            ),
            /* Center(
              child: Text(
                'Timer: '+ (timeLeft==6?'5':timeLeft.toString()), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ), */

           Container(
            width: width*0.9,
            child:  LinearProgressIndicator(
             /*  color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555), */
              minHeight: 5,
              
              backgroundColor: Colors.transparent,
              value: timeLeft == divider?1:(timeLeft/(divider-1)).toDouble(),
              // value: _slideController.value,
              valueColor: AlwaysStoppedAnimation(Color(0xffffffff)),
            ),
           ),
             SizedBox(
              height: height*0.05,
            ),

            Container(
              height: height*0.55,
              width: width,
              child: defeated
              ?Center(
                child: MaterialButton(
                  onPressed: (){

                  },
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('Nice Effort. Your final Score is: '+ (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :finished
              ?Center(
                child: MaterialButton(
                  onPressed: (){},
                  onLongPress: (){
                    setState(() {
                      currentPage = 0;
                      finished = false;
                      correctPicked = false;
                    });
                  },
                  child: Container(
                    height: height*0.5,
                    width: width,
                    child: Center(
                      child: Text('You have finished the list', style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 30, fontWeight: FontWeight.w900),),
              
                    )
                  ),
                )
                )
              :Center(
                child: PageView.builder(
                  allowImplicitScrolling: false,
                  itemCount: (footballers.length)*10,
                itemBuilder: (context, index){
                  var item = footballers[index%5];
                  return Center(
                    child: playerSelect(width, height, index, item),
                  );
                },
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                
                ),
              )
                
            ),
            
            Center(
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),),
             
            )

          ],
        ),
      ),
    
        ],
      ));
   
   }

   bool compare(var first, var second){
    return first>second;
   }


   

   Widget playerSelect(var width, var height, int index, List<Map<String, dynamic>> footballer){
    return  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                playerCard(width, height, compare(footballer[0][widget.category], footballer[1][widget.category]), 0, footballer[0]['image'], footballer[0]['name']),
                SizedBox(width: 20,),
                playerCard(width, height,  compare(footballer[1][widget.category], footballer[0][widget.category]), 1, footballer[1]['image'], footballer[1]['name'])
              ],
            );
   }

   Widget playerCard(var width, var height, bool correct, int index, String image, String name){
    return GestureDetector(
      onTap: (){
        if(wrongClick){
          print('wrong click');
        }
        
        else if(correct){
          setState(() {
            correctPicked = true;
            currentPage = currentPage+1;
            timeLeft = resetValue;
            divider = resetValue;
            _slideController.reset();
            _animation = new Tween<double>(begin: 0, end: 1).animate(
        new CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutCirc));
          });
          
          _animationController.forward().then((value) {
            Future.delayed(Duration(milliseconds: 200)).then((value){
              if(currentPage == (footballers.length)*10){
          setState(() {
            finished = true;
          });
        }
           else{
             setState((){
              correctPicked = false;
             });
             _pageController.animateToPage(currentPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
             _animationController.reset();
            
           }
            }); 
          });
        }
        else{
          setState(() {
          animate = true;
          wrongClick = true;
          _animationController.repeat(reverse: true);
           _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });
        });
        Future.delayed(Duration(seconds: 5)).then((value) {
          setState(() {
            defeated = true;
            
          });
        });
        }
      },
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
        width: width*0.42,
        height: width*0.65,
        decoration: BoxDecoration(
          image: DecorationImage(
            
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [BoxShadow(
            color: animate?correct?Color(0xff63ff89):Color(0xffff3989):Colors.black,
            blurRadius: animate?_animation.value:0,
            spreadRadius: animate?_animation.value:0
          )],
          
          borderRadius: BorderRadius.circular(20)
        ),
        
      ), 
   
              
              correct && correctPicked?Align(
                alignment: Alignment.center,
                child: Container(
                  child: Center(
                    child: AnimatedCheck(
                      
                progress: _animation,
                size: 100,
                color: Color(0xff63ff89),
              ),
                  )),
              )
              :correct && wrongClick
              ?Align(
                alignment: Alignment.center,
                child: Container(
                  child: Center(
                    child: Icon(Icons.done, size: 100, color: Color(0xff63ff89),)
                  )),
              )
              :wrongClick?Align(
                alignment: Alignment.center,
                child: Container(
                  child: Center(
                    child: Icon(Icons.close, size: 100, color: Color(0xffff3989),)
                  )),
              ):Center()
            ],
          ),
          SizedBox(height: 10,),
      Text(
                name, style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 22, fontWeight: FontWeight.w900),
              ),
        ],
      )
    );
   }


}