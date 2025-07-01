class UserModel {
  final String id;
  final String name;
  final String email;
  final Map<String, bool> badges;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.badges
  });

  // Factory constructor per creare UserModel da Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      badges: Map<String, bool>.from(data['badges'] ?? {}),
    );
  }

  // Factory constructor esistente (corretto)
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      badges: Map<String, bool>.from(map['badges'] ?? {}), // Corretto: era 'data' invece di 'map'
    );
  }

  // Metodo per convertire in Map (aggiornato per includere badges)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'badges': badges,
    };
  }
}