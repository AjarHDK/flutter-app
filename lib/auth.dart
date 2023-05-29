import 'package:odoo_rpc/odoo_rpc.dart';

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
}
