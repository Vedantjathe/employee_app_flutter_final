import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool showBackrop;
  const LoadingOverlay({super.key, this.showBackrop = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: showBackrop ? const Color.fromRGBO(76, 102, 102, 0.3) : null,
      child: Center(
          child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.circular(10)),
        child: const Material(
          color: Colors.transparent,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
        ),
      )),
    );
  }
}
