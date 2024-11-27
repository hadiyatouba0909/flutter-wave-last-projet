// Dans lib/app/modules/transfers_multiple/controllers/transfers_multiple_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:vendredi/app/services/transfer_multiple_service.dart';

class TransfersMultipleController extends GetxController {
  final TransfersMultipleService _service = TransfersMultipleService();
  final transfers = <Map<String, dynamic>>[].obs;
  final contacts = <Contact>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadContacts();
    addNewTransfer();
  }

  void addNewTransfer() {
    transfers.add({
      'phoneNumber': '',
      'amount': 0.0,
      'contact': Rxn<Contact>(),
      'phoneController': TextEditingController(),
      'amountController': TextEditingController(),
    });
  }

  void removeTransfer(int index) {
    if (transfers.length > 1) {
      final transfer = transfers[index];
      (transfer['phoneController'] as TextEditingController).dispose();
      (transfer['amountController'] as TextEditingController).dispose();
      transfers.removeAt(index);
    }
  }

  void onContactSelected(int index, Contact contact) {
    final transfer = transfers[index];
    transfer['contact'] = Rxn<Contact>(contact);
    final phone = contact.phones.firstOrNull?.number ?? '';
    transfer['phoneNumber'] = phone;
    (transfer['phoneController'] as TextEditingController).text = phone;
  }

  Future<void> loadContacts() async {
    contacts.value = await _service.getContacts();
  }

  double getTotalAmount() {
    return transfers.fold(0.0, (sum, transfer) => 
      sum + (double.tryParse(transfer['amountController'].text) ?? 0.0)
    );
  }

  Future<void> makeTransfers() async {
    if (transfers.isEmpty) {
      Get.snackbar('Erreur', 'Ajoutez au moins un transfert');
      return;
    }

    List<Map<String, dynamic>> preparedTransfers = [];
    for (var transfer in transfers) {
      final amount = double.tryParse(transfer['amountController'].text) ?? 0.0;
      final phone = transfer['phoneController'].text;

      if (phone.isEmpty || amount <= 0) {
        Get.snackbar(
          'Erreur',
          'Veuillez remplir correctement tous les champs',
          backgroundColor: Colors.red[100],
        );
        return;
      }

      preparedTransfers.add({
        'phoneNumber': phone,
        'amount': amount,
      });
    }

    isLoading.value = true;
    try {
      final result = await _service.makeMultipleTransfers(
        transfers: preparedTransfers,
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

  @override
  void onClose() {
    for (var transfer in transfers) {
      (transfer['phoneController'] as TextEditingController).dispose();
      (transfer['amountController'] as TextEditingController).dispose();
    }
    super.onClose();
  }
}