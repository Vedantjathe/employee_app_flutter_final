import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
                backgroundColor: Colors.transparent,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 150,
                      height: 120,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(color: Colors.red),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Please Wait....",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Segoe',
                                  fontWeight: FontWeight.normal),
                            ),
                          ]),
                    ),
                  ),
                ]),
          );
        });
  }
}
