class Contact {
  final int? id;
  final String name;
  final String phone;
  final int synced;
  final int isDeleted;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.synced = 0,
    this.isDeleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'synced': synced,
      'isDeleted': isDeleted,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      synced: map['synced'],
      isDeleted: map['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}
