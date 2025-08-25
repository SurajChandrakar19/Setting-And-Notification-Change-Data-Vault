class SimpleAdminDashboardSummary {
  final int userId;
  final String userName;
  final bool isAdmin;
  final int todayTotalGoForInterviewCount;
  final int todayTotalReachedCandidateCount;
  final int todayTotalTargetCandidateCount;
  final int currentMonthTotalTarget;
  final int currentMonthTotalAchieved;
  final double currentMonthProgressPercentage;
  final MonthData previousMonth;
  final MonthData currentMonth;
  final MonthData nextMonth;
  final String userRole;
  final String summaryMessage;

  SimpleAdminDashboardSummary({
    required this.userId,
    required this.userName,
    required this.isAdmin,
    required this.todayTotalGoForInterviewCount,
    required this.todayTotalReachedCandidateCount,
    required this.todayTotalTargetCandidateCount,
    required this.currentMonthTotalTarget,
    required this.currentMonthTotalAchieved,
    required this.currentMonthProgressPercentage,
    required this.previousMonth,
    required this.currentMonth,
    required this.nextMonth,
    required this.userRole,
    required this.summaryMessage,
  });

  factory SimpleAdminDashboardSummary.fromJson(Map<String, dynamic> json) {
    return SimpleAdminDashboardSummary(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      todayTotalGoForInterviewCount:
          json['todayGoForInterviewCount'] ??
          json['todayTotalGoForInterviewCount'] ??
          0,
      todayTotalTargetCandidateCount: json['todayTotalTarget'] ?? 0,
      todayTotalReachedCandidateCount:
          json['todayReachedCandidateCount'] ??
          json['todayTotalReachedCandidateCount'] ??
          0,
      currentMonthTotalTarget:
          json['currentMonthTarget'] ?? json['currentMonthTotalTarget'] ?? 0,
      currentMonthTotalAchieved:
          json['currentMonthAchieved'] ??
          json['currentMonthTotalAchieved'] ??
          0,
      currentMonthProgressPercentage:
          (json['currentMonthProgressPercentage'] ??
                  json['currentMonthTotalProgressPercentage'] ??
                  0.0)
              .toDouble(),
      previousMonth: MonthData.fromJson(json['previousMonth'] ?? {}),
      currentMonth: MonthData.fromJson(json['currentMonth'] ?? {}),
      nextMonth: MonthData.fromJson(json['nextMonth'] ?? {}),
      userRole: json['userRole'] ?? '',
      summaryMessage: json['summaryMessage'] ?? '',
    );
  }
}

class MonthData {
  final String monthName;
  final int monthNumber;
  final int year;
  final int totalTarget;
  final int totalAchieved;
  final double totalProgressPercentage;
  final String periodKey;

  MonthData({
    required this.monthName,
    required this.monthNumber,
    required this.year,
    required this.totalTarget,
    required this.totalAchieved,
    required this.totalProgressPercentage,
    required this.periodKey,
  });

  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      monthName: json['monthName'] ?? '',
      monthNumber: json['monthNumber'] ?? 0,
      year: json['year'] ?? 0,
      totalTarget: json['target'] ?? json['totalTarget'] ?? 0,
      totalAchieved: json['achieved'] ?? json['totalAchieved'] ?? 0,
      totalProgressPercentage:
          (json['progressPercentage'] ?? json['totalProgressPercentage'] ?? 0.0)
              .toDouble(),
      periodKey: json['periodKey'] ?? '',
    );
  }
}
