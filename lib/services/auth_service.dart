import 'package:supabase_flutter/supabase_flutter.dart';

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

Future<bool> verifyOTP(String otp) async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) throw Exception('No existe una session.');
  final res = await Supabase.instance.client.functions.invoke(
    'verify-otp',
    body: {
      'user_id': session.user.id,
      'otp': otp,
    },
  );

  final json = res.data as Map<String, dynamic>;

  return json['success'] == true;
}

Future<void> sendOTP() async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) throw Exception('No existe una session.');
  await Supabase.instance.client.functions.invoke('send-otp', body: {
    'email': session.user.email,
    'user_id': session.user.id,
  });
}