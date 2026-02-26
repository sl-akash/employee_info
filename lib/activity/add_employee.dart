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

class AddemployeeActivity extends StatefulWidget {
  final UserData userData;

  const AddemployeeActivity({super.key, required this.userData});

  @override
  State<AddemployeeActivity> createState() => _AddemployeeActivityState();
}

class _AddemployeeActivityState extends State<AddemployeeActivity> {
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
      password;
  String? nameError,
      employeeIdError,
      phoneNumberError,
      joiningDateError,
      emailError,
      passwordError;
  bool isClicked = false, isAdmin = false, isActive = true, isLoading = false;

  ResponseData? imageResponse, dataResponse;

  File? _image;

  void clearData() {
    _image = null;
    imageResponse = null;
    isClicked = false;
    isAdmin = false;
    isActive = true;

    nameController.text = "";
    name = nameController.text;
    nameError = getError(name);

    employeeIdController.text = "";
    employeeId = employeeIdController.text;
    employeeIdError = getError(employeeId);

    countryCode = "+91";

    phoneNumberController.text = "";
    phoneNumber = phoneNumberController.text;
    phoneNumberError = getError(phoneNumber);

    joiningDateController.text = "";
    joiningDate = joiningDateController.text;
    joiningDateError = getError(joiningDate);

    lastDateController.text = "";
    lastDate = lastDateController.text;

    emailController.text = "";
    email = emailController.text;
    emailError = getEmailError();

    passwordController.text = "";
    password = passwordController.text;
    passwordError = getPasswordError();
  }

  late UserData userData;

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
        imageUrl: imageResponse != null ? imageResponse!.message : "",
        isActive: isActive ? 1 : 0,
        isAdmin: isAdmin ? 1 : 0,
        joiningDate: getTimeStamp(joiningDate),
        lastDate: getTimeStamp(lastDate),
        insertedDate: DateTime.now().millisecondsSinceEpoch,
        updatedDate: DateTime.now().millisecondsSinceEpoch,
        insertedBy: this.userData.id,
        updatedBy: this.userData.id,
        id: 0,
      );

      try {
        var data = {"request_type": "insert_user", "data": userData.toJson()};

        var formData = FormData.fromMap(data);

        var dio = Dio();

        Response response = await dio.post(
          "${Constants.baseUrl}user.php",
          data: formData,
        );

        ResponseData responseData = ResponseData.fromJson(jsonDecode(response.data));
        handleResponse(responseData, 1);
        
      } catch (e) {
        
      }

      // print(userData.toJson());
    }

    setState(() {
      isLoading = false;
    });
  }

  void handleResponse(ResponseData responseData, int type) {
    switch (type) {
      case 1:
        if (responseData.status == "success") {
          Constants.showSnackBar(context, Colors.green, responseData.message);
          clearData();
        } else {
          Constants.showSnackBar(context, Colors.red, responseData.message);
        }
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

      print(imageResponse!.message);

      print(response.data);
    } catch (e) {
      print("Upload error: $e");
    }
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
        "${Constants.addEmployee} ${Constants.page}".toUpperCase(),
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
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadiusGeometry.all(
                              Radius.circular(75),
                            ),
                            child: Image.file(_image!, width: 150, height: 150),
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 150,
                            color: Colors.grey,
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
                      initialSelection: 'IN',
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
                          await showDatePicker(
                            currentDate: DateTime.now(),
                            context: context,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ).then((date) {
                            if (date != null) {
                              joiningDateController.text =
                                  "${Constants.getDouble(date.day)}-${Constants.getDouble(date.month)}-${date.year}";
                              joiningDate = joiningDateController.text;
                              joiningDateError = getError(joiningDate);
                              if (isClicked) {
                                setState(() {});
                              }
                            }
                          });
                        },
                        controller: joiningDateController,
                        keyboardType: TextInputType.datetime,
                        onChanged: (value) {
                          joiningDate = joiningDateController.text;
                          joiningDateError = getError(joiningDate);
                          if (isClicked) {
                            setState(() {});
                          }
                        },
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
                              await showDatePicker(
                                currentDate: DateTime.now(),
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              ).then((date) {
                                if (date != null) {
                                  lastDateController.text =
                                      "${Constants.getDouble(date.day)}-${Constants.getDouble(date.month)}-${date.year}";
                                  lastDate = lastDateController.text;
                                }
                              });
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

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      width: imageWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Switch(
                            activeColor: Constants.signatureColor,
                            value: isActive,
                            onChanged: (status) {
                              setState(() {
                                isActive = status;
                              });
                            },
                          ),
                          SizedBox(width: 20),
                          Text(Constants.active),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      width: imageWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Switch(
                            activeColor: Constants.signatureColor,
                            value: isAdmin,
                            onChanged: (status) {
                              setState(() {
                                isAdmin = status;
                              });
                            },
                          ),
                          SizedBox(width: 20),
                          Text(Constants.admin),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    if (!isLoading) {
                      setState(() {
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

    nameController = TextEditingController();
    name = nameController.text;
    nameError = getError(name);

    employeeIdController = TextEditingController();
    employeeId = employeeIdController.text;
    employeeIdError = getError(employeeId);

    countryCode = "+91";

    phoneNumberController = TextEditingController();
    phoneNumber = phoneNumberController.text;
    phoneNumberError = getError(phoneNumber);

    joiningDateController = TextEditingController();
    joiningDate = joiningDateController.text;
    joiningDateError = getError(joiningDate);

    lastDateController = TextEditingController();
    lastDate = lastDateController.text;

    emailController = TextEditingController();
    email = emailController.text;
    emailError = getEmailError();

    passwordController = TextEditingController();
    password = passwordController.text;
    passwordError = getPasswordError();
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
    } else if (password.length < 8) {
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
