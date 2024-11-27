// auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vendredi/app/data/model/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      this.user.value = user;
    });
    super.onInit();
  }

  String generateEmail(String firstName, String lastName) {
    firstName = firstName.trim().toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '')
        .replaceAll(' ', '');
    lastName = lastName.trim().toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '')
        .replaceAll(' ', '');
    
    return '$firstName$lastName@gmail.com';
  }

  Future<bool> emailExists(String email) async {
    try {
      // ignore: deprecated_member_use
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de l\'email: $e');
      return false;
    }
  }

  Future<String> generateUniqueEmail(String firstName, String lastName) async {
    String baseEmail = generateEmail(firstName, lastName);
    String email = baseEmail;
    int counter = 1;

    while (await emailExists(email)) {
      email = baseEmail.replaceAll('@gmail.com', '$counter@gmail.com');
      counter++;
    }

    return email;
  }

  Future<UserCredential?> registerWithEmailPassword({
    required String firstName,
    required String lastName,
    required String phone,
    required String type,
  }) async {
    try {
      final email = await generateUniqueEmail(firstName, lastName);
      final password = '${firstName.toLowerCase()}${lastName.toLowerCase()}123!';

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          type: type,
          solde: 0,
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());
        
        // Envoyer un email avec les identifiants
        await userCredential.user!.sendEmailVerification();

        return userCredential;
      }
      return null;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  Future<UserCredential?> registerWithGoogle({
    required String firstName,
    required String lastName,
    required String phone,
    required String type,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: userCredential.user!.email!,
          phone: phone,
          type: type,
          solde: 0,
        );

        await _firestore.collection('users').doc(user.id).set(user.toJson());
      }

      return userCredential;
    } catch (e) {
      print('Erreur lors de l\'inscription avec Google: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Vérifier si l'utilisateur existe dans Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Compte non trouvé. Veuillez vous inscrire.');
      }

      return userCredential;
    } catch (e) {
      print('Erreur de connexion Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

