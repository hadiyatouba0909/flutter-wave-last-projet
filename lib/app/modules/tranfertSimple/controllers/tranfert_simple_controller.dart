// transfer_simple_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:vendredi/app/services/transfer_simple_service.dart';

class TransferSimpleController extends GetxController {
  final TransferSimpleService _service = TransferSimpleService();
  final phoneNumber = ''.obs;
  final amount = 0.0.obs;
  final description = ''.obs;
  final isLoading = false.obs;
  final contacts = <Contact>[].obs;
  final selectedContact = Rxn<Contact>();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadContacts();
    phoneController.addListener(() {
      phoneNumber.value = phoneController.text;
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadContacts() async {
    try {
      // Demander la permission d'accéder aux contacts
      if (await FlutterContacts.requestPermission()) {
        // Charger tous les contacts avec leurs numéros de téléphone
        final loadedContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        // Filtrer pour ne garder que les contacts avec des numéros de téléphone
        contacts.value = loadedContacts
            .where((contact) => contact.phones.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('Erreur lors du chargement des contacts: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les contacts',
        backgroundColor: Colors.red[100],
      );
    }
  }

  Future<void> makeTransfer() async {
    if (phoneNumber.isEmpty || amount.value <= 0) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs correctement',
        backgroundColor: Colors.red[100],
      );
      return;
    }

    isLoading.value = true;
    try {
      // Normaliser le numéro avant l'envoi
      String normalizedNumber = _service.normalizePhoneNumber(phoneNumber.value);
      
      final result = await _service.makeTransfer(
        phoneNumber: normalizedNumber,
        amount: amount.value,
        description: description.value,
      );

      if (result['success']) {
        Get.back();
        Get.snackbar(
          'Succès',
          result['message'],
          backgroundColor: Colors.green[100],
        );
      } else {
        Get.snackbar(
          'Erreur',
          result['message'],
          backgroundColor: Colors.red[100],
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onContactSelected(Contact contact) {
    selectedContact.value = contact;
    String number = contact.phones.firstOrNull?.number ?? '';
    // Normaliser le numéro dès la sélection du contact
    String normalizedNumber = _service.normalizePhoneNumber(number);
    phoneController.text = normalizedNumber;
    phoneNumber.value = normalizedNumber;
  }
}

// transfer_simple_service.dart (modifications de la fonction normalizePhoneNumber)
String normalizePhoneNumber(String phone) {
  // Enlever tous les espaces, tirets et autres caractères spéciaux
  String normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
  
  // Si le numéro est vide après nettoyage
  if (normalized.isEmpty) {
    return '';
  }
  
  // Si le numéro commence par '00221', le convertir en '+221'
  if (normalized.startsWith('00221')) {
    normalized = '+221${normalized.substring(5)}';
  }
  
  // Si le numéro commence déjà par +221, on le garde tel quel
  if (normalized.startsWith('+221')) {
    return normalized;
  }
  
  // Si le numéro commence par 221, on ajoute le +
  if (normalized.startsWith('221')) {
    return '+$normalized';
  }
  
  // Si le numéro commence par 7x (70, 75, 76, 77, 78), on ajoute +221
  if (normalized.length == 9 && normalized.startsWith(RegExp(r'7[0-8]'))) {
    return '+221$normalized';
  }
  
  // Pour les numéros qui commencent déjà par un +
  if (normalized.startsWith('+')) {
    return normalized;
  }
  
  return normalized;
}