import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'features/auth/screens/login_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnVE',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        ...AppRoutes.routes,
      },
    );
  }
}
