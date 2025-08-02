class GoForInterviewResponse {
  final int id;
  final int userId;
  final int candidateId;
  final String userName;
  final String candidateName;
  final String role;
  final DateTime addedDateTime;

  GoForInterviewResponse({
    required this.id,
    required this.userId,
    required this.candidateId,
    required this.userName,
    required this.candidateName,
    required this.role,
    required this.addedDateTime,
  });

  factory GoForInterviewResponse.fromJson(Map<String, dynamic> json) {
    return GoForInterviewResponse(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      candidateId: json['candidateId'] ?? 0,
      userName: json['userName'] ?? '',
      candidateName: json['candidateName'] ?? '',
      role: json['role'] ?? '',
      addedDateTime: json['addedDateTime'] != null
          ? DateTime.parse(json['addedDateTime'])
          : DateTime.now(), // fallback
    );
  }
}
