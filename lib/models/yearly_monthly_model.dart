class YearlyStatsModel {
  final int year;
  final int targetCount;
  final int joiningCandidateCount;
  final int goForInterviewCount;
  final int selectedCandidateCount;

  YearlyStatsModel({
    required this.year,
    required this.targetCount,
    required this.joiningCandidateCount,
    required this.goForInterviewCount,
    required this.selectedCandidateCount,
  });

  factory YearlyStatsModel.fromJson(Map<String, dynamic> json) {
    return YearlyStatsModel(
      year: json['year'],
      targetCount: json['targetCount'],
      joiningCandidateCount: json['joiningCandidateCount'],
      goForInterviewCount: json['goForInterviewCount'],
      selectedCandidateCount: json['selectedCandidateCount'],
    );
  }
}
