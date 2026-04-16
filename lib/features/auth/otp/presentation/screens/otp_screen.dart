import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirasasa/app/app_providers.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/config/app_env.dart';
import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/theme/app_colors.dart';
import 'package:wirasasa/features/auth/otp/presentation/models/otp_screen_arguments.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.arguments});

  final OtpScreenArguments? arguments;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.arguments;
    final theme = Theme.of(context);
    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('OTP challenge was not provided.')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
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
                  const Spacer(),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.green,
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Text('Verify your OTP', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(
                'Enter the code sent to ${args.destination}',
                style: const TextStyle(color: AppColors.muted, fontSize: 16),
              ),
              if (AppEnv.showDevOtp && args.devOtpCode != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Dev OTP: ${args.devOtpCode}',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 36),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'OTP code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : () => _verify(args),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isSubmitting ? 'Verifying...' : 'Verify',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => _resend(args),
                    child: const Text(
                      'Resend code',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Change destination',
                      style: TextStyle(
                        color: AppColors.slate,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify(OtpScreenArguments args) async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showMessage('Enter the OTP code.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final session = await ref
          .read(authApiProvider)
          .verifyOtp(
            challengeId: args.challengeId,
            code: code,
            requestedRole: args.requestedRole,
            displayName: args.displayName,
          );
      ref.read(authSessionProvider.notifier).setSession(session);
      if (!mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.shell,
        (route) => false,
      );
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _resend(OtpScreenArguments args) async {
    try {
      final challenge = await ref
          .read(authApiProvider)
          .sendOtp(
            identifier: args.identifier,
            channel: args.channel,
            requestedRole: args.requestedRole,
          );
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(
        context,
        AppRouter.otp,
        arguments: OtpScreenArguments(
          challengeId: challenge.challengeId,
          phoneNumber: challenge.phoneNumber,
          identifier: args.identifier,
          channel: challenge.channel ?? args.channel,
          requestedRole: args.requestedRole,
          displayName: args.displayName,
          devOtpCode: challenge.devOtpCode,
          maskedDestination: challenge.maskedDestination,
        ),
      );
    } on ApiException catch (error) {
      _showMessage(error.message);
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
