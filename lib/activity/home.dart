import 'package:employee_log/activity/add_employee.dart';
import 'package:employee_log/activity/employee.dart';
import 'package:employee_log/activity/user_employee.dart';
import 'package:employee_log/data/data.dart';
import 'package:employee_log/support/constants.dart';
import 'package:flutter/material.dart';

class HomeActivity extends StatefulWidget {
  final UserData userData;

  const HomeActivity({super.key, required this.userData});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  late UserData userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double imageWidth = (width - 120) / 2;
    return Scaffold(
      backgroundColor: Constants.signatureColor,
      appBar: AppBar(
        title: Text(
          "${Constants.home} ${Constants.page}".toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Constants.signatureColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "0") {
                Constants.showSnackBar(
                  context,
                  Colors.green,
                  "User Logged Out",
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeActivity(userData: userData),
                  ),
                  (route) => false,
                );
              } else if (value == "1") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEmployeeActivity(
                      userData: userData,
                      myData: userData,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "1",
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "0",
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // appBar: Constants.appBar(
      //   "${Constants.home} ${Constants.page}".toUpperCase(),
      // ),
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
              Image.asset(Constants.logoUrl),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EmployeeActivity(userData: userData),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: imageWidth,
                          height: imageWidth,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Image.asset(Constants.employeeUrl),
                        ),
                        Text(
                          Constants.employee,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  if (userData.isAdmin == 1) SizedBox(width: 20),
                  if (userData.isAdmin == 1)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddemployeeActivity(userData: userData),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: imageWidth,
                            height: imageWidth,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Image.asset(Constants.addEmployeeUrl),
                          ),
                          Text(
                            Constants.addEmployee,
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
