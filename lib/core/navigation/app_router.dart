import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedidos/features/stock/presentation/pages/stock_page.dart';
import '../../login_page.dart';

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
          final userRole =
              state.extra as String? ?? "viewer"; // ✅ Get user role
          return StockPage(
            posId: 'beach_club',
            userRole: userRole,
          );
        },
      ),
      /*GoRoute(
        path: '/transactions/:stockId',
        builder: (context, state) {
          final stockId = state.pathParameters['stockId']!;
          return StockTransactionPage(
            stockId: stockId,
            posId: 'beach_club',
          );
        },
      ),*/
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
    ],
  );
}
