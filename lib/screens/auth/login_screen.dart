import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_button.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passworldController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _handleLogin() async {
    if(!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final auth = context.read<AuthService>();
    final error = await auth.login(_emailController.text.trim(), _passworldController.text);

    if(!mounted) return;
    setState(() => _isLoading = false);

    if(error != null) {
      setState(() => _errorText = error);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 40),
                    Text('Welcome back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text('Login to ${AppConstants.appName}', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passworldController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                    ),
                    if(_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorText!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    CommonButton(label: 'Login', isLoading: _isLoading, onPressed: _handleLogin),
                    const SizedBox(height: 12),
                    CommonButton(
                      label: 'Create Account',
                      outlined: true,
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterScreen())),
                    ),
                  ],
                ),
            ),
          ),
      ),
    );
  }
}