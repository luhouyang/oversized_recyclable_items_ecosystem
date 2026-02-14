enum UserEnum {
  id("id"),
  name("name"),
  contact("contact"),
  role("role"),
  points("points");

  final String value;
  const UserEnum(this.value);
}

class UserEntity {
  final String id; // firebase auth id
  final String name;
  final Map<String, dynamic> contact;
  final String role;
  final int points; // Gamification points

  UserEntity({
    required this.id,
    required this.name,
    required this.contact,
    required this.role,
    this.points = 0,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map[UserEnum.id.value] ?? '',
      name: map[UserEnum.name.value] ?? 'Unknown',
      contact: map[UserEnum.contact.value] as Map<String, dynamic>? ?? {},
      role: map[UserEnum.role.value] ?? 'user',
      points: map[UserEnum.points.value] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserEnum.id.value: id,
      UserEnum.name.value: name,
      UserEnum.contact.value: contact,
      UserEnum.role.value: role,
      UserEnum.points.value: points,
    };
  }

  // Helper to get Level Name based on points
  String get levelName {
    if (points < 100) return "Seedling";
    if (points < 300) return "Sprout";
    if (points < 600) return "Sapling";
    if (points < 1000) return "Young Tree";
    return "Forest Guardian";
  }

  // Helper to get progress to next level
  double get levelProgress {
    if (points < 100) return points / 100;
    if (points < 300) return (points - 100) / 200;
    if (points < 600) return (points - 300) / 300;
    if (points < 1000) return (points - 600) / 400;
    return 1.0;
  }
}