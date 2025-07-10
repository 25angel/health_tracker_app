import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Получаем текущего пользователя
  User? get currentUser => _auth.currentUser;

  // Регистрация с email и паролем
  Future<String?> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Вход с email и паролем
  Future<String?> loginWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Вход с Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user?.uid;
    } catch (e) {
      return e.toString();
    }
  }

  // Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Получаем данные пользователя
  Future<Map<String, String>> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      String email = user.email ?? 'No email';
      String displayName = user.displayName ?? 'No name';

      return {'uid': uid, 'email': email, 'displayName': displayName};
    }
    return {};
  }
}
