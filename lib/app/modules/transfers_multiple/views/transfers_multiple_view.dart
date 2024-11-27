// Dans lib/app/modules/transfers_multiple/views/transfers_multiple_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import '../controllers/transfers_multiple_controller.dart';

class TransfersMultipleView extends GetView<TransfersMultipleController> {
  const TransfersMultipleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferts Multiples'),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.transfers.length,
                itemBuilder: (context, index) => _buildTransferCard(context, index),
              )),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: controller.addNewTransfer,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un transfert'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE91E63),
                  ),
                ),
                Obx(() => Text(
                  'Total: ${controller.getTotalAmount()} F',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.makeTransfers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Effectuer les transferts',
                    style: TextStyle(fontSize: 16),
                  ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transfert ${index + 1}'),
                if (controller.transfers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => controller.removeTransfer(index),
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showContactPicker(context, index),
              child: TextField(
                controller: controller.transfers[index]['phoneController'],
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un contact',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.contact_phone),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.transfers[index]['amountController'],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactPicker(BuildContext context, int index) async {
    final contact = await showModalBottomSheet<Contact>(
      context: context,
      builder: (context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Sélectionner un contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.contacts.length,
              itemBuilder: (context, contactIndex) {
                final contact = controller.contacts[contactIndex];
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
            )),
          ),
        ],
      ),
    );

    if (contact != null) {
      controller.onContactSelected(index, contact);
    }
  }
}