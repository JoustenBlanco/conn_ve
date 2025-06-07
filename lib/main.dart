import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:conn_ve/pages/login_register_page.dart';
import 'package:conn_ve/services/auth_service.dart';
import 'package:conn_ve/pages/home_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // Inicializar FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Pedir permiso en iOS (en Android normalmente se habilita por defecto)
  await messaging.requestPermission();
  // Obtener token del dispositivo
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  await Supabase.initialize(
    url: 'https://wwjvnuopafqmvsolrofm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3anZudW9wYWZxbXZzb2xyb2ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3NjczMjEsImV4cCI6MjA2MDM0MzMyMX0.v4CNGHBsa7sB_4FIMomytTYW-cVIEmsh-KIVbTC1Z1g',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Vehículos Eléctricos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SessionRedirector(),
    );
  }
}



class SessionRedirector extends StatefulWidget {
  const SessionRedirector({super.key});

  @override
  State<SessionRedirector> createState() => _SessionRedirectorState();
}

class _SessionRedirectorState extends State<SessionRedirector> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _navigating = false; // Para evitar múltiples navegaciones

  @override
  void initState() {
    super.initState();
    print("Estamos en el SessionRedirector");
    // Escuchar cambios de sesión
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (_navigating) return;
      final session = data.session;
      print("Escuchando cambios de sesión: $session");
      if (session != null) {
        await Future.delayed(Duration(seconds: 1)); 
        print('Sesión activa, redirigiendo al home o crear perfil');
        bool hasProfile = false;
        try {
          hasProfile = await userHasProfile();
        } catch (e) {
          print('Error en userHasProfile: $e');
        }
        if (!mounted) return;
        if (hasProfile) {
          print('Ya había un perfil en authSubscription, redirigiendo al home');
          _navigating = true;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        } else {
          print('No había un perfil en authSubscription, cerrando sesión y redirigiendo al login/registro');
          await Supabase.instance.client.auth.signOut();
          _navigating = true;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginRegisterPage()));
        }
      } else {
        print('No hay sesión activa en authSubscription, redirigiendo al login');
        _navigating = true;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginRegisterPage()));
      }
    });

    // Chequear si ya había una sesión activa al inicio
    final currentSession = Supabase.instance.client.auth.currentSession;
    print("Chequear si ya había una sesión activa al inicio: Sesión actual: $currentSession");
    if (currentSession != null) {
      print('Ya había una sesión activa al inicio');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_navigating) return;
        bool hasProfile = false;
        try {
          hasProfile = await userHasProfile();
        } catch (e) {
          print('Error en userHasProfile: $e');
        }
        if (!mounted) return;
        if (hasProfile) {
          print('Ya había un perfil, redirigiendo al home');
          _navigating = true;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        } else {
          print('No había un perfil, cerrando sesión y redirigiendo al login/registro');
          await Supabase.instance.client.auth.signOut();
          _navigating = true;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginRegisterPage()));
        }
      });
    } else {
      print('No hay sesión activa en el currentSession, redirigiendo al login');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_navigating) return;
        _navigating = true;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginRegisterPage()));
      });
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
