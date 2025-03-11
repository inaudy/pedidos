import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pedidos/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:pedidos/features/authentication/presentation/cubits/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void login(BuildContext context) async {
    setState(() => isLoading = true);
    await context.read<AuthCubit>().signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock App Login")),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (state.role == 'adm' || state.role == 'superuser') {
              context.go('/', extra: state.role);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Access denied: ${state.role}")),
              );
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => login(context),
                        child: const Text("Login"),
                      ),
                TextButton(
                  onPressed: () {
                    context.push('/register');
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
