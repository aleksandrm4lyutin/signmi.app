import 'package:flutter/material.dart';

const txtInputDecor = InputDecoration(
  isDense: true,
  errorStyle: TextStyle(
    //color: color1,
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(8.0),
    ),
    borderSide: BorderSide(
      color: Color(0xFFFF3D00),//deepOrangeAccent[400]
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
      borderSide: BorderSide(
        color: Colors.grey,
      )
  ),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        const Radius.circular(8.0),
      ),
      borderSide: BorderSide(
        width: 1.0,
        color: Colors.grey,//grey[500]
      )
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(8.0),
    ),
    borderSide: BorderSide(
      width: 1.0,
      color: Color(0xFFEEEEEE),//grey[200]
    ),
  ),
  filled: true,
  fillColor: Color(0xFFEEEEEE),//grey[200]
);