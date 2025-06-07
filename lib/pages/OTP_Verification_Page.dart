import 'package:conn_ve/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:conn_ve/pages/home_page.dart';
import '../shared/styles/app_colors.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({Key? key}) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final otpController = TextEditingController();
  bool loading = false;
  bool resending = false;

  Future<void> verify() async {
    final enteredOtp = otpController.text.trim();

    setState(() => loading = true);

    if (await verifyOTP(enteredOtp)) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código incorrecto o expirado.')),
      );
    }

    setState(() => loading = false);
  }

  Future<void> resend() async {
    setState(() => resending = true);
    try {
      await sendOTP();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código reenviado al correo.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reenviar: ${e.toString()}')),
      );
    } finally {
      setState(() => resending = false);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.darkCard.withOpacity(0.98),
          elevation: 0,
          title: Text('Verificar OTP', style: AppTextStyles.title),
          centerTitle: true,
          shadowColor: AppColors.purplePrimary.withOpacity(0.12),
          iconTheme: const IconThemeData(color: AppColors.purpleAccent),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              decoration: AppDecorations.card(opacity: 0.97),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Introduce el código enviado a tu correo',
                    style: AppTextStyles.subtitle.copyWith(color: AppColors.purpleAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.cardContent.copyWith(color: AppColors.textColor),
                    decoration: InputDecoration(
                      labelText: 'Ingrese el código OTP',
                      labelStyle: AppTextStyles.subtitle.copyWith(color: AppColors.purpleAccent),
                      filled: true,
                      fillColor: AppColors.darkBg.withOpacity(0.85),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purplePrimary,
                        foregroundColor: AppColors.textColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: AppTextStyles.title.copyWith(fontSize: 18),
                        elevation: 8,
                        shadowColor: AppColors.purpleAccent.withOpacity(0.22),
                      ),
                      onPressed: loading ? null : verify,
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verificar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.purpleAccent,
                        textStyle: AppTextStyles.subtitle.copyWith(decoration: TextDecoration.underline),
                      ),
                      onPressed: resending ? null : resend,
                      child: resending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.purpleAccent,
                              ),
                            )
                          : const Text('Reenviar código'),
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
