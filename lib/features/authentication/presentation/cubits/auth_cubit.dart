import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthCubit({
    required this.auth,
    required this.firestore,
  }) : super(AuthInitial());

  /// ✅ Check if user is already logged in
  Future<void> checkAuthStatus() async {
    final user = auth.currentUser;
    if (user != null) {
      await _fetchUserRole(user);
    } else {
      emit(AuthUnauthenticated());
    }
  }

  /// ✅ Sign in user and fetch role
  Future<void> signIn(String email, String password) async {
    try {
      emit(AuthLoading());

      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fetchUserRole(userCredential.user);
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "Login failed"));
    }
  }

  /// ✅ Fetch user role from Firestore
  Future<void> _fetchUserRole(User? user) async {
    try {
      if (user != null) {
        final userDoc = await firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.data()!.containsKey('role')) {
          final String userRole = userDoc['role'];
          emit(AuthAuthenticated(userRole));
        } else {
          emit(AuthError("User role not found."));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError("Error fetching user role: $e"));
    }
  }

  /// ✅ Sign out user
  Future<void> signOut() async {
    await auth.signOut();
    emit(AuthUnauthenticated());
  }
}
