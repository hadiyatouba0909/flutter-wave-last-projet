//Système de transfert mis à jour

// transfer_simple_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// transfer_simple_service.dart
class TransferSimpleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String normalizePhoneNumber(String phone) {
    // Enlever tous les caractères non numériques
    String normalized = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si le numéro commence par 221, enlever le 221
    if (normalized.startsWith('221')) {
      normalized = normalized.substring(3);
    }
    
    // Si le numéro commence par +221, enlever le +221
    if (normalized.startsWith('221')) {
      normalized = normalized.substring(3);
    }
    
    // Vérifier si c'est un numéro sénégalais valide (70, 75, 76, 77, 78)
    if (normalized.length == 9 && 
        normalized.startsWith(RegExp(r'7[0-8]'))) {
      return normalized;  // Retourner juste les 9 chiffres
    }
    
    // Si le numéro est déjà dans le bon format (9 chiffres)
    if (normalized.length == 9 && 
        normalized.startsWith('7')) {
      return normalized;
    }
    
    return normalized;
  }

  Future<Map<String, dynamic>> makeTransfer({
    required String phoneNumber,
    required double amount,
    String? description,
  }) async {
    try {
      // Normaliser le numéro pour qu'il corresponde au format de la base de données
      final String normalizedPhone = normalizePhoneNumber(phoneNumber);
      print('Numéro à rechercher: $normalizedPhone'); // Debug
      
      // Vérifier si le numéro est dans un format valide
      if (!RegExp(r'^7[0-8]\d{7}$').hasMatch(normalizedPhone)) {
        return {
          'success': false,
          'message': 'Format de numéro invalide. Veuillez entrer un numéro sénégalais valide.',
        };
      }

      final String senderId = _auth.currentUser!.uid;

      // Rechercher l'utilisateur avec le numéro normalisé
      var receiverQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: normalizedPhone)
          .get();

      if (receiverQuery.docs.isEmpty) {
        print('Aucun utilisateur trouvé pour le numéro: $normalizedPhone'); // Debug
        return {
          'success': false,
          'message': 'Numéro de téléphone non trouvé dans la base de données.'
        };
      }

      final receiverId = receiverQuery.docs.first.id;
      
      // Vérifier si l'expéditeur essaie d'envoyer à lui-même
      if (senderId == receiverId) {
        return {
          'success': false,
          'message': 'Impossible de transférer vers votre propre numéro'
        };
      }

      // Effectuer le transfert
      await _firestore.runTransaction((transaction) async {
        final senderDoc = await transaction.get(_firestore.collection('users').doc(senderId));
        final receiverDoc = await transaction.get(_firestore.collection('users').doc(receiverId));

        if (!senderDoc.exists || !receiverDoc.exists) {
          throw Exception('Un des utilisateurs n\'existe pas');
        }

        final double senderSolde = (senderDoc.data()?['solde'] ?? 0.0).toDouble();
        final double receiverSolde = (receiverDoc.data()?['solde'] ?? 0.0).toDouble();

        if (senderSolde < amount) {
          throw Exception('Solde insuffisant');
        }

        transaction.update(senderDoc.reference, {'solde': senderSolde - amount});
        transaction.update(receiverDoc.reference, {'solde': receiverSolde + amount});
        
        // Ajouter la transaction dans l'historique
        transaction.set(
          _firestore.collection('transactions').doc(),
          {
            'senderId': senderId,
            'receiverId': receiverId,
            'amount': amount,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'transfer',
            'description': description,
            'status': 'completed',
          },
        );
      });

      return {'success': true, 'message': 'Transfert effectué avec succès'};
    } catch (e) {
      print('Erreur détaillée: $e'); // Debug
      String message = 'Erreur lors du transfert';
      if (e.toString().contains('Solde insuffisant')) {
        message = 'Solde insuffisant pour effectuer ce transfert';
      }
      return {'success': false, 'message': message};
    }
  }
}