import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Текущий пользователь (если залогинен)
  User? get currentUser => _auth.currentUser;

  /// Стрим изменений авторизации (можно слушать в виджетах)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ЧИСТЫЙ signup: создаёт нового пользователя
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// ЧИСТЫЙ login: логинится с уже существующим аккаунтом
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
