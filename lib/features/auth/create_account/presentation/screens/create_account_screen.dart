import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/features/auth/create_account/presentation/models/create_account_arguments.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key, this.arguments});

  final CreateAccountArguments? arguments;

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  late final TextEditingController _phoneController;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.arguments?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Create your account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          _AppField(
            controller: _phoneController,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _AppField(controller: _firstNameController, label: 'First Name'),
          const SizedBox(height: 14),
          _AppField(controller: _lastNameController, label: 'Last Name'),
          const SizedBox(height: 14),
          _AppField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _AppField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _createAccount,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isSubmitting ? 'Creating Account...' : 'Create Account',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    final phoneNumber = _normalizePhone(_phoneController.text);
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (phoneNumber == null) {
      _showMessage('Enter a valid phone number.');
      return;
    }
    if (firstName.isEmpty || lastName.isEmpty) {
      _showMessage('Enter first name and last name.');
      return;
    }
    if (!email.contains('@')) {
      _showMessage('Enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authApiProvider).registerAccount(
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            requestedRole: 'client',
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created. Sign in to request your OTP code.'),
        ),
      );
      Navigator.pop(context, phoneNumber);
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _AppField extends StatelessWidget {
  const _AppField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

String? _normalizePhone(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) {
    return null;
  }
  if (digits.startsWith('254') && digits.length == 12) {
    return '+$digits';
  }
  if (digits.startsWith('0') && digits.length == 10) {
    return '+254${digits.substring(1)}';
  }
  if (digits.length == 9) {
    return '+254$digits';
  }
  return null;
}
