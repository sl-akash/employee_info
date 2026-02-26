import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:employee_log/data/data.dart';
import 'package:employee_log/support/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UserEmployeeActivity extends StatefulWidget {
  final UserData userData, myData;

  const UserEmployeeActivity({
    super.key,
    required this.userData,
    required this.myData,
  });

  @override
  State<UserEmployeeActivity> createState() => _UserEmployeeActivityState();
}

class _UserEmployeeActivityState extends State<UserEmployeeActivity> {
  late TextEditingController nameController,
      employeeIdController,
      phoneNumberController,
      joiningDateController,
      lastDateController,
      emailController,
      passwordController;
  late String name,
      employeeId,
      countryCode,
      phoneNumber,
      joiningDate,
      lastDate,
      email,
      password,
      imageUrl;
  String? nameError,
      employeeIdError,
      phoneNumberError,
      joiningDateError,
      emailError,
      passwordError;
  bool isClicked = false, isAdmin = false, isActive = true, isLoading = false;

  ResponseData? imageResponse, dataResponse;

  File? _image;

  late UserData userData, myData;

  Future<void> uploadData() async {
    isClicked = true;

    if (nameError == null &&
        employeeIdError == null &&
        phoneNumberError == null &&
        joiningDateError == null &&
        emailError == null &&
        passwordError == null) {
      UserData userData = UserData(
        staffName: name,
        employeeId: employeeId,
        countryCode: countryCode,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        imageUrl: imageResponse != null ? imageResponse!.message : this.userData.imageUrl,
        isActive: isActive ? 1 : 0,
        isAdmin: isAdmin ? 1 : 0,
        joiningDate: getTimeStamp(joiningDate),
        lastDate: getTimeStamp(lastDate),
        insertedDate: this.userData.insertedDate,
        updatedDate: DateTime.now().millisecondsSinceEpoch,
        insertedBy: this.userData.insertedBy,
        updatedBy: myData.id,
        id: this.userData.id,
      );

      try {
        var data = {"request_type": "update_user", "data": userData.toJson()};

        var formData = FormData.fromMap(data);

        var dio = Dio();

        Response response = await dio.post(
          "${Constants.baseUrl}user.php",
          data: formData,
        );

        ResponseData responseData = ResponseData.fromJson(jsonDecode(response.data));
        handleResponse(responseData, 1);
      } catch (e) {
        print(e);
      }

      // print(userData.toJson());
    } else {
      // print("Unknown");
    }

    setState(() {
      isLoading = false;
    });
  }

  

  void handleResponse(ResponseData responseData, int type) {
    switch (type) {
      case 1:
        Color color = Colors.red;
        if (responseData.status == "success") {
          color = Colors.green;
        }
        Constants.showSnackBar(context, color, responseData.message);
        break;
    }
  }

