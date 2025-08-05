import 'dart:async';
import 'package:amtnew/core/features/auth/auth_provider.dart';
import 'package:amtnew/core/features/profile/profile_provider.dart';
import 'package:amtnew/widgets/Snackbars/dismissed_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/router/app_router.dart';
import '../../../core/utils/app_validators.dart';
import '../../../widgets/Constants/auth_constants.dart';
import '../../../widgets/TextFields/auth_text_field.dart';
import 'auth_container.dart';
class OtpPage extends StatefulWidget {
  final bool flag;
  const OtpPage({super.key, this.flag = false});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final emailFieldKey = GlobalKey<FormFieldState>();
  final otpFieldKey = GlobalKey<FormFieldState>();

  late final ValueNotifier<int> countdownNotifier;
  Timer? _timer;
  bool isSent = false;

  @override
  void initState() {
    super.initState();
    countdownNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    countdownNotifier.dispose();
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    countdownNotifier.value = 90;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownNotifier.value <= 1) {
        timer.cancel();
        countdownNotifier.value = 0;
      } else {
        countdownNotifier.value -= 1;
      }
    });
  }

  Future<void> _sendOrVerifyOtp(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    if (!formKey.currentState!.validate() || authState.isLoading) return;

    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    bool res = false;

    if (!isSent) {
      res = await authNotifier.loginWithOtp(email);
      if (!res) {
        showSingleSnackBar(message: authState.error ?? "Failed to send OTP");
        return;
      }
      setState(() => isSent = true);
      _startTimer();
      showSingleSnackBar(message: 'OTP sent to $email');
      return;
    }

    res = await authNotifier.verifyOtp(email, otp);
    if (!res) {
      showSingleSnackBar(message: authState.error ?? 'Failed to verify OTP');
      return;
    }

    ref.read(passwordResetCompletedProvider.notifier).state = widget.flag;

    if (!widget.flag) {
      final profile = ref.read(profileNotifierProvider).profile;
      showSingleSnackBar(message: "Welcome Back! ${profile?.username}");
    }
    debugPrint("OTP verified");
  }

  Future<void> _resendOtp(BuildContext context, WidgetRef ref) async {
    final email = emailController.text.trim();
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    final res = await authNotifier.loginWithOtp(email);
    if (!res) {
      showSingleSnackBar(message: authState.error ?? "Failed to resend OTP");
      return;
    }

    _startTimer();
    showSingleSnackBar(message: "OTP sent to $email");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authNotifierProvider);

        return AuthContainer(
          title: widget.flag ? "Forgot Password" : "Login With OTP",
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Image.asset(
                  kImagePathAsset,
                  width: kImageSize,
                  height: kImageSize,
                  fit: BoxFit.contain,
                ),
                AuthCustomTextFormField(
                  label: "Email",
                  keyField: emailFieldKey,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                ),
                if (isSent) ...[
                  const SizedBox(height: kBetweenTextFieldsPadding),
                  AuthCustomTextFormField(
                    label: "Enter OTP",
                    keyField: otpFieldKey,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    validator: AppValidators.validateOtp,
                    inputters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: ValueChangeNotifierButton(
                      countdownNotifier: countdownNotifier,
                      onPressed: () => _resendOtp(context, ref),
                      buttonText: "Resend",
                      countdownTextBuilder: (s) =>
                      "Resend in ${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}",
                    ),
                  ),
                ],
                const SizedBox(height: kOtpButtonTopMargin),
                ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => _sendOrVerifyOtp(context, ref),
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : Text(isSent ? "Verify OTP" : "Send OTP"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class ValueChangeNotifierButton extends StatelessWidget {
  final ValueNotifier<int> countdownNotifier;
  final VoidCallback onPressed;
  final String buttonText;
  final String Function(int remainingSeconds) countdownTextBuilder;

  const ValueChangeNotifierButton({
    super.key,
    required this.countdownNotifier,
    required this.onPressed,
    required this.buttonText,
    required this.countdownTextBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: countdownNotifier,
      builder: (_, secondsLeft, __) {
        final isEnabled = secondsLeft == 0;
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          child: Text(
            isEnabled ? buttonText : countdownTextBuilder(secondsLeft),
          ),
        );
      },
    );
  }
}
