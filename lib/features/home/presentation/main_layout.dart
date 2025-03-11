import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pedidos/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_cubit.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_state.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              title: const Text('Stock'),
              onTap: () => context.go('/stock'),
            ),
            ListTile(
              title: const Text('Refill'),
              onTap: () => context.go('/refill'),
            ),
            ListTile(
              title: const Text('Transfers'),
              onTap: () => context.go('/transfers'),
            ),
            const Divider(),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                context.read<AuthCubit>().signOut();

                // Reset POS and any other state
                context.read<PosCubit>().emit(PosInitial());

                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
