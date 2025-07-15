class UserModel {
  String uid;
  String name;
  String email;
  String address;
  String phone;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
    };
  }
}