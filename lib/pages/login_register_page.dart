import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  bool loading = false;

  Future<void> handleLoginOrRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final nombre = nombreController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && nombre.isEmpty)) return;

    setState(() => loading = true);

    try {
      if (isLogin) {
        // Login
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        // Registro
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        final userId = res.user?.id;
        if (userId != null) {
          await Supabase.instance.client.from('usuarios').insert({
            'id': userId,
            'nombre': nombre,
            'correo': email,
          });
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Iniciar sesión' : 'Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : handleLoginOrRegister,
              child: Text(loading
                  ? 'Procesando...'
                  : (isLogin ? 'Iniciar sesión' : 'Registrarse')),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin
                  ? '¿No tenés cuenta? Registrate'
                  : '¿Ya tenés cuenta? Iniciá sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
