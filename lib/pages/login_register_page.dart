import 'package:conn_ve/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:conn_ve/pages/OTP_Verification_Page.dart';
import 'package:conn_ve/shared/styles/app_colors.dart';
import 'package:conn_ve/shared/styles/app_text_styles.dart';
import 'package:conn_ve/shared/styles/app_decorations.dart';
import 'package:conn_ve/shared/styles/app_constants.dart';

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
  final confirmPasswordController = TextEditingController();
  String? confirmPasswordError;

  Future<void> handleLoginOrRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final nombre = nombreController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validación de campos vacíos
    if (email.isEmpty ||
        password.isEmpty ||
        (!isLogin && nombre.isEmpty) ||
        (!isLogin && confirmPassword.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      setState(() {
        confirmPasswordError = null;
      });
      return;
    }

    // Validación de formato de email
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un correo electrónico válido.')),
      );
      setState(() {
        confirmPasswordError = null;
      });
      return;
    }

    // Validación de confirmación de contraseña
    if (!isLogin && password != confirmPassword) {
      setState(() {
        confirmPasswordError = 'Las contraseñas no coinciden';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    } else {
      setState(() {
        confirmPasswordError = null;
      });
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
        if (res.user == null) throw Exception('No se logro procesar el registro.');
        registerUser(res.user!.id,nombre,email);
      }
      // Limpiar campos después de éxito
      emailController.clear();
      passwordController.clear();
      nombreController.clear();
      confirmPasswordController.clear();
      // Proceso de OTP
      sendOTP();

      // Navegar a pantalla de verificación
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(),
        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Otros errores
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: [${e.toString()}')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.backgroundGradient,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.cardPaddingHorizontal,
                vertical: AppConstants.cardPaddingVertical,
              ),
              decoration: AppDecorations.card(opacity: 0.96),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Icono musical
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: AppDecorations.iconCircle,
                    padding: const EdgeInsets.all(AppConstants.iconPadding),
                    child: Icon(
                      Icons.electric_car_rounded,
                      color: AppColors.textColor,
                      size: AppConstants.iconSize,
                    ),
                  ),
                  Text(
                    isLogin ? '¡Bienvenido de nuevo!' : 'Crea tu cuenta',
                    style: AppTextStyles.welcome.copyWith(fontSize: 28, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLogin
                        ? 'Inicia sesión para continuar'
                        : 'Regístrate para empezar',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 32),
                  if (!isLogin)
                    TextField(
                      controller: nombreController,
                      style: TextStyle(color: AppColors.textColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBg,
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: AppColors.hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.purplePrimary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.purpleAccent, width: 2),
                        ),
                      ),
                    ),
                  if (!isLogin) const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBg,
                      labelText: 'Correo',
                      labelStyle: TextStyle(color: AppColors.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.purplePrimary, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.purpleAccent, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBg,
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: AppColors.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.purplePrimary, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.purpleAccent, width: 2),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  // Confirmar contraseña solo en registro
                  if (!isLogin)
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: AppColors.textColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBg,
                        labelText: 'Confirmar contraseña',
                        labelStyle: TextStyle(color: AppColors.hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.purplePrimary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.purpleAccent, width: 2),
                        ),
                        errorText: confirmPasswordError,
                      ),
                    ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: loading ? null : handleLoginOrRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purplePrimary,
                        foregroundColor: AppColors.textColor,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      child:
                          loading
                              ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 3,
                                ),
                              )
                              : Text(
                                isLogin ? 'Iniciar sesión' : 'Registrarse',
                              ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed:
                        loading
                            ? null
                            : () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                    child: Text(
                      isLogin
                          ? '¿No tenés cuenta? Registrate'
                          : '¿Ya tenés cuenta? Iniciá sesión',
                      style: AppTextStyles.cardContent.copyWith(
                        color: AppColors.purpleAccent,
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