  int getTimeStamp(String dateText) {
    DateFormat format = DateFormat("dd-MM-yyyy");
    DateTime? date = format.tryParse(dateText);
    return date != null ? date.millisecondsSinceEpoch : 0;
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      cropImage(pickedFile.path);
    }
  }

  Future<void> uploadFile(String filePath) async {
    final dio = Dio();

    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      Response response = await dio.post(
        "${Constants.baseUrl}profile.php",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      imageResponse = ResponseData.fromJson(jsonDecode(response.data));

      imageResponse!.message = "${Constants.baseUrl}${imageResponse!.message}";
    } catch (e) {}
  }

  Future<void> cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
          uploadFile(_image!.path);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double textWidth = (width - 142) / 2;
    double imageWidth = (width - 100) / 2;
    return Scaffold(
      backgroundColor: Constants.signatureColor,
      appBar: Constants.appBar(
        "${Constants.employee} ${Constants.page}".toUpperCase(),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: pickImage,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(85)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(75),
                      ),
                      child: Stack(
                        children: [
                          if (_image != null)
                            Image.file(_image!, width: 150, height: 150),

                          if (_image == null && imageUrl.isNotEmpty)
                            Image.network(
                              userData.imageUrl,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),

                          if (imageUrl.isEmpty && _image == null)
                            Icon(
                              Icons.account_circle,
                              size: 150,
                              color: Colors.grey,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    name = nameController.text;
                    nameError = getError(name);
                    if (isClicked) {
                      setState(() {});
                    }
                  },
                  controller: nameController,
                  decoration: Constants.buttonDecoration(
                    Icons.account_circle,
                    Constants.enterStaffName,
                  ),
                ),
                if (nameError != null && isClicked)
                  Constants.errorMessage(nameError!),
                SizedBox(height: 20),

                TextField(
                  readOnly: true,
                  controller: employeeIdController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    employeeId = employeeIdController.text;
                    employeeIdError = getError(employeeId);
                    if (isClicked) {
                      setState(() {});
                    }
                  },
                  decoration: Constants.buttonDecoration(
                    Icons.perm_identity,
                    Constants.enterEmployeeId,
                  ),
                ),
                if (employeeIdError != null && isClicked)
                  Constants.errorMessage(employeeIdError!),
                SizedBox(height: 20),

                Row(
                  children: [
                    CountryCodePicker(
                      onChanged: (country) {
                        countryCode = country.dialCode!;
                      },
                      initialSelection: countryCode,
                      favorite: ['+91', 'IN'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          phoneNumberController.text = value;
                          phoneNumber = phoneNumberController.text;
                          phoneNumberError = getError(phoneNumber);

                          if (isClicked) {
                            setState(() {});
                          }
                        },
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: Constants.buttonDecoration2(
                          Constants.enterPhoneNumber,
                        ),
                      ),
                    ),
                  ],
                ),

                if (phoneNumberError != null && isClicked)
                  Constants.errorMessage(phoneNumberError!),

                SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 17),
                    SizedBox(
                      width: textWidth,
                      child: TextField(
                        readOnly: true,
                        onTap: () async {
                          
                        },
                        controller: joiningDateController,
                        keyboardType: TextInputType.datetime,
                        decoration: Constants.buttonDecoration2(
                          Constants.enterJoiningDate,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        SizedBox(
                          width: textWidth,
                          child: TextField(
                            readOnly: true,
                            onTap: () async {
                              
                            },
                            controller: lastDateController,
                            keyboardType: TextInputType.datetime,
                            onChanged: (value) {
                              lastDateController.text = value;
                              lastDate = lastDateController.text;
                            },
                            decoration: Constants.buttonDecoration2(
                              Constants.enterLastDate,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (joiningDateError != null && isClicked)
                  Row(
                    children: [
                      SizedBox(
                        width: width / 2 - 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Constants.errorMessage(Constants.required),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),

                TextField(
                  readOnly: true,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = emailController.text;
                    emailError = getEmailError();
                    if (isClicked) {
                      setState(() {});
                    }
                  },
                  decoration: Constants.buttonDecoration(
                    Icons.email,
                    Constants.enterEmail,
                  ),
                ),
                if (emailError != null && isClicked)
                  Constants.errorMessage(emailError!),
                SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    password = passwordController.text;
                    passwordError = getPasswordError();
                    // print(passwordError);
                    // print(password);
                    if (isClicked) {
                      setState(() {});
                    }
                  },
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
                      uploadData();
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
                            Constants.update.toUpperCase(),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userData = widget.userData;
    myData = widget.myData;
    nameController = TextEditingController(text: userData.staffName);
    name = nameController.text;
    nameError = getError(name);

    employeeIdController = TextEditingController(text: userData.employeeId);
    employeeId = employeeIdController.text;
    employeeIdError = getError(employeeId);

    countryCode = userData.countryCode;

    phoneNumberController = TextEditingController(text: userData.phoneNumber);
    phoneNumber = phoneNumberController.text;
    phoneNumberError = getError(phoneNumber);

    joiningDateController = TextEditingController(
      text: getDateFormat(userData.joiningDate!),
    );
    joiningDate = joiningDateController.text;
    joiningDateError = getError(joiningDate);

    lastDateController = TextEditingController(
      text: getDateFormat(userData.lastDate!),
    );
    lastDate = lastDateController.text;

    emailController = TextEditingController(text: userData.email);
    email = emailController.text;
    emailError = getEmailError();

    passwordController = TextEditingController();
    password = passwordController.text;
    passwordError = getPasswordError();

    isActive = userData.isActive == 1;

    isAdmin = userData.isAdmin == 1;

    imageUrl = userData.imageUrl;
  }

  String getDateFormat(int timestamp) {
    if (timestamp != 0) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return "${Constants.getDouble(dateTime.day)}-${Constants.getDouble(dateTime.month)}-${dateTime.year}";
    }

    return "";
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
    if (password.isNotEmpty && password.length < 8) {
      return Constants.minimumLengthIsEight;
    }
    return null;
  }

  String? getError(String text) {
    if (text.isEmpty) {
      return Constants.required;
    }
    return null;
  }
}
