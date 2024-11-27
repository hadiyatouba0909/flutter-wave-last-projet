// scheduled_transfer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:vendredi/app/services/transferts_programmes.dart';

class TransfertsProgrammesController extends GetxController {
  final ScheduledTransferService _service = ScheduledTransferService();
  
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final selectedContact = Rxn<Contact>();
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedTime = Rx<TimeOfDay>(TimeOfDay.now());
  final selectedFrequency = RxString('daily');
  final contacts = <Contact>[].obs;
  final scheduledTransfers = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadContacts();
    loadScheduledTransfers();
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> loadContacts() async {
    contacts.value = await _service.getContacts();
  }

  Future<void> loadScheduledTransfers() async {
    scheduledTransfers.value = await _service.getScheduledTransfers();
  }

  Future<void> scheduleTransfer() async {
    if (phoneController.text.isEmpty || amountController.text.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs requis',
        backgroundColor: Colors.red[100],
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Erreur',
        'Montant invalide',
        backgroundColor: Colors.red[100],
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await _service.scheduleTransfer(
        phoneNumber: phoneController.text,
        amount: amount,
        startDate: selectedDate.value,
        frequency: selectedFrequency.value,
        scheduledTime: selectedTime.value,
        description: descriptionController.text,
      );

      if (result['success']) {
        Get.back();
        Get.snackbar(
          'Succès',
          result['message'],
          backgroundColor: Colors.green[100],
        );
        loadScheduledTransfers();
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

  Future<void> cancelTransfer(String transferId) async {
    try {
      final result = await _service.cancelScheduledTransfer(transferId);
      if (result['success']) {
        loadScheduledTransfers();
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
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        backgroundColor: Colors.red[100],
      );
    }
  }

  void onContactSelected(Contact contact) {
    selectedContact.value = contact;
    phoneController.text = contact.phones.firstOrNull?.number ?? '';
  }
}
