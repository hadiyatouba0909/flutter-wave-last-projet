// transfer_simple_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:vendredi/app/modules/tranfertSimple/controllers/tranfert_simple_controller.dart';

class TransferSimpleView extends GetView<TransferSimpleController> {
  const TransferSimpleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert Simple'),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: () => _showContactPicker(context),
              child: TextField(
                controller: TextEditingController(
                  text: controller.selectedContact.value?.displayName ?? '',
                ),
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un contact (optionnel)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.contact_phone),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
                hintText: 'Entrez le numéro ou sélectionnez un contact',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => controller.amount.value = double.tryParse(value) ?? 0,
              decoration: const InputDecoration(
                labelText: 'Montant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 30),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.makeTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Effectuer le transfert',
                    style: TextStyle(fontSize: 16),
                  ),
            )),
          ],
        ),
      ),
    );
  }

  void _showContactPicker(BuildContext context) async {
    final contact = await showModalBottomSheet<Contact>(
      context: context,
      builder: (context) => Obx(() => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Sélectionnez un contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.contacts.length,
              itemBuilder: (context, index) {
                final contact = controller.contacts[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(contact.displayName),
                  subtitle: Text(
                    contact.phones.firstOrNull?.number ?? 'Pas de numéro',
                  ),
                  onTap: () => Navigator.pop(context, contact),
                );
              },
            ),
          ),
        ],
      )),
    );

    if (contact != null) {
      controller.onContactSelected(contact);
    }
  }
}