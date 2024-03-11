import 'package:flutter/material.dart';

class RequiredPermissionPage extends StatelessWidget {
  final String _description =
      'It seems your login credentials is not enabled the required permissions to access this page. We would advise you to reach out to your system administrator for additional permissions.';

  const RequiredPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Required permissions missing',
              style: TextStyle(
                fontFamily: 'poppins_regular',
                color: Color(0xFF3A9FBE),
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 6.0),
            const Text(
              'No Permissions',
              style: TextStyle(
                fontFamily: 'poppins_regular',
                fontSize: 15.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                _description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'poppins_regular',
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
