import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  transfer,
  deposit,
  withdrawal,
  unlimit,
}

class TransactionModel {
  final String? id;
  final String? senderId;
  final String? receiverId;
  final double amount;
  final TransactionType type;
  final DateTime? timestamp;
  final String? description;
  final DateTime? scheduledDate;
  final String status;
  final Map<String, dynamic> metadata;

  TransactionModel({
    this.id,
    this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.timestamp,
    this.description,
    this.scheduledDate,
    required this.status,
    this.metadata = const {},
  });

  // Factory pour construire un modèle à partir d'un JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString(),
      senderId: json['senderId']?.toString(),
      receiverId: json['receiverId']?.toString(),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      type: _parseTransactionType(json['type']),
      timestamp: _parseTimestamp(json['timestamp']),
      description: json['description']?.toString(),
      scheduledDate: _parseTimestamp(json['scheduledDate']),
      status: json['status']?.toString() ?? '',
      metadata: _parseMetadata(json['metadata']),
    );
  }

  // Méthode pour convertir un modèle en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': _convertTransactionTypeToString(type),
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'description': description,
      'scheduledDate':
          scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'status': status,
      'metadata': metadata,
    };
  }

  // Parse le type de transaction depuis une valeur dynamique
  static TransactionType _parseTransactionType(dynamic typeValue) {
    if (typeValue == null) return TransactionType.transfer;

    String typeString = typeValue.toString().toLowerCase();
    switch (typeString) {
      case 'transfer':
        return TransactionType.transfer;
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'unlimit':
        return TransactionType.unlimit;
      default:
        return TransactionType.transfer; // Valeur par défaut
    }
  }

  // Convertit l'enum en chaîne de caractères de manière sécurisée
  static String _convertTransactionTypeToString(TransactionType type) {
    return type.toString().split('.').last;
  }

  // Méthode utilitaire pour parser les timestamps
  static DateTime? _parseTimestamp(dynamic timestampValue) {
    if (timestampValue == null) return null;

    if (timestampValue is Timestamp) {
      return timestampValue.toDate();
    }

    try {
      return DateTime.parse(timestampValue.toString());
    } catch (_) {
      return null;
    }
  }

  // Méthode utilitaire pour parser les métadonnées
  static Map<String, dynamic> _parseMetadata(dynamic metadataValue) {
    if (metadataValue == null) return {};

    if (metadataValue is Map) {
      return Map<String, dynamic>.from(metadataValue);
    }

    return {};
  }

  String getTypeString() {
    return type.toString().split('.').last;
  }
}
