import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<bool> userHasProfile() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  print('userHasProfile: userId: $userId');
  if (userId == null) return false;

  final res = await Supabase.instance.client
      .from('usuarios')
      .select()
      .eq('id', userId)
      .maybeSingle();

  print('userHasProfile: resultado de consulta: $res');
  return res != null;
}

Future<bool> registerUser(String userId, String name, String email,) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) throw Exception('No existe una session.');
  final res = await Supabase.instance.client.functions.invoke(
    'register-user',
    body: {
      'id': userId,
      'nombre': name,
      'correo': email,
      'tokenFCM': token
    },
  );

  if (res.data is! Map<String, dynamic>) return false;

  final json = res.data as Map<String, dynamic>;

  return json['success'] == true;
}

Future<bool> verifyOTP(String otp, email) async {
  final res = await Supabase.instance.client.functions.invoke(
    'verify-otp',
    body: {
      'email': email,
      'otp': otp,
    },
  );

  if (res.data is! Map<String, dynamic>) return false;
  
  final json = res.data as Map<String, dynamic>;

  return json['success'] == true;
}

Future<void> sendOTP(email) async {
  await Supabase.instance.client.functions.invoke('send-otp', body: {
    'email': email,
  });
}