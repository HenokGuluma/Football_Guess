import 'package:flutter/material.dart';
import 'package:flutter_spinning_wheel/src/utils.dart';

class SpinningWheel extends StatefulWidget {
  final Image image;
  final int dividers;
  final Image secondaryImage;
  final double secondaryImageHeight;
  final double secondaryImageWidth;
  final Function onUpdate;

  SpinningWheel(
    {
      this.image,
    this.dividers,
    this.secondaryImage,
    this.secondaryImageHeight,
    this.secondaryImageWidth,
    this.onUpdate,
  });

  @override
  _SpinningWheelState createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  SpinVelocity _spinVelocity;
  NonUniformCircularMotion _motion;

  RenderBox _renderBox;
  double _currentDistance = 0;
  Offset _localPosition;
  bool _isBackwards;
  double _totalDuration = 0;
  double _initialCircularVelocity = 0;
  double _initialSpinAngle = 0;
  double _dividerAngle;
  int _currentDivider;

  @override
  void initState() {
    super.initState();

    
    _motion = NonUniformCircularMotion(resistance: 0.5);
    _dividerAngle = _motion.anglePerDivision(widget.dividers);

    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  double topSecondaryImage (var height) {
    return (height / 2) - (widget.secondaryImageHeight / 2);
  }
      

  double leftSecondaryImage(var width){
    return (width / 2) - (widget.secondaryImageWidth / 2);
  }
      

  double widthSecondaryImage (var width){
    return widget.secondaryImageWidth ?? width;
  } 

  double heightSecondaryImage (var height){
    return widget.secondaryImageHeight ?? height;
  }
      

  @override
  Widget build(BuildContext context) {
     var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    setState(() {
      _spinVelocity = SpinVelocity(width: width, height: height);
    });
    return Column(children: [
      Container(
        height: height,
        width: width,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onPanUpdate: _moveWheel,
              onPanEnd: _startAnimation,
              child: AnimatedBuilder(
                  animation: _animation,
                  child: Container(child: widget.image),
                  builder: (context, child) {
                    _updateAnimationValues();
                    // widget.onUpdate(_currentDivider);
                    return Transform.rotate(
                      angle: _initialSpinAngle + _currentDistance,
                      child: child,
                    );
                  }),
            ),
            widget.secondaryImage != null
                ? Positioned(
                    top: topSecondaryImage(height),
                    left: leftSecondaryImage(width),
                    child: Container(
                      height: heightSecondaryImage(height),
                      width: widthSecondaryImage(width),
                      child: widget.secondaryImage,
                    ))
                : Container(),
          ],
        ),
      ),
    ]);
  }

  void _updateAnimationValues() {
    if (_animationController.isAnimating) {
      var currentTime = _totalDuration * _animation.value;
      _currentDistance =
          _motion.distance(_initialCircularVelocity, currentTime);
      if (_isBackwards) {
        _currentDistance = -_currentDistance;
      }
    }

    var modulo = _motion.modulo(_currentDistance + _initialSpinAngle);
    _currentDivider = widget.dividers - (modulo ~/ _dividerAngle);

    if (!_animationController.isAnimating) {
      _initialSpinAngle = modulo;
      _currentDistance = 0;
    }
  }

  void _moveWheel(DragUpdateDetails details) {
    if (_animationController.isAnimating) return;

    _localPosition = _updateLocalPosition(details.globalPosition);
    var angle = _spinVelocity.offsetToRadians(_localPosition);

    setState(() {
      _initialSpinAngle = angle;
    });
  }

  Offset _updateLocalPosition(Offset position) {
    if (_renderBox == null) {
      _renderBox = context.findRenderObject();
    }
    return _renderBox.globalToLocal(position);
  }

  void _startAnimation(DragEndDetails details) {
    if (_animationController.isAnimating) return;

    var velocity = _spinVelocity.getVelocity(
        _localPosition, details.velocity.pixelsPerSecond);

    _localPosition = null;
    _isBackwards = velocity < 0;
    _initialCircularVelocity = pixelsPerSecondToRadians(velocity.abs());
    _totalDuration = _motion.duration(_initialCircularVelocity);

    _animationController.duration =
        Duration(milliseconds: (_totalDuration * 1000).round());

    _animationController.reset();
    _animationController.forward();
  }
}