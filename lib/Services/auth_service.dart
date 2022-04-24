import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Stream<User?> get userid => FirebaseAuth.instance.idTokenChanges();
  Stream<User?> get user => FirebaseAuth.instance.authStateChanges();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

//  Future googleSignIn() {}
  Future register(
      {required String email,
      required String password,
      required String username,
      String? photoURL}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      user?.updateDisplayName(username);
      user?.updatePhotoURL(photoURL);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
