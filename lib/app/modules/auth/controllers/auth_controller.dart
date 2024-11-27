// auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendredi/app/routes/app_pages.dart';
import 'package:vendredi/app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final firstName = ''.obs;
  final lastName = ''.obs;
  final phone = ''.obs;
  final type = 'client'.obs;
  final isLoading = false.obs;
  final isRegistering = false.obs;
  final isSoldeVisible = true.obs;

  void toggleRegistering() => isRegistering.value = !isRegistering.value;

  void toggleSoldeVisibility() {
    isSoldeVisible.value = !isSoldeVisible.value;
  }

  bool _validateFields() {
    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        backgroundColor: Colors.red[100],
      );
      return false;
    }
    return true;
  }

  Future<void> register() async {
    if (!_validateFields()) return;

    try {
      isLoading.value = true;
      final result = await _authService.registerWithEmailPassword(
        firstName: firstName.value,
        lastName: lastName.value,
        phone: phone.value,
        type: type.value,
      );

      if (result != null) {
        Get.snackbar(
          'Succès',
          'Compte créé avec succès! Vérifiez votre email pour le mot de passe.',
          backgroundColor: Colors.green[100],
        );
        Get.offAllNamed(
          type.value == 'client' ? Routes.HOME : Routes.DISTRIBUTEUR,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'inscription: ${e.toString()}',
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerWithGoogle() async {
    if (!_validateFields()) return;

    try {
      isLoading.value = true;
      final result = await _authService.registerWithGoogle(
        firstName: firstName.value,
        lastName: lastName.value,
        phone: phone.value,
        type: type.value,
      );

      if (result != null) {
        Get.offAllNamed(
          type.value == 'client' ? Routes.HOME : Routes.DISTRIBUTEUR,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'inscription avec Google',
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid)
            .get();
            
        final userType = userDoc.data()?['type'] ?? 'client';
        Get.offAllNamed(userType == 'client' ? Routes.HOME : Routes.DISTRIBUTEUR);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la connexion avec Google',
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la déconnexion',
        backgroundColor: Colors.red[100],
      );
    }
  }
}