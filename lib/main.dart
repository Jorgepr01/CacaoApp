// import 'dart:convert';

import 'package:flutter/material.dart';



import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'auth_provider.dart';
import 'deteccion.dart';

import 'home_screen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            home: authProvider.isAuthenticated ? Deteccion() : LoginScreen(),
          );
        },
      ),
    );
  }
}