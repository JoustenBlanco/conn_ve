import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging _fcm = FirebaseMessaging.instance;

Future<bool> updateTokenFCM() async {
  String? token = await _fcm.getToken();
  
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return false;
  if (token == null) return false;
  final res = await Supabase.instance.client.functions.invoke(
    'uptdate-token-FCM',
    body: {
      'user_id': session.user.id,
      'tokenFCM': token
    },
  );

  if (res.data is! Map<String, dynamic>) return false;

  final json = res.data as Map<String, dynamic>;

  return json['success'] == true;
}

Future<bool> deleteTokenFCM() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return false;
  final res = await Supabase.instance.client.functions.invoke(
    'uptdate-token-FCM',
    body: {
      'user_id': session.user.id
    },
  );

  if (res.data is! Map<String, dynamic>) return false;

  final json = res.data as Map<String, dynamic>;

  return json['success'] == true;
}