import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFloatingButton extends StatefulWidget {
  final List<IconData> buttonsIcons;
  final Color backgroundColor;
  final Color foregroundColor;
  final List<Function> action;
  const AnimatedFloatingButton(
      {Key? key,
      required this.buttonsIcons,
      required this.backgroundColor,
      required this.foregroundColor,
      required this.action})
      : super(key: key);

  @override
  State<AnimatedFloatingButton> createState() => AnimatedFloatingButtonState();
}

class AnimatedFloatingButtonState extends State<AnimatedFloatingButton>
    with TickerProviderStateMixin {
  late final AnimationController floatingButtonController;

  @override
  void initState() {
    floatingButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.buttonsIcons.length, (int index) {
        Widget child = Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: floatingButtonController,
              curve: Interval(
                  0.0, 1.0 - (index / (widget.buttonsIcons.length * 4.0)),
                  curve: Curves.easeInOut),
              // curve: Curves.easeOut
            ),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: widget.backgroundColor,
              mini: true,
              child: Icon(widget.buttonsIcons[index],
                  color: widget.foregroundColor),
              onPressed: () {
                widget.action[index].call();
              },
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          FloatingActionButton(
            heroTag: null,
            child: AnimatedBuilder(
              animation: floatingButtonController,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  transform: Matrix4.rotationZ(
                      floatingButtonController.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: Icon(floatingButtonController.isDismissed
                      ? Icons.add
                      : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (floatingButtonController.isDismissed) {
                floatingButtonController.forward();
              } else {
                floatingButtonController.reverse();
              }
            },
          ),
        ),
    );
  }

  cancelButton() {
    floatingButtonController.reverse();
  }
}
