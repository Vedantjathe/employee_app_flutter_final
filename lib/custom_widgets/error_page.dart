import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 100,
              color: Color(0xFF3A9FBE),
            ),
            Text(
              'Error',
              style: TextStyle(
                fontFamily: 'poppins_regular',
                color: Colors.red,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 6.0),
            Text(
              'Please Contact KDL Admin',
              style: TextStyle(
                fontFamily: 'poppins_regular',
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
