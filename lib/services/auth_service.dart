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
