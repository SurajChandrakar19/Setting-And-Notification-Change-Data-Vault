class CompanyIdName {
  final int id;
  final String companyName;
  final String jobTitle;
  final String location;

  CompanyIdName({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.location,
  });

  factory CompanyIdName.fromJson(Map<String, dynamic> json) {
    return CompanyIdName(
      id: json['id'],
      companyName: json['companyName'],
      jobTitle: json['jobTitle'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'location': location,
    };
  }
}
