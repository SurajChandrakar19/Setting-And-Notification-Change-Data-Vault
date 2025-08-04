// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_vault_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateDB _$CandidateDBFromJson(Map<String, dynamic> json) => CandidateDB(
  name: json['name'] as String,
  location: json['location'] as String,
  qualification: json['qualification'] as String,
  languages: json['languages'] as String,
  experience: json['experience'] as String,
  gender: json['gender'] as String,
  age: (json['age'] as num).toInt(),
  callStatus: json['callStatus'] as String,
  role: json['role'] as String,
  uploadDate: json['uploadDate'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  isUnlocked: json['isUnlocked'] as bool,
  notes: json['notes'] as String,
  other1: json['other1'] as String,
  other2: json['other2'] as String,
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$CandidateDBToJson(CandidateDB instance) =>
    <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
      'qualification': instance.qualification,
      'languages': instance.languages,
      'experience': instance.experience,
      'gender': instance.gender,
      'age': instance.age,
      'callStatus': instance.callStatus,
      'role': instance.role,
      'uploadDate': instance.uploadDate,
      'phone': instance.phone,
      'email': instance.email,
      'isUnlocked': instance.isUnlocked,
      'notes': instance.notes,
      'other1': instance.other1,
      'other2': instance.other2,
      'userId': instance.userId,
    };
