import 'package:flutter/material.dart';

class Constants {
  static String userId = "userId";
  static String update = "Update";
  static String delete = "Delete";
  static String login = "Login";
  static String page = "Page";
  static String home = "Home";
  static String enterEmail = "Enter the email";
  static String enterPassword = "Enter the password";
  static String required = "Required";
  static String invalidFormat = "Invalid format";
  static String employee = "Employee";
  static String addEmployee = "Add Employee";
  static String minimumLengthIsEight = "minimum lengh is 8";
  static String enterStaffName = "Enter staff name";
  static String enterEmployeeId = "Enter employee Id";
  static String enterJoiningDate = "Joining date";
  static String enterLastDate = "Last date";
  static String enterPhoneNumber = "Enter phone number";
  static String admin = "Admin";
  static String active = "Active";
  static String staffName = "Staff Name";
  static String employeeId = "Employee Id";
  static String phoneNumber = "Phone Number";
  static String joiningDate = "Joining Date";
  static String lastDate = "Last Date";
  static String email = "Email";
  static String password = "Password";
  static String collan = ":";
  static String name = "Name";
  static String id = "Id";
  static String phone = "Phone";
  static String number = "Number";

  static String baseUrl = "https://slprojects.slinnoventures.com/uploads/";

  static Color signatureColor = Color.fromARGB(15, 5, 145, 226);

  static void showSnackBar(BuildContext context, Color color, String message) {
    SnackBar snackBar = SnackBar(content: Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), backgroundColor: color);

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static AppBar appBar(String title) {
    return AppBar(
      title: Text(title, style: 
        TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),
      ), 
      backgroundColor: signatureColor, 
      foregroundColor: Colors.white,
    );
  }

  static InputDecoration buttonDecoration(IconData icon, String label) {
    return InputDecoration(
      icon: Icon(icon),
      labelText: label,
      border: OutlineInputBorder()
    );
  }

  static InputDecoration buttonDecoration2(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder()
    );
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  static Row errorMessage(String error) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(error.toLowerCase(), style: TextStyle(color: Colors.red),),
        ],
      );
  }

  static String getDouble(int number) {
    if (number < 10) {
      return "0$number";
    }
    return number.toString();
  }

  static String logoUrl = "assert/logo.png";
  static String addEmployeeUrl = "assert/add_employee.png";
  static String employeeUrl = "assert/employee.jpg";
}