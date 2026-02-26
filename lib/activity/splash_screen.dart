import 'package:employee_log/activity/login.dart';
import 'package:employee_log/support/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreenActivity extends StatefulWidget {
  const SplashScreenActivity({super.key});

  @override
  State<SplashScreenActivity> createState() => _SplashScreenActivityState();
}

class _SplashScreenActivityState extends State<SplashScreenActivity> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    delayActivity();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Future<void> delayActivity() async {
    await Future.delayed(Duration(seconds: 2), () {
      navigateTo();
    });
  }

  void navigateTo() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginActivity()),
        (route) => false,
      );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double imageWidth = (width - 148) / 2;
    return Scaffold(
      backgroundColor: Constants.signatureColor,
      body: Padding(
        padding: EdgeInsetsGeometry.all(20.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Image.asset(Constants.logoUrl)],
          ),
        ),
      ),
    );
  }
}
