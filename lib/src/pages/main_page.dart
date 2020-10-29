import 'package:flutter/material.dart';

class MainBounceTabbar extends StatefulWidget {
  @override
  _MainBounceTabbarState createState() => _MainBounceTabbarState();
}

class _MainBounceTabbarState extends State<MainBounceTabbar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [],
      ),
      bottomNavigationBar: BounceTabbar(
        items: [
          Icon(
            Icons.person_add_alt_1_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.ac_unit,
            color: Colors.white,
          ),
          Icon(
            Icons.agriculture,
            color: Colors.white,
          ),
          Icon(
            Icons.bubble_chart,
            color: Colors.white,
          ),
        ],
        onTabbarChanged: (int value) {
          print(value);
        },
      ),
    );
  }
}

class BounceTabbar extends StatefulWidget {
  const BounceTabbar(
      {Key key,
      this.backgroundColor = Colors.deepPurple,
      @required this.items,
      @required this.onTabbarChanged,
      this.initialIndex = 0,
      this.movement = 100})
      : super(key: key);

  final Color backgroundColor;
  final List<Widget> items;
  final ValueChanged<int> onTabbarChanged;
  final int initialIndex;
  final double movement;

  @override
  _BounceTabbarState createState() => _BounceTabbarState();
}

class _BounceTabbarState extends State<BounceTabbar>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animTabbarIn;
  Animation _animTabbarOut;
  Animation _animCircle;
  Animation _animElevationIn;
  Animation _animElevationOut;

  int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 1200,
        ));

    _animTabbarIn =
        CurveTween(curve: Interval(.1, .6, curve: Curves.decelerate))
            .animate(_controller);

    _animTabbarOut =
        CurveTween(curve: Interval(.6, 1.0, curve: Curves.bounceOut))
            .animate(_controller);

    _animCircle = CurveTween(curve: Interval(.0, .5)).animate(_controller);

    _animElevationIn =
        CurveTween(curve: Interval(.3, .5, curve: Curves.decelerate))
            .animate(_controller);

    _animElevationOut =
        CurveTween(curve: Interval(.55, 1.0, curve: Curves.bounceOut))
            .animate(_controller);

    _controller.forward(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double currentWidth = width;
    double currentElevation = 0.0;

    final _movement = widget.movement;

    return SizedBox(
      height: kBottomNavigationBarHeight,
      child: AnimatedBuilder(
        builder: (context, snapshot) {
          currentWidth = width -
              (_movement * _animTabbarIn.value) +
              (_movement * _animTabbarOut.value);

          currentElevation = -_movement * _animElevationIn.value +
              (_movement - kBottomNavigationBarHeight / 4) *
                  _animElevationOut.value;

          return Center(
            child: Container(
              width: currentWidth,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.items.length,
                  (index) {
                    var child = widget.items[index];

                    var innerWidget = CircleAvatar(
                      radius: 30.0,
                      backgroundColor: widget.backgroundColor,
                      child: child,
                    );

                    if (index == _currentIndex) {
                      return Expanded(
                        child: CustomPaint(
                          foregroundPainter:
                              _CircleItemPainter(_animCircle.value),
                          child: Transform.translate(
                            offset: Offset(0.0, currentElevation),
                            child: innerWidget,
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: GestureDetector(
                            onTap: () {
                              widget.onTabbarChanged(index);
                              setState(() {
                                _currentIndex = index;
                              });
                              _controller.forward(from: 0.0);
                            },
                            child: innerWidget),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
        animation: _controller,
      ),
    );
  }
}

class _CircleItemPainter extends CustomPainter {
  final double progress;

  _CircleItemPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 20.0 * progress;
    final strokeWidth = 10.0;
    final currentStrokeWidth = strokeWidth * (1 - progress);

    final paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = currentStrokeWidth;

    if (progress < 1) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_CircleItemPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_CircleItemPainter oldDelegate) => false;
}
