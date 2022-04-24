import 'package:flutter/material.dart';

formStyle({required String labeltext, required IconData icon}) {
  return InputDecoration(
      labelText: labeltext,
      prefixIcon: Icon(icon),
      enabledBorder:
          UnderlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder:
          UnderlineInputBorder(borderRadius: BorderRadius.circular(12)));
}

buttonStyle(double width) {
  return ElevatedButton.styleFrom(
      primary: Colors.orangeAccent,
      minimumSize: Size(width, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(color: Colors.black, fontSize: 18));
}
