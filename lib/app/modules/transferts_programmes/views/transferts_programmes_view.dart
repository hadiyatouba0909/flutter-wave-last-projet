// scheduled_transfer_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendredi/app/modules/transferts_programmes/controllers/transferts_programmes_controller.dart';

class ScheduledTransferView extends GetView<TransfertsProgrammesController> {
  const ScheduledTransferView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferts Programmés'),
        backgroundColor: const Color(0xFFE91E63),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Color(0xFFE91E63),
              tabs: [
                Tab(text: 'Nouveau Transfert'),
                Tab(text: 'Transferts Actifs'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildNewTransferForm(context),
                  _buildScheduledTransfersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTransferForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _showContactPicker(context),
            child: TextField(
              controller: controller.phoneController,
              enabled: true, // Permettre la saisie manuelle
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.contact_phone),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: controller.selectedFrequency.value,
            decoration: const InputDecoration(
              labelText: 'Fréquence',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
              DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
              DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
            ],
            onChanged: (value) => controller.selectedFrequency.value = value!,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      controller.selectedDate.value = date;
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Obx(() => Text(
                    'Date: ${controller.selectedDate.value.day}/'
                    '${controller.selectedDate.value.month}/'
                    '${controller.selectedDate.value.year}',
                  )),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: controller.selectedTime.value,
                    );
                    if (time != null) {
                      controller.selectedTime.value = time;
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Obx(() => Text(
                    'Heure: ${controller.selectedTime.value.format(context)}',
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value 
              ? null 
              : controller.scheduleTransfer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Programmer le transfert'),
          )),
        ],
      ),
    );
  }

// scheduled_transfer_view.dart (suite)
  Widget _buildScheduledTransfersList() {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.scheduledTransfers.length,
      itemBuilder: (context, index) {
        final transfer = controller.scheduledTransfers[index];
        final nextExecution = (transfer['nextExecution'] as Timestamp).toDate();
        final scheduledTime = TimeOfDay(
          hour: transfer['scheduledTime']['hour'],
          minute: transfer['scheduledTime']['minute'],
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vers: ${transfer['receiverPhone']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Annuler'),
                          onTap: () => controller.cancelTransfer(transfer['id']),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Montant: ${transfer['amount']} F',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fréquence: ${_getFrequencyText(transfer['frequency'])}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Heure programmée: ${scheduledTime.format(context)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prochaine exécution: ${_formatDate(nextExecution)}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (transfer['description'] != null && transfer['description'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${transfer['description']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ));
  }

  void _showContactPicker(BuildContext context) async {
  }

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Quotidien';
      case 'weekly':
        return 'Hebdomadaire';
      case 'monthly':
        return 'Mensuel';
      default:
        return frequency;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} à '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}