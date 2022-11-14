import 'dart:math';

import 'package:flutter/material.dart';

import 'arrow_view.dart';
import 'model.dart';

class BoardView extends StatefulWidget {
  final double angle;
  final double current;
  final List<Luck> items;

  const BoardView({Key key, this.angle, this.current, this.items})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BoardViewState();
  }
}

class _BoardViewState extends State<BoardView> {
  Size get size => Size(MediaQuery.of(context).size.width * 0.8,
      MediaQuery.of(context).size.width * 0.8);

  double _rotote(int index) => ((index / widget.items.length) * 2 * pi);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        //shadow
        Container(
          height: size.height*1.2,
          width: size.width*1.2,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
               border: Border.all(color: Colors.white),
              // boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black38)]
              ),
        ),
        Transform.rotate(
          angle: -(widget.current + widget.angle) * 2 * pi,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              for (var luck in widget.items) ...[_buildCard(luck)],
              for (var luck in widget.items) ...[_buildImage(luck)],
            ],
          ),
        ),
        Container(
          height: size.height,
          width: size.width,
          child: ArrowView(),
        ),
      ],
    );
  }

  _buildCard(Luck luck) {
    var _rotate = _rotote(widget.items.indexOf(luck));
    var _angle = 2 * pi / widget.items.length;
    return Transform.rotate(
      angle: _rotate,
      child: ClipPath(
        clipper: _LuckPath(_angle),
        child: Container(
          height: size.height*1.2,
          width: size.width*1.2,
          decoration: BoxDecoration(
             border: Border.all(color: Colors.white),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [luck.color.withOpacity(0.5), luck.color.withOpacity(0)])),
        ),
      ),
    );
  }

  Widget displayName(String name, var width){
    return Container(
      width: width*0.2,
      child: Text(name, style: TextStyle(color: Colors.white, fontFamily: 'Muli', fontSize: 16, fontWeight: FontWeight.w900),)
    );
  }

  _buildImage(Luck luck) {
    var _rotate = _rotote(widget.items.indexOf(luck));
    return Transform.rotate(
      angle: _rotate,
      child: Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
              BoxConstraints.expand(height: size.height / 3, width: size.width*0.7),
          child: Container(
            
            child: Transform(
            transform: Matrix4.rotationZ((-pi/2)),
            alignment: Alignment.topCenter,
            child: Transform.translate(offset: Offset( 0, -size.height*0.03), child: displayName(luck.asset, size.width)),)
          )
          // Image.asset(luck.asset),
        ),
      ),
    );
  }
}

class _LuckPath extends CustomClipper<Path> {
  final double angle;

  _LuckPath(this.angle);

  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    Rect _rect = Rect.fromCircle(center: _center, radius: size.width / 2);
    _path.moveTo(_center.dx, _center.dy);
    _path.arcTo(_rect, -pi / 2 - angle / 2, angle, false);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(_LuckPath oldClipper) {
    return angle != oldClipper.angle;
  }
}