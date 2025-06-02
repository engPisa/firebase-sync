import 'package:firebase_database/firebase_database.dart';
import '../models/contato.dart';

class FirebaseService {
  static final _database = FirebaseDatabase.instance.ref('contacts');

  static Future<bool> saveContact(Contact contact) async {
    try {
      await _database.push().set({
        'name': contact.name,
        'phone': contact.phone,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Erro ao salvar no Firebase: $e');
      return false;
    }
  }
}
