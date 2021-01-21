import 'package:flutter/material.dart';

showCustomDialog({BuildContext context , String title , List<Widget> children}){
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
            style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white
            ),
          ),
          SizedBox(height: 20.0,),
        ]+children,
      ),
    ),
  );
  showDialog(context: context , builder: (BuildContext context) => dialog);
}
