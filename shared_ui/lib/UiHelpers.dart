import 'package:flutter/material.dart';
import 'dart:math' as math;

Future showCustomDialog(
    {required BuildContext context,
    required String title,
    required List<Widget> children,
    bool dissmissable = true}) async {
  Dialog dialog = Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
              Text(
                title,
                style: const TextStyle(
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 20.0,
              ),
            ] +
            children,
      ),
    ),
  );
  await showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
      barrierDismissible: dissmissable);
}

Widget animatedFloatingActionButtons(
    AnimationController floatingButtonController,
    List<IconData> buttonsIcons,
    Color backgroundColor,
    Color foregroundColor,
    List<Function> func) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: new List.generate(buttonsIcons.length, (int index) {
      Widget child = new Container(
        height: 70.0,
        width: 56.0,
        alignment: FractionalOffset.topCenter,
        child: new ScaleTransition(
          scale: new CurvedAnimation(
            parent: floatingButtonController,
            curve: new Interval(0.0, 1.0 - index / (buttonsIcons.length * 4.0),
                curve: Curves.linearToEaseOut),
          ),
          child: new FloatingActionButton(
            heroTag: null,
            backgroundColor: backgroundColor,
            mini: true,
            child: new Icon(buttonsIcons[index], color: foregroundColor),
            onPressed: () {
              func[index].call();
            },
          ),
        ),
      );
      return child;
    }).toList()
      ..add(
        new FloatingActionButton(
          heroTag: null,
          child: new AnimatedBuilder(
            animation: floatingButtonController,
            builder: (BuildContext context, Widget? child) {
              return new Transform(
                transform: new Matrix4.rotationZ(
                    floatingButtonController.value * 0.5 * math.pi),
                alignment: FractionalOffset.center,
                child: new Icon(floatingButtonController.isDismissed
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
