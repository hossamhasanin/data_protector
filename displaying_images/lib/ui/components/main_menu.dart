import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  final Function() goToAboutUs;

  const MainMenu({Key? key, required this.goToAboutUs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PopupMenuButton<String>(
            onSelected: (String choice) {
              switch (choice) {
                case 'About us':
                  goToAboutUs();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'About us'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            )),
      ],
    );
  }
}
