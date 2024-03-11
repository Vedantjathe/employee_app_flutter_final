import 'package:flutter/material.dart';

const kTFFDecoration = InputDecoration(
  filled: true,
  fillColor: Color(0XFFF9F9F9),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
  counterText: "",
  errorStyle: TextStyle(height: 0),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(width: 1.3, color: Color(0XFFBEDCF0)),
  ),
);
