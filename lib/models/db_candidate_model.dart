// candidate_db_dto.dart
import '../models/db_candiate_status_model.dart';
import 'package:flutter/material.dart';

class CandidateDBDTO {
  final int? candidateDBId;
  final String? name;
  final String? location;
  final String? qualification;
  final String? languages;
  final String? experience;
  final String? gender;
  final int? age;
  final String? callStatus;
  final String? role;
  final String? uploadDate;
  final String? phone;
  final String? email;
  final bool? isUnlocked;
  final String? notes;
  final String? other1;
  final String? other2;
  final int? userId;
  final String? addedDate;
  final String? updateDate;
  final List<StatusDTO>? statusList;

  CandidateDBDTO({
    this.candidateDBId,
    this.name,
    this.location,
    this.qualification,
    this.languages,
    this.experience,
    this.gender,
    this.age,
    this.callStatus,
    this.role,
    this.uploadDate,
    this.phone,
    this.email,
    this.isUnlocked,
    this.notes,
    this.other1,
    this.other2,
    this.userId,
    this.addedDate,
    this.updateDate,
    this.statusList,
  });

  factory CandidateDBDTO.fromJson(Map<String, dynamic> json) {
    return CandidateDBDTO(
      candidateDBId: json['candidateDBId'],
      name: json['name'],
      location: json['location'],
      qualification: json['qualification'],
      languages: json['languages'],
      experience: json['experience'],
      gender: json['gender'],
      age: json['age'],
      callStatus: json['callStatus'],
      role: json['role'],
      uploadDate: json['uploadDate'],
      phone: json['phone'],
      email: json['email'],
      isUnlocked: json['isUnlocked'],
      notes: json['notes'],
      other1: json['other1'],
      other2: json['other2'],
      userId: json['userId'],
      addedDate: json['addedDate'],
      updateDate: json['updateDate'],
      statusList: (json['statusList'] as List<dynamic>?)
          ?.map((e) => StatusDTO.fromJson(e))
          .toList(),
    );
  }
}

// class CandidateModelConverter {
//   final String candidateId;
//   final String? name;
//   final String? location;
//   final String? qualification;
//   final String? languages;
//   final String? experience;
//   final String? gender;
//   final String? age;
//   String? status;
//   final String? role;
//   final String? uploadDate;
//   final String? phone;
//   final String? email;
//   bool? isUnlocked;

//   CandidateModelConverter({
//     required this.candidateId,
//     this.name,
//     this.location,
//     this.qualification,
//     this.languages,
//     this.experience,
//     this.gender,
//     this.age,
//     this.status,
//     this.role,
//     this.uploadDate,
//     this.phone,
//     this.email,
//     this.isUnlocked,
//   });

//   factory CandidateModelConverter.fromJson(Map<String, dynamic> json) {
//     return CandidateModelConverter(
//       candidateId: json['candidateDBId'].toString(),
//       name: json['name'],
//       location: json['location'],
//       qualification: json['qualification'],
//       languages: json['languages'],
//       experience: json['experience'],
//       gender: json['gender'],
//       age: json['age']?.toString(),
//       role: json['role'],
//       uploadDate: json['uploadDate'],
//       phone: json['phone'],
//       email: json['email'],
//       isUnlocked: json['unlocked'],

//       // Optional: You can extract status from statusList if needed
//       status: (json['statusList'] as List).isNotEmpty
//           ? json['statusList'][0]['status']
//           : null,
//     );
//   }
// }

class CandidateModelConverter {
  final String candidateId;
  final String? name;
  final String? location;
  final String? qualification;
  final String? languages;
  final String? experience;
  final String? gender;
  final String? age;
  String? status;
  final String? role;
  final String? uploadDate;
  final String? phone;
  final String? email;
  bool? isUnlocked;
  final List<StatusDTO>? statusList;

  CandidateModelConverter({
    required this.candidateId,
    this.name,
    this.location,
    this.qualification,
    this.languages,
    this.experience,
    this.gender,
    this.age,
    this.status,
    this.role,
    this.uploadDate,
    this.phone,
    this.email,
    this.isUnlocked,
    this.statusList,
  });

  factory CandidateModelConverter.fromJson(Map<String, dynamic> json) {
    List<StatusDTO>? statuses = (json['statusList'] as List?)
        ?.map((e) => StatusDTO.fromJson(e))
        .toList();

    return CandidateModelConverter(
      candidateId: json['candidateDBId'].toString(),
      name: json['name'],
      location: json['location'],
      qualification: json['qualification'],
      languages: json['languages'],
      experience: json['experience'],
      gender: json['gender'],
      age: json['age']?.toString(),
      role: json['role'],
      uploadDate: json['uploadDate'],
      phone: json['phone'],
      email: json['email'],
      isUnlocked: json['unlocked'],
      statusList: statuses,
      status: statuses?.isNotEmpty == true ? statuses!.first.statusName : null,
    );
  }
}
