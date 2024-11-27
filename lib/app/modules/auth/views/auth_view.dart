// auth_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Vendredi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              const SizedBox(height: 40),
              Obx(() => controller.isRegistering.value
                ? _buildRegistrationForm()
                : _buildLoginForm()),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => controller.toggleRegistering(),
                child: Text(
                  controller.isRegistering.value
                    ? 'Déjà un compte ? Se connecter'
                    : 'Pas de compte ? S\'inscrire',
                  style: const TextStyle(color: Color(0xFFE91E63)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        TextField(
          onChanged: (value) => controller.firstName.value = value,
          decoration: const InputDecoration(
            labelText: 'Prénom',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => controller.lastName.value = value,
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => controller.phone.value = value,
          decoration: const InputDecoration(
            labelText: 'Téléphone',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Obx(() => DropdownButton<String>(
            value: controller.type.value,
            isExpanded: true,
            underline: Container(),
            items: ['client', 'distributeur'].map((type) => 
              DropdownMenuItem(
                value: type,
                child: Text(type.capitalizeFirst!),
              )
            ).toList(),
            onChanged: (value) => controller.type.value = value!,
          )),
        ),
        const SizedBox(height: 24),
        _buildRegisterButtons(),
      ],
    );
  }

  Widget _buildRegisterButtons() {
    return Column(
      children: [
        Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.register,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'S\'inscrire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        )),
        const SizedBox(height: 16),
        const Text('OU', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        _buildGoogleButton(
          'S\'inscrire avec Google',
          controller.registerWithGoogle,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return _buildGoogleButton(
      'Se connecter avec Google',
      controller.signInWithGoogle,
    );
  }

  Widget _buildGoogleButton(String text, VoidCallback onPressed) {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: controller.isLoading.value
        ? const CircularProgressIndicator(color: Colors.white)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/google_logo.png',
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
    ));
  }
}