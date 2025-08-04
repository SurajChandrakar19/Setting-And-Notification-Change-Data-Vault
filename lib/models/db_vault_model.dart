import 'package:json_annotation/json_annotation.dart';

part 'db_vault_model.g.dart';

@JsonSerializable()
class CandidateDB {
  final String name;
  final String location;
  final String qualification;
  final String languages;
  final String experience;
  final String gender;
  final int age;
  final String callStatus;
  final String role;
  final String uploadDate;
  final String phone;
  final String email;
  final bool isUnlocked;
  final String notes;
  final String other1;
  final String other2;
  final int userId;

  CandidateDB({
    required this.name,
    required this.location,
    required this.qualification,
    required this.languages,
    required this.experience,
    required this.gender,
    required this.age,
    required this.callStatus,
    required this.role,
    required this.uploadDate,
    required this.phone,
    required this.email,
    required this.isUnlocked,
    required this.notes,
    required this.other1,
    required this.other2,
    required this.userId,
  });

  factory CandidateDB.fromJson(Map<String, dynamic> json) =>
      _$CandidateDBFromJson(json);

  Map<String, dynamic> toJson() => _$CandidateDBToJson(this);
}
