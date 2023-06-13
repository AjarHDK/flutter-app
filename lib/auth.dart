import 'package:odoo_rpc/odoo_rpc.dart';
import 'notification_helper.dart';

class Auth {
  static OdooClient? orpc;

  static Future<void> authenticate(
    String url,
    String dbName,
    String user,
    String password,
  ) async {
    orpc = OdooClient(url);
    await orpc!.authenticate(dbName, user, password);
  }

  static Future<void> logout() async {
    await NotificationHelper.saveNotifications(
        NotificationHelper.receivedNotifications);

    // Perform the logout logic here
  }
}
