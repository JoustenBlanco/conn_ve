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

  // Validación de campos vacíos
  if (email.isEmpty || password.isEmpty || (!isLogin && nombre.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, complete todos los campos.')),
    );
    return;
  }

  // Validación de formato de email
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]');
  if (!emailRegex.hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ingrese un correo electrónico válido.')),
    );
    return;
  }

  setState(() => loading = true);

  try {
    if (isLogin) {
      // Login
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        throw Exception('Usuario o contraseña incorrectos.');
      }
    } else {
      // Registro
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      // Si ocurre un error, Supabase lanzará una excepción y saltará al catch.
      final userId = res.user?.id;
      if (userId != null) {
        await Supabase.instance.client.from('usuarios').insert({
          'id': userId,
          'nombre': nombre,
          'correo': email,
        });
      }
    }
    // Limpiar campos después de éxito
    emailController.clear();
    passwordController.clear();
    nombreController.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } on AuthException catch (e) {
    // Errores específicos de autenticación
    String message = 'Ocurrió un error de autenticación.';
    if (e.message.contains('Invalid login credentials')) {
      message = 'Usuario o contraseña incorrectos.';
    } else if (e.message.contains('already registered')) {
      message = 'El correo ya está registrado.';
    } else {
      message = e.message;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    // Otros errores
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color purplePrimary = const Color(0xFF7B1FA2);
    final Color purpleAccent = const Color(0xFFB388FF);
    final Color darkBg = const Color(0xFF18181A);
    final Color darkCard = const Color(0xFF23232B);
    final Color textColor = Colors.white;
    final Color hintColor = Colors.white70;

    return Scaffold(
      backgroundColor: darkBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFF18181A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(
                color: darkCard.withOpacity(0.96),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: purplePrimary.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Icono musical
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [purplePrimary, purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Icon(Icons.electric_car_rounded, color: Colors.white, size: 48),
                  ),
                  Text(
                    isLogin ? '¡Bienvenido de nuevo!' : 'Crea tu cuenta',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin ? 'Inicia sesión para continuar' : 'Regístrate para empezar',
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  if (!isLogin)
                    TextField(
                      controller: nombreController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: darkBg,
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: purplePrimary, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: purpleAccent, width: 2),
                        ),
                      ),
                    ),
                  if (!isLogin) const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: darkBg,
                      labelText: 'Correo',
                      labelStyle: TextStyle(color: hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: purplePrimary, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: purpleAccent, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: darkBg,
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: purplePrimary, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: purpleAccent, width: 2),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: loading ? null : handleLoginOrRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purplePrimary,
                        foregroundColor: textColor,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : Text(isLogin ? 'Iniciar sesión' : 'Registrarse'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                    child: Text(
                      isLogin ? '¿No tenés cuenta? Registrate' : '¿Ya tenés cuenta? Iniciá sesión',
                      style: TextStyle(
                        color: purpleAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
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
