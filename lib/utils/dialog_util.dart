import 'package:flutter/material.dart';

uploadFileDialog(BuildContext context,
    {VoidCallback? cameraCallback, VoidCallback? storageCallBack}) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 15, 0, 5),
                    child: Text(
                      "Upload File",
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Segoe',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: InkWell(
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: Color(0XFFE3E3E3),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              margin: const EdgeInsets.only(right: 5, left: 10),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/camera_ic.png",
                                    scale: 3.0,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Camera",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Segoe',
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              )),
                          onTap: cameraCallback,
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color(0XFFE3E3E3),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            margin: const EdgeInsets.only(left: 5, right: 10),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/gallery_ic.png",
                                  scale: 3.0,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Storage",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Segoe',
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          onTap: storageCallBack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(10, 8, 0, 8),
                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Segoe',
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          ),
        );
      }).then((value) => {});
}

Future<dynamic> showNoInternetDialogBox(
    BuildContext context, VoidCallback onPressed) {
  String appName = 'Employee';
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: Text(
        appName,
        style: const TextStyle(
            color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: const Text('No Internet Connection. Please try again later'),
      actions: <Widget>[
        TextButton(
          onPressed: onPressed,
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

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
                      child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            )
                          ]),
                    ))
                  ]));
        });
  }
}
