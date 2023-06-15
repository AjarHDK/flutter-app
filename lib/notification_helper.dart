import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static List<NotificationModel> receivedNotifications = [];

  static const String savedNotificationsKey = 'saved_notifications';

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> _selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
  }

  static Future<void> checkProductQuantity() async {
    final orpc = Auth.orpc;

    try {
      final response = await orpc?.callKw({
        'model': 'stock.warehouse.orderpoint',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'qty_on_hand',
            'product_min_qty',
            'product_id',
            'location_id',
            'qty_on_hand',
            'qty_to_order',
          ],
        },
      });

      if (response != null && response is List<dynamic>) {
        print(response);
        List<dynamic> orderPoints = response;
        for (var orderPoint in orderPoints) {
          double qtyOnHandDouble =
              double.parse(orderPoint['qty_on_hand'].toString());
          double productMinQtyDouble =
              double.parse(orderPoint['product_min_qty'].toString());
          String productName = orderPoint['product_id'][1].toString();

          String emplacement = orderPoint['location_id'][1].toString();

          int qtyOnHand = qtyOnHandDouble.toInt();
          int productMinQty = productMinQtyDouble.toInt();
          String title;
          String body;

          if (qtyOnHand < productMinQty) {
            title = 'Rupture de stock -  $productName';
            body =
                'une rupture de stock a été identifiée pour $productName dans votre inventaire au niveau de l\'emplacement $emplacement';

            NotificationModel notification = NotificationModel(
              title: title,
              body: body,
              timestamp: DateTime.now(),
            );

            receivedNotifications.add(notification);
            showNotification(title, body);
          }
        }

        // Save the notifications
        await saveNotifications(receivedNotifications);
      } else {
        print('Invalid or unexpected response: $response');
      }
    } catch (e) {
      print('Error fetching order points: $e');
    }
  }

  static Future<void> showNotification(String title, String body) async {
    int notificationId = receivedNotifications
        .length; // Use the length of receivedNotifications as the unique identifier
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  static Future<void> saveNotifications(
    List<NotificationModel> notifications,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> encodedNotifications =
          notifications.map((n) => _encodeNotification(n)).toList();
      await prefs.setStringList(savedNotificationsKey, encodedNotifications);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  static Future<List<NotificationModel>> getSavedNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? encodedNotifications =
          prefs.getStringList(savedNotificationsKey);
      if (encodedNotifications != null) {
        List<NotificationModel> notifications =
            encodedNotifications.map((e) => _decodeNotification(e)).toList();
        return notifications;
      }
    } catch (e) {
      print('Error retrieving saved notifications: $e');
    }
    return [];
  }

  static String _encodeNotification(NotificationModel notification) {
    Map<String, dynamic> map = {
      'title': notification.title,
      'body': notification.body,
      'time': notification.timestamp.millisecondsSinceEpoch,
    };
    return jsonEncode(map);
  }

  static NotificationModel _decodeNotification(String encodedNotification) {
    Map<String, dynamic> map = jsonDecode(encodedNotification);
    String title = map['title'];
    String body = map['body'];
    int timestampInMillis = map['time'];
    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(timestampInMillis);
    return NotificationModel(title: title, body: body, timestamp: timestamp);
  }
}

class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel(
      {required this.title, required this.body, required this.timestamp});
}
