enum UserEnum {
  id("id"),
  name("name"),
  contact("contact"),
  role("role");

  final String value;
  const UserEnum(this.value);
}

class UserEntity {
  final String id; // firebase auth id
  final String name;
  final Map<String, dynamic> contact;
  final String role;

  UserEntity({required this.id, required this.name, required this.contact, required this.role});

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map[UserEnum.id.value],
      name: map[UserEnum.name.value],
      contact: map[UserEnum.contact.value] as Map<String, dynamic>? ?? {},
      role: map[UserEnum.role.value],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserEnum.id.value: id,
      UserEnum.name.value: name,
      UserEnum.contact.value: contact,
      UserEnum.role.value: role,
    };
  }
}
