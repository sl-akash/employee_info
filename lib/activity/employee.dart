import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:employee_log/activity/unique_employee.dart';
import 'package:employee_log/data/data.dart';
import 'package:employee_log/support/constants.dart';
import 'package:flutter/material.dart';

class EmployeeActivity extends StatefulWidget {
  final UserData userData;

  const EmployeeActivity({super.key, required this.userData});

  @override
  State<EmployeeActivity> createState() => _EmployeeActivityState();
}

class _EmployeeActivityState extends State<EmployeeActivity> {
  List<UserData> userDataList = [];

  late UserData userData;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    getAllUser();
  }

  Future<void> getAllUser() async {
    try {
      var dio = Dio();

      var data = {"request_type": "get_all_user"};

      Response response = await dio.get(
        "${Constants.baseUrl}user.php",
        queryParameters: data,
      );

      var jsonList = jsonDecode(response.data);

      userDataList.clear();

      for (var json in jsonList) {
        userDataList.add(UserData.fromJson(json));
      }
    } catch (e) {}

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Constants.signatureColor,
      appBar: Constants.appBar(
        "${Constants.employee} ${Constants.page}".toUpperCase(),
      ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isLoading) CircularProgressIndicator(color: Colors.black),
              if (!isLoading)
                for (UserData userData in userDataList)
                  employeeRecycler(userData, width),
            ],
          ),
        ),
      ),
    );
  }

  InkWell employeeRecycler(UserData userData, double width) {
    Color backgroundColor = const Color.fromARGB(255, 219, 219, 219);

    double duration =
        (DateTime.now().millisecondsSinceEpoch - userData.joiningDate!) /
        (5 * 365 * 24 * 60 * 60 * 1000);

    if (userData.isActive == 0 ||
        (DateTime.now().millisecondsSinceEpoch > userData.lastDate! &&
            userData.lastDate != 0)) {
      backgroundColor = Colors.redAccent;
    } else if (duration > 1) {
      backgroundColor = Colors.greenAccent;
    }

    return InkWell(
      onTap: () {
        if (this.userData.isAdmin == 1) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => UniqueEmployeeActivity(
                    userData: userData,
                    myData: this.userData,
                  ),
                ),
              )
              .then((onValue) {
                if (onValue != null && onValue) {
                  setState(() {
                    isLoading = true;
                  });
                }
                getAllUser();
              });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: Colors.grey),
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: userData.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(10),
                      ),
                      child: Image.network(
                        userData.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.account_circle, size: 80, color: Colors.grey),
            ),
            SizedBox(width: 10),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 60, child: Text(Constants.name)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                      child: Text(Constants.collan),
                    ),
                    SizedBox(
                      width: width - 270,
                      child: Text(userData.staffName),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 60, child: Text(Constants.id)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                      child: Text(Constants.collan),
                    ),
                    SizedBox(
                      width: width - 270,
                      child: Text(userData.employeeId),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 60, child: Text(Constants.phone)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                      child: Text(Constants.collan),
                    ),
                    SizedBox(
                      width: width - 270,
                      child: Text(
                        "${userData.countryCode} ${userData.phoneNumber}",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
