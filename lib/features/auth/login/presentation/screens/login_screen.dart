import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/features/auth/create_account/presentation/models/create_account_arguments.dart';
import 'package:wirasasa/features/auth/otp/presentation/models/otp_screen_arguments.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0x1407B53B),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.headlineLarge,
                      children: const [
                        TextSpan(
                          text: 'WIRA',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'SASA',
                          style: TextStyle(color: AppColors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 38),
            Text('How it works', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 18),
            const _StepTile(index: '1', label: 'Select a service category'),
            const _StepTile(
              index: '2',
              label: 'View available professionals on the map',
            ),
            const _StepTile(
              index: '3',
              label: 'Choose based on location, rating, and price',
            ),
            const _StepTile(index: '4', label: 'Request service instantly'),
            const SizedBox(height: 36),
            Text(
              'Enter Email Address or Username',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 22),
            _AuthField(
              controller: _identifierController,
              label: 'Email address Or Username',
              hintText: 'Enter email or Address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _AuthField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Enter password',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 70,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _openTokenDeliveryOptions,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isSubmitting ? 'Sending Token...' : 'Send Token',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.forgotPassword),
                child: const Text(
                  'Forgot password',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'New here? ',
                  style: TextStyle(color: AppColors.muted, fontSize: 16),
                ),
                GestureDetector(
                  onTap: _openCreateAccount,
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTokenDeliveryOptions() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      _showMessage('Enter email address or username.');
      return;
    }

    final channel = await showDialog<_OtpDeliveryChannel>(
      context: context,
      builder: (context) => const _OtpDeliveryDialog(),
    );
    if (channel == null || !mounted) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final challenge = await ref
          .read(authApiProvider)
          .sendOtp(
            identifier: identifier,
            channel: channel.name,
            requestedRole: 'client',
          );
      if (!mounted) {
        return;
      }
      Navigator.pushNamed(
        context,
        AppRouter.otp,
        arguments: OtpScreenArguments(
          challengeId: challenge.challengeId,
          phoneNumber: challenge.phoneNumber,
          identifier: identifier,
          channel: challenge.channel ?? channel.name,
          requestedRole: 'client',
          devOtpCode: challenge.devOtpCode,
          maskedDestination: challenge.maskedDestination,
        ),
      );
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _openCreateAccount({String? prefilledPhone}) async {
    final result = await Navigator.pushNamed(
      context,
      AppRouter.createAccount,
      arguments: CreateAccountArguments(phoneNumber: prefilledPhone),
    );
    if (result is String) {
      _identifierController.text = result;
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _OtpDeliveryChannel {
  sms('SMS'),
  email('email');

  const _OtpDeliveryChannel(this.label);

  final String label;
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.index, required this.label});

  final String index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              index,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
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
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}

class _OtpDeliveryDialog extends StatefulWidget {
  const _OtpDeliveryDialog();

  @override
  State<_OtpDeliveryDialog> createState() => _OtpDeliveryDialogState();
}

class _OtpDeliveryDialogState extends State<_OtpDeliveryDialog> {
  _OtpDeliveryChannel _selectedChannel = _OtpDeliveryChannel.email;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select how you would like to receive the Login Otp.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _DeliveryOptionTile(
              label: 'Send via Sms',
              value: _OtpDeliveryChannel.sms,
              groupValue: _selectedChannel,
              onChanged: _setSelectedChannel,
            ),
            const Divider(height: 1),
            _DeliveryOptionTile(
              label: 'Send via email',
              value: _OtpDeliveryChannel.email,
              groupValue: _selectedChannel,
              onChanged: _setSelectedChannel,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _selectedChannel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setSelectedChannel(_OtpDeliveryChannel? value) {
    if (value == null) {
      return;
    }
    setState(() => _selectedChannel = value);
  }
}

class _DeliveryOptionTile extends StatelessWidget {
  const _DeliveryOptionTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final _OtpDeliveryChannel value;
  final _OtpDeliveryChannel groupValue;
  final ValueChanged<_OtpDeliveryChannel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: Icon(
        value == groupValue
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: value == groupValue ? AppColors.green : AppColors.muted,
      ),
      onTap: () => onChanged(value),
    );
  }
}
