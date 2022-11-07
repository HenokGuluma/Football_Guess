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
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

class Shaker extends StatefulWidget {

  @override
  _ShakerState createState() => _ShakerState();
}

class _ShakerState extends State<Shaker>
    with TickerProviderStateMixin {
  List<List<String>> images = 
  [['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png'],
    ['assets/Alexis-Sanchez.png', 'assets/Paul-Pogba.png']
  ];

  List<List<Map<String, dynamic>>> Shaker = 
  [
    [
      {'name': 'Alexis Sanchez', 'age': 33, 'image':'assets/Alexis-Sanchez.png' },
      {'name': 'Paul Pogba', 'age': 29, 'image':'assets/Paul-Pogba.png' },
    ],
    [
      {'name': 'Lionel Messi', 'age': 35, 'image':'assets/Lionel-Messi.png' },
       {'name': 'Christiano Ronaldo', 'age': 37, 'image':'assets/Christiano-Ronaldo.png'},
    ],
    
    [
      {'name': 'Kylian Mbappe', 'age': 23, 'image':'assets/Kylian-Mbappe.png' },
      {'name': 'Bukayo-Saka', 'age': 21, 'image':'assets/Bukayo-Saka.png' },
    ],
     [
      {'name': 'Karim Benzema', 'age': 34, 'image':'assets/Karim-Benzema.png'},
      {'name': 'Luka Modric', 'age': 37, 'image':'assets/Luca-Modric.png' },
    ],
   
    [
      {'name': 'Sadio Mane', 'age': 31, 'image':'assets/Sadio-Mane.png' },
      {'name': 'Mohammed Salah', 'age': 30, 'image':'assets/Mohammed-Salah.png' },
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
  int second = 5;
  int timeLeft = 5;
  bool defeated = false;
  bool wrongClick = false;
  


  @override
  void initState() {
    
    
    _pageController = PageController(initialPage: currentPage, viewportFraction: 1);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
     _slideController = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(seconds: second),
    )..addListener(() {
        setState(() {});
      });
    _slideController.repeat(reverse: false);

    super.initState();
    
    _animationController.repeat(reverse: true);
    _animationController.reset();
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
      setState(() {
        
      });
    });
    
    startCountDown();
    // scheduleTimeout(second * 1000);
    
  }

  void startCountDown(){
    Timer.periodic(Duration(seconds: 1), (timer) { 
      if (wrongClick){
        
      }
      else if(timeLeft >0){
        setState(() {
          timeLeft--;
        });
      }
      
      else{
        handleTimeout();
      }
    });
  }

  Timer scheduleTimeout(milliseconds) =>
    Timer(Duration(milliseconds: milliseconds), handleTimeout);

void handleTimeout() {  // callback function
  setState(() {
    defeated = true;
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
                  timeLeft = 5;
                  defeated = false;
                  finished = false;
                  wrongClick = false;
                  correctPicked = false;
                  animate = false;
                  currentPage = 0;
                  _animationController.reset();
                  _slideController.reset();
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
            )
          ],
        )
        :Column(
          children: [
            SizedBox(
              height: height*0.15,
            ),
            Center(
              child: Text(
                'Pick the older one.', style: TextStyle(color: Color(0xff00ffff), fontFamily: 'Muli', fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(
              height: height*0.1,
            ),
            Center(
              child: Text(
                'Timer: '+ (timeLeft==6?'5':timeLeft.toString()), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),

           /*  LinearProgressIndicator(
              color: Color(0xff00ffff),
              backgroundColor: Color(0xff005555),

              value: _slideController.value,
            ), */

            Container(
              height: height*0.5,
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
                itemBuilder: (context, index){
                  var item = Shaker[index];
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
              child: Text('Score: ' + (currentPage*10).toString(), style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 20, fontWeight: FontWeight.w900),),
             
            )

          ],
        ),
      ),
    
        ],
      ));
   
   }

   bool compare(int first, int second){
    return first>second;
   }


   

   Widget playerSelect(var width, var height, int index, List<Map<String, dynamic>> footballer){
    return  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                playerCard(width, height, compare(footballer[0]['age'], footballer[1]['age']), 0, footballer[0]['image'], footballer[0]['name']),
                SizedBox(width: 20,),
                playerCard(width, height,  compare(footballer[1]['age'], footballer[0]['age']), 1, footballer[1]['image'], footballer[1]['name'])
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
            timeLeft = 6;
            _animation = new Tween<double>(begin: 0, end: 1).animate(
        new CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutCirc));
          });
          
          _animationController.forward().then((value) {
            Future.delayed(Duration(milliseconds: 200)).then((value){
              if(currentPage == Shaker.length){
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
      onDoubleTap: (){
        _animationController.reset();
        setState(() {
          animate = false;
          correctPicked = false;
          
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)..addListener(() {
    });
        });
        
         
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