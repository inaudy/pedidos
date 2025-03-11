import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedidos/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:pedidos/features/authentication/presentation/cubits/auth_state.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_cubit.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_state.dart';
import 'package:pedidos/features/pos/presentation/pages/pos_selection_page.dart';
import 'package:pedidos/features/stock/presentation/pages/stock_page.dart';
import '../../features/authentication/presentation/login_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return '/login'; // ✅ Redirect to login if not authenticated
      }

      // ✅ Retrieve user role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userRole =
          userDoc.exists ? userDoc['role'] : "viewer"; // Default to viewer
      return null; // ✅ No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final authState = context.watch<AuthCubit>().state;
          final posState = context.watch<PosCubit>().state;

          if (authState is AuthAuthenticated) {
            if (posState is PosSelected) {
              return StockPage();
            } else {
              return PosSelectionPage(); // Go to POS selection if none is selected
            }
          } else if (authState is AuthUnauthenticated) {
            return const LoginPage();
          } else if (authState is AuthError) {
            return Center(child: Text("Error: ${authState.message}"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      /*GoRoute(
        path: '/stock',
        builder: (context, state) => StockPage(),
      ),*/
    ],
  );
}
