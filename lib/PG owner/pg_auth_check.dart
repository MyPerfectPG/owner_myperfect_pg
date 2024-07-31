import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:owner_myperfect_pg/PG%20owner/pg_login.dart';

import 'owner_home.dart';

class PGAuthCheck extends StatefulWidget {
  const PGAuthCheck({super.key});

  @override
  State<PGAuthCheck> createState() => _PGAuthCheckState();
}

class _PGAuthCheckState extends State<PGAuthCheck> {
  var auth=FirebaseAuth.instance;
  var isLogin=false;

  checkIfLogin()async{
    auth.authStateChanges().listen((User?user) {
      if(user!=null && mounted){
        setState(() {
          isLogin=true;
        });
      }
    });
  }

  @override
  void initState(){
    checkIfLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLogin ?  HomeScreen(): OwnerLoginScreen(),
    );
  }
}