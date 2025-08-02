class RescheduleCandidateDTO {
  final int? jobId;
  final String? notes;
  final String interviewTime;

  RescheduleCandidateDTO({
    this.jobId,
    this.notes,
    required this.interviewTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'notes': notes,
      'interviewTime': interviewTime,
    };
  }
}
