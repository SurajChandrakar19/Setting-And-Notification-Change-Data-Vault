class CandidateCreateResponse {
  final bool success;
  final String message;
  final String candidateName;
  final String candidateEmail;
  final String candidatePhone;
  final String candidateRole;
  final String candidateLocation;
  final String candidateQualification;
  final String candidateExperience;
  final int candidateAge;
  final bool isActiveCandidate;
  final String status;
  final String interviewTime;
  final String interviewLocation;
  final String interviewNotes;
  final String interviewType;
  final String interviewStatus;
  final bool hasResume;
  final String resumeFileName;
  final String resumeFileType;
  final String resumeDownloadUrl;
  final int companyId;
  final String companyName;
  final String createdAt;

  CandidateCreateResponse({
    required this.success,
    required this.message,
    required this.candidateName,
    required this.candidateEmail,
    required this.candidatePhone,
    required this.candidateRole,
    required this.candidateLocation,
    required this.candidateQualification,
    required this.candidateExperience,
    required this.candidateAge,
    required this.isActiveCandidate,
    required this.status,
    required this.interviewTime,
    required this.interviewLocation,
    required this.interviewNotes,
    required this.interviewType,
    required this.interviewStatus,
    required this.hasResume,
    required this.resumeFileName,
    required this.resumeFileType,
    required this.resumeDownloadUrl,
    required this.companyId,
    required this.companyName,
    required this.createdAt,
  });

  factory CandidateCreateResponse.fromJson(Map<String, dynamic> json) {
    return CandidateCreateResponse(
      success: json['success'] ?? false, // Default to false if null
      message: json['message'] ?? '', // Empty string if null
      candidateName: json['candidateName'] ?? '', // Empty string if null
      candidateEmail: json['candidateEmail'] ?? '', // Empty string if null
      candidatePhone: json['candidatePhone'] ?? '', // Empty string if null
      candidateRole: json['candidateRole'] ?? '', // Empty string if null
      candidateLocation: json['candidateLocation'] ?? '', // Empty string if null
      candidateQualification: json['candidateQualification'] ?? '', // Empty string if null
      candidateExperience: json['candidateExperience'] ?? '', // Empty string if null
      candidateAge: json['candidateAge'] ?? 0, // Default to 0 if null
      isActiveCandidate: json['isActiveCandidate'] ?? false, // Default to false if null
      status: json['status'] ?? '', // Empty string if null
      interviewTime: json['interviewTime'] ?? '', // Empty string if null
      interviewLocation: json['interviewLocation'] ?? '', // Empty string if null
      interviewNotes: json['interviewNotes'] ?? '', // Empty string if null
      interviewType: json['interviewType'] ?? '', // Empty string if null
      interviewStatus: json['interviewStatus'] ?? '', // Empty string if null
      hasResume: json['hasResume'] ?? false, // Default to false if null
      resumeFileName: json['resumeFileName'] ?? '', // Empty string if null
      resumeFileType: json['resumeFileType'] ?? '', // Empty string if null
      resumeDownloadUrl: json['resumeDownloadUrl'] ?? '', // Empty string if null
      companyId: json['companyId'] ?? 0, // Default to 0 if null
      companyName: json['companyName'] ?? '', // Empty string if null
      createdAt: json['createdAt'] ?? '', // Empty string if null
    );
  }
}
