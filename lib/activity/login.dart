import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:employee_log/activity/home.dart';
import 'package:employee_log/data/data.dart';
import 'package:employee_log/support/constants.dart';
import 'package:flutter/material.dart';

class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key});

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  late TextEditingController emailController, passwordController;
  late String email, password;
  String? emailError, passwordError;
  bool isClicked = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    email = emailController.text;
    emailError = getEmailError();
    passwordController = TextEditingController();
    password = passwordController.text;
    passwordError = getPasswordError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.signatureColor,
      appBar: Constants.appBar(
        "${Constants.login} ${Constants.page}".toUpperCase(),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(Constants.logoUrl),
                SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = emailController.text;
                    emailError = getEmailError();
                    if (isClicked) {
                      setState(() {});
                    }
                  },
                  controller: emailController,
                  decoration: Constants.buttonDecoration(
                    Icons.email,
                    Constants.enterEmail,
                  ),
                ),
                if (emailError != null && isClicked)
                  Constants.errorMessage(emailError!),
                SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    password = passwordController.text;
                    passwordError = getPasswordError();
                    if (isClicked) {
                      setState(() {});
                    }
                  },
                  controller: passwordController,
                  decoration: Constants.buttonDecoration(
                    Icons.password,
                    Constants.enterPassword,
                  ),
                ),
                if (passwordError != null && isClicked)
                  Constants.errorMessage(passwordError!),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    if (!isLoading) {
                      setState(() {
                        isClicked = true;
                        isLoading = true;
                      });
                      loginUser();
                    }
                    
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                            constraints: BoxConstraints(
                              maxHeight: 35,
                              maxWidth: 35,
                              minHeight: 35,
                              minWidth: 35,
                            ),
                          )
                        : Text(
                            Constants.login.toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? getEmailError() {
    if (email.isEmpty) {
      return Constants.required;
    } else if (!Constants.isValidEmail(email)) {
      return Constants.invalidFormat;
    }
    return null;
  }

  String? getPasswordError() {
    if (password.isEmpty) {
      return Constants.required;
    }
    return null;
  }

  void loginUser() async {
    if (emailError == null && passwordError == null) {
      try {
        var data = {
          "request_type": "auth_user",
          "data": {"email": email, "password": password},
        };

        var dio = Dio();

        Response response = await dio.get(
          "${Constants.baseUrl}user.php",
          queryParameters: data,
        );

        ResponseData responseData = ResponseData.fromJson(
          jsonDecode(response.data),
        );

        if (responseData.status == "error") {
          Constants.showSnackBar(context, Colors.red, responseData.message);
        } else {
          Constants.showSnackBar(context, Colors.green, "Login successfully");

          navigateTo(UserData.fromJson(jsonDecode(responseData.message)));
        }
      } catch (e) {
        print(e);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void navigateTo(UserData userData) {

    if (userData.isActive == 0 || (userData.lastDate != 0 && DateTime.now().millisecondsSinceEpoch > userData.lastDate!)) {
      Constants.showSnackBar(context, Colors.red, "User not allowed");
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeActivity(userData: userData)),
      (route) => false,
    );
  }
}
