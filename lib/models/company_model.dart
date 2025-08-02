class Company {
  final String id;
  final String name; // from companyName
  final String address; // from location

  Company({required this.id, required this.name, required this.address});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'].toString(), // convert Long to String
      name: json['companyName'] ?? '',
      address: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address};
  }

  // Empty company constructor (default values)
  factory Company.empty() {
    return Company(id: '', name: '', address: '');
  }
}
