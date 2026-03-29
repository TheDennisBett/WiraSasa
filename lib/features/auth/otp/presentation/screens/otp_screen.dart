import 'package:flutter/material.dart';
import 'package:wirasasa/app/app_router.dart';
import 'package:wirasasa/core/theme/app_colors.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Text('Verify your number', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 10),
              const Text(
                'Enter the 6-digit code sent to 65636362727',
                style: TextStyle(color: AppColors.muted, fontSize: 16),
              ),
              const SizedBox(height: 36),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _OtpDigit(value: '1'),
                  _OtpDigit(value: '2'),
                  _OtpDigit(value: '3'),
                  _OtpDigit(value: '3'),
                  _OtpDigit(value: '4'),
                  _OtpDigit(value: '4', active: true),
                ],
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.shell,
                    (route) => false,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Row(
                children: [
                  Text(
                    'Resend code',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Change number',
                    style: TextStyle(
                      color: AppColors.slate,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}

class _OtpDigit extends StatelessWidget {
  const _OtpDigit({required this.value, this.active = false});

  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? Colors.black38 : Colors.transparent,
          width: active ? 2 : 1,
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}
