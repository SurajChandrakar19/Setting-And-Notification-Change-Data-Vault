// status_dto.dart
class StatusDTO {
  final int? statusDBId;
  final String? statusName;
  final String? other1;
  final String? addedDate;

  StatusDTO({this.statusDBId, this.statusName, this.other1, this.addedDate});

  factory StatusDTO.fromJson(Map<String, dynamic> json) {
    return StatusDTO(
      statusDBId: json['statusDBId'],
      statusName: json['statusName'],
      other1: json['other1'],
      addedDate: json['addedDate'],
    );
  }
}


class DBStatusDTO {
  final String statusName;
  final String other1;
  final int candidateId;
  final int userId;

  DBStatusDTO({
    required this.statusName,
    required this.other1,
    required this.candidateId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'statusName': statusName,
      'other1': other1,
      'candidateId': candidateId,
      'userId': userId,
    };
  }
}
