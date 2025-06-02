import '../services/database_service.dart';
import '../services/api_service.dart';

class SyncRepository {
  static Future<void> syncContacts() async {
    final contacts = await DatabaseService.getUnsyncedContacts();
    for (var contact in contacts) {
      final success = await ApiService.sendContact(contact);
      if (success) {
        await DatabaseService.markAsSynced(contact.id!);
      }
    }
  }
}
