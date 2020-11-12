import 'package:flutter/material.dart';
import '../Screens/Index.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 1,
        navigateAfterSeconds: IndexPage(),
        title: Text(
          'ไผ่@ปราจีนบุรี',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
        ),
        image: Image.asset('assets/logo.png'),
        backgroundColor: Theme.of(context).primaryColor,
        styleTextUnderTheLoader: TextStyle(color: Colors.white),
        photoSize: 100.0,
        loaderColor: Colors.white);
  }
}
