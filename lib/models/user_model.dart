class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen
});

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
        id: id,
        name: map['name'] ?? 'Unknown',
        email: map['email'] ?? '',
        photoUrl: map['photoUrl'],
        isOnline: map['isOnline'] ?? false,
        lastSeen: map['lastSeen'] != null
             ? DateTime.tryParse(map['lastSeen'].toString())
             : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}