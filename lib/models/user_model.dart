class UserModel {
  final String id;
  final String name;
  final String email;
  final String? livello;
  final Map<String, bool> badges;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.livello,
    required this.badges
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      livello: data['livello'],
      badges: Map<String, bool>.from(data['badges'] ?? {}),
    );
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      livello: map['livello'],
      badges: Map<String, bool>.from(map['badges'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'livello': livello,
      'badges': badges,
    };
  }
}