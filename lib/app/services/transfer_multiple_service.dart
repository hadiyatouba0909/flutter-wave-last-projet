// transfer_multiple_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class TransfersMultipleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String normalizePhoneNumber(String phone) {
    // Enlever tous les caractères non numériques
    String normalized = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si le numéro commence par 221, enlever le 221
    if (normalized.startsWith('221')) {
      normalized = normalized.substring(3);
    }
    
    // Vérifier si c'est un numéro sénégalais valide (70, 75, 76, 77, 78)
    if (normalized.length == 9 && normalized.startsWith(RegExp(r'7[0-8]'))) {
      return normalized;
    }
    
    return normalized;
  }

  Future<Map<String, dynamic>> makeMultipleTransfers({
    required List<Map<String, dynamic>> transfers,
    String? description,
  }) async {
    try {
      final String senderId = _auth.currentUser!.uid;

      // Calculer le montant total nécessaire
      double totalAmount = transfers.fold(0, (sum, transfer) => sum + (transfer['amount'] as double));

      // Vérifier le solde de l'expéditeur
      final senderDoc = await _firestore.collection('users').doc(senderId).get();
      if (!senderDoc.exists) {
        return {'success': false, 'message': 'Compte expéditeur non trouvé'};
      }
      
      final senderSolde = (senderDoc.data()!['solde'] ?? 0.0).toDouble();

      if (senderSolde < totalAmount) {
        return {
          'success': false,
          'message': 'Solde insuffisant pour effectuer tous les transferts'
        };
      }

      // Vérifier et préparer tous les destinataires
      List<Map<String, dynamic>> validatedTransfers = [];
      for (var transfer in transfers) {
        final String phoneNumber = normalizePhoneNumber(transfer['phoneNumber']);
        print('Recherche pour le numéro normalisé: $phoneNumber'); // Debug

        // Vérifier si c'est un numéro valide
        if (!RegExp(r'^7[0-8]\d{7}$').hasMatch(phoneNumber)) {
          return {
            'success': false,
            'message': 'Numéro invalide: ${transfer['phoneNumber']}. Veuillez entrer un numéro sénégalais valide.',
          };
        }

        // Rechercher le destinataire
        final receiverQuery = await _firestore
            .collection('users')
            .where('phone', isEqualTo: phoneNumber)
            .get();

        if (receiverQuery.docs.isEmpty) {
          return {
            'success': false,
            'message': 'Numéro non trouvé: ${transfer['phoneNumber']}'
          };
        }

        // Vérifier que ce n'est pas un transfert vers soi-même
        if (receiverQuery.docs.first.id == senderId) {
          return {
            'success': false,
            'message': 'Impossible de transférer vers votre propre numéro: ${transfer['phoneNumber']}'
          };
        }

        validatedTransfers.add({
          ...transfer,
          'receiverId': receiverQuery.docs.first.id,
          'normalizedPhone': phoneNumber,
        });
      }

      // Exécuter tous les transferts dans une seule transaction
      await _firestore.runTransaction((transaction) async {
        // Mettre à jour le solde de l'expéditeur
        transaction.update(
          _firestore.collection('users').doc(senderId),
          {'solde': senderSolde - totalAmount}
        );

        // Effectuer chaque transfert
        for (var transfer in validatedTransfers) {
          final receiverDoc = await transaction.get(
            _firestore.collection('users').doc(transfer['receiverId'])
          );
          
          final double receiverSolde = (receiverDoc.data()!['solde'] ?? 0.0).toDouble();
          
          transaction.update(
            receiverDoc.reference,
            {'solde': receiverSolde + transfer['amount']}
          );

          // Créer l'entrée de transaction
          transaction.set(
            _firestore.collection('transactions').doc(),
            {
              'senderId': senderId,
              'receiverId': transfer['receiverId'],
              'amount': transfer['amount'],
              'type': 'transfer',
              'timestamp': FieldValue.serverTimestamp(),
              'description': description ?? 'Transfert multiple',
              'status': 'completed',
            },
          );
        }
      });

      return {
        'success': true,
        'message': 'Tous les transferts ont été effectués avec succès'
      };
    } catch (e) {
      print('Erreur détaillée: $e'); // Debug
      String message = 'Une erreur est survenue lors des transferts';
      if (e.toString().contains('Solde insuffisant')) {
        message = 'Solde insuffisant pour effectuer ces transferts';
      }
      return {'success': false, 'message': message};
    }
  }

  Future<List<Contact>> getContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        print('Permission des contacts accordée'); // Debug
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        print('Nombre de contacts chargés: ${contacts.length}'); // Debug
        return contacts;
      } else {
        print('Permission des contacts refusée'); // Debug
        return [];
      }
    } catch (e) {
      print('Erreur lors du chargement des contacts: $e'); // Debug
      return [];
    }
  }
}