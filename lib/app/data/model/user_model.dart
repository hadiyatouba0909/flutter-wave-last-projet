// user_model.dart
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String type;
  final double solde;
  final double limit;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.type,
    this.solde = 20000.0,
    this.limit = 200000.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'type': type,
    'solde': solde,
    'limit': limit,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    email: json['email'],
    phone: json['phone'],
    type: json['type'],
    solde: json['solde']?.toDouble() ?? 20000.0,
    limit: json['limit']?.toDouble() ?? 200000.0,
  );
}