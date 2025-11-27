import 'dart:convert';

UserProfile userProfileFromJson(String str) =>
    UserProfile.fromJson(json.decode(str));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  final String? status;
  final String? message;
  final Data? data;

  UserProfile({this.status, this.message, this.data});

  UserProfile copyWith({String? status, String? message, Data? data}) =>
      UserProfile(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final int? userId;
  final String? email;
  final String? name;
  final String? profileUrl;

  Data({this.userId, this.email, this.name, this.profileUrl});

  Data copyWith({
    int? userId,
    String? email,
    String? name,
    String? profileUrl,
  }) => Data(
    userId: userId ?? this.userId,
    email: email ?? this.email,
    name: name ?? this.name,
    profileUrl: profileUrl ?? this.profileUrl,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    email: json["email"],
    name: json["name"],
    profileUrl: json["profileUrl"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "email": email,
    "name": name,
    "profileUrl": profileUrl,
  };
}
