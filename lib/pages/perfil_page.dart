import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import 'login_register_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? nombre;
  String? correo;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Si no hay usuario, redirigir a login
      _goToLogin();
      return;
    }
    final userId = user.id;
    final data = await Supabase.instance.client
        .from('usuarios')
        .select('nombre, correo')
        .eq('id', userId)
        .single();
    setState(() {
      nombre = data['nombre'] ?? '';
      correo = data['correo'] ?? '';
      loading = false;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    _goToLogin();
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginRegisterPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        title: Text('Perfil', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: SafeArea(
          child: Center(
            child: loading
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar/Icono usuario
                        Container(
                          decoration: AppDecorations.iconCircle,
                          padding: const EdgeInsets.all(18),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: const Icon(
                            Icons.account_circle_rounded,
                            color: AppColors.textColor,
                            size: 90,
                          ),
                        ),
                        // Card de datos
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 28),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          decoration: AppDecorations.card(opacity: 0.97),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nombre', style: AppTextStyles.subtitle),
                              const SizedBox(height: 2),
                              Text(nombre ?? '', style: AppTextStyles.title.copyWith(fontSize: 20)),
                              const SizedBox(height: 18),
                              Text('Correo', style: AppTextStyles.subtitle),
                              const SizedBox(height: 2),
                              Text(correo ?? '', style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.purpleAccent)),
                              const SizedBox(height: 18),
                              Text('Contraseña', style: AppTextStyles.subtitle),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text('********', style: AppTextStyles.title.copyWith(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.lock, color: AppColors.hintColor, size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 44.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purplePrimary,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                textStyle: AppTextStyles.title.copyWith(fontSize: 18),
                                elevation: 8,
                                shadowColor: AppColors.purpleAccent.withOpacity(0.25),
                              ),
                              icon: const Icon(Icons.logout, size: 26),
                              label: const Text('Cerrar sesión'),
                              onPressed: _logout,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
