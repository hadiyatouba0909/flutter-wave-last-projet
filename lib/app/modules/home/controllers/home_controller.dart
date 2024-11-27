// home_controller.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final solde = 0.0.obs;
  final isSoldeLoading = true.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final isTransactionsLoading = true.obs;

  // Streams subscriptions pour le nettoyage
  StreamSubscription<DocumentSnapshot>? _soldeSubscription;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  void initializeData() {
    loadUserSolde();
    setupSoldeListener();
    loadTransactions();
  }

  Future<void> loadUserSolde() async {
    try {
      isSoldeLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          solde.value = (userDoc.data()?['solde'] ?? 0.0).toDouble();
        }
      }
    } catch (e) {
      print('Erreur lors du chargement du solde: $e');
    } finally {
      isSoldeLoading.value = false;
    }
  }

  void setupSoldeListener() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _soldeSubscription = _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen(
        (document) {
          if (document.exists) {
            solde.value = (document.data()?['solde'] ?? 0.0).toDouble();
          }
        },
        onError: (error) {
          print('Erreur dans le listener du solde: $error');
        },
      );
    }
  }

  Future<void> loadTransactions() async {
    try {
      isTransactionsLoading.value = true;
      final userId = _auth.currentUser?.uid;

      if (userId != null) {
        final transactionsQuery = await _firestore
            .collection('transactions')
            .where(Filter.or(
              Filter('senderId', isEqualTo: userId),
              Filter('receiverId', isEqualTo: userId),
            ))
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        final List<Map<String, dynamic>> transactionsList = [];

        for (var doc in transactionsQuery.docs) {
          final data = doc.data();
          final isSender = data['senderId'] == userId;

          // Récupérer les informations de l'autre partie
          final otherUserId = isSender ? data['receiverId'] : data['senderId'];
          final otherUserDoc = await _firestore
              .collection('users')
              .doc(otherUserId)
              .get();
          
          final otherUserData = otherUserDoc.data();

          // Formater la date
          final timestamp = (data['timestamp'] as Timestamp).toDate();
          final formattedDate = DateFormat('dd MMM', 'fr_FR').format(timestamp);

          transactionsList.add({
            ...data,
            'id': doc.id,
            'isReceived': !isSender,
            'otherUserName': '${otherUserData?['firstName'] ?? ''} ${otherUserData?['lastName'] ?? ''}',
            'formattedDate': formattedDate,
            'formattedAmount': '${isSender ? "-" : ""}${data['amount']}F',
          });
        }

        transactions.value = transactionsList;
      }
    } catch (e) {
      print('Erreur lors du chargement des transactions: $e');
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadUserSolde();
    await loadTransactions();
  }

  String getFormattedSolde() {
    return '${solde.value.toStringAsFixed(0)}F';
  }

  @override
  void onClose() {
    _soldeSubscription?.cancel();
    super.onClose();
  }
}