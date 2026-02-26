
class UserData {

  late String staffName, employeeId, countryCode, phoneNumber, email, password, imageUrl;
  int? isActive, isAdmin, joiningDate, lastDate, insertedDate, updatedDate, insertedBy, updatedBy, id;

  UserData({
    required this.staffName,
    required this.employeeId,
    required this.countryCode,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.imageUrl,
    required this.isActive,
    required this.isAdmin,
    required this.joiningDate,
    required this.lastDate,
    required this.insertedDate,
    required this.updatedDate,
    required this.insertedBy,
    required this.updatedBy,
    required this.id,
  });

  UserData.secondary({
    required this.staffName,
    required this.employeeId,
    required this.countryCode,
    required this.phoneNumber,
    required this.email,
    required this.isActive,
    required this.isAdmin,
    required this.joiningDate,
    required this.lastDate,
    required this.insertedDate,
    required this.updatedDate,
  });



  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(staffName: json['staffName'], employeeId: json['employeeId'],
      countryCode: json['countryCode'], phoneNumber: json['phoneNumber'],
      email: json['email'], password: json['password'], imageUrl: json['imageUrl'], 
      isActive: json['isActive'], isAdmin: json['isAdmin'], joiningDate: json['joiningDate'], 
      lastDate: json['lastDate'], insertedDate: json['insertedDate'], updatedDate: json['updatedDate'],
      insertedBy: json['insertedBy'], updatedBy: json['updatedBy'], id: json['id']
      );
  }

  Map<String, dynamic> toJson() {
    return {
      "staffName" : staffName,
      "employeeId" : employeeId,
      "countryCode" : countryCode,
      "phoneNumber" : phoneNumber,
      "email" : email,
      "password" : password,
      "imageUrl" : imageUrl,
      "isActive" : isActive,
      "isAdmin" : isAdmin,
      "joiningDate" : joiningDate,
      "lastDate" : lastDate,
      "insertedDate" : insertedDate,
      "updatedDate" : updatedDate,
      "insertedBy" : insertedBy,
      "updatedBy": updatedBy,
      "id" : id
    };
  }

}

class ResponseData {
  late String status, message;

  ResponseData({
    required this.status,
    required this.message
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(status: json["status"], message: json["message"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "status" : status,
      "message" : message
    };
  }

}