// scheduled_transfer_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ScheduledTransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String normalizePhoneNumber(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (normalized.startsWith('221')) {
      normalized = normalized.substring(3);
    }
    
    if (normalized.length == 9 && normalized.startsWith(RegExp(r'7[0-8]'))) {
      return normalized;
    }
    
    return normalized;
  }

  Future<Map<String, dynamic>> scheduleTransfer({
    required String phoneNumber,
    required double amount,
    required DateTime startDate,
    required String frequency, // 'daily', 'weekly', 'monthly'
    required TimeOfDay scheduledTime,
    String? description,
  }) async {
    try {
      final String senderId = _auth.currentUser!.uid;
      final normalizedPhone = normalizePhoneNumber(phoneNumber);

      // Valider le format du numéro
      if (!RegExp(r'^7[0-8]\d{7}$').hasMatch(normalizedPhone)) {
        return {
          'success': false,
          'message': 'Format de numéro invalide'
        };
      }

      // Vérifier si le destinataire existe
      final receiverQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: normalizedPhone)
          .get();

      if (receiverQuery.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Numéro non trouvé dans la base de données'
        };
      }

      final receiverId = receiverQuery.docs.first.id;
      
      // Vérifier que ce n'est pas un transfert vers soi-même
      if (senderId == receiverId) {
        return {
          'success': false,
          'message': 'Impossible de programmer un transfert vers votre propre numéro'
        };
      }

      // Créer le transfert programmé
      await _firestore.collection('scheduled_transfers').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'receiverPhone': normalizedPhone,
        'amount': amount,
        'frequency': frequency,
        'startDate': Timestamp.fromDate(startDate),
        'scheduledTime': {
          'hour': scheduledTime.hour,
          'minute': scheduledTime.minute
        },
        'description': description,
        'status': 'active',
        'lastExecuted': null,
        'nextExecution': _calculateNextExecution(startDate, scheduledTime, frequency),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Transfert programmé avec succès'
      };
    } catch (e) {
      print('Erreur: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la programmation du transfert'
      };
    }
  }

  DateTime _calculateNextExecution(DateTime startDate, TimeOfDay scheduledTime, String frequency) {
    DateTime nextDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (nextDate.isBefore(DateTime.now())) {
      switch (frequency) {
        case 'daily':
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case 'weekly':
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case 'monthly':
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day, 
                            scheduledTime.hour, scheduledTime.minute);
          break;
      }
    }

    return nextDate;
  }

  Future<List<Map<String, dynamic>>> getScheduledTransfers() async {
    try {
      final userId = _auth.currentUser!.uid;
      final transfers = await _firestore
          .collection('scheduled_transfers')
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      return transfers.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      print('Erreur: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> cancelScheduledTransfer(String transferId) async {
    try {
      await _firestore
          .collection('scheduled_transfers')
          .doc(transferId)
          .update({'status': 'cancelled'});

      return {
        'success': true,
        'message': 'Transfert programmé annulé avec succès'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'annulation du transfert'
      };
    }
  }

  Future<List<Contact>> getContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        return await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
      }
    } catch (e) {
      print('Erreur lors du chargement des contacts: $e');
    }
    return [];
  }
}