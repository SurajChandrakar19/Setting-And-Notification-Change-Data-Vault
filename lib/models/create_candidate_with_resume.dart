class CandidateCreateWithResumeDTO {
  String name;
  String phone;
  String role;
  String location;
  String qualification;
  String experience;
  int age;
  bool isActiveCandidate;
  String email;
  String interviewTime;
  String interviewLocation;
  String interviewNotes;
  String interviewType;
  int companyId;
  String companyName;
  String resumeFileName;
  String resumeFileType;
  int createdByUserId;
  String createdByUserName;
  String status;

  CandidateCreateWithResumeDTO({
    required this.name,
    required this.phone,
    this.role = '',
    this.location = '',
    this.qualification = '',
    this.experience = '',
    this.age = 0,
    this.isActiveCandidate = true,
    this.email = '',
    this.interviewTime = '',
    this.interviewLocation = '',
    this.interviewNotes = '',
    this.interviewType = 'IN_PERSON',
    this.companyId = 0,
    this.companyName = '',
    this.resumeFileName = '',
    this.resumeFileType = '',
    this.createdByUserId = 0,
    this.createdByUserName = '',
    this.status = 'PENDING',
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "role": role,
    "location": location,
    "qualification": qualification,
    "experience": experience,
    "age": age,
    "isActiveCandidate": isActiveCandidate,
    "email": email,
    "interviewTime": interviewTime,
    "interviewLocation": interviewLocation,
    "interviewNotes": interviewNotes,
    "interviewType": interviewType,
    "companyId": companyId,
    "companyName": companyName,
    "resumeFileName": resumeFileName,
    "resumeFileType": resumeFileType,
    "createdByUserId": createdByUserId,
    "createdByUserName": createdByUserName,
    "status": status,
  };
}
