

import 'package:amtnew/core/config/router/app_router.dart';
import 'package:amtnew/core/utils/app_validators.dart';
import 'package:amtnew/core/features/auth/auth_provider.dart';
import 'package:amtnew/widgets/TextFields/auth_text_field.dart';
import 'package:amtnew/widgets/animated_size.dart' show AnimatedSizeContainer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';




class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _psdKey = GlobalKey<FormFieldState>();
  final _conPsdKey = GlobalKey<FormFieldState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _resetButton() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(_confirmPasswordController.text.trim());

    if (!response) {
      debugPrint(ref.read(authNotifierProvider).error.toString());
      return;
    }

    Navigator.of(context).pop();  // Close the sheet
    ref.read(passwordResetCompletedProvider.notifier).state = false;

    _showSnackBar("Password updated");
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return AnimatedSizeContainer(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AuthCustomTextFormField(
              label: "New Password",
              keyField: _psdKey,
              controller: _newPasswordController,
              obscure: true,
              validator: AppValidators.validatePassword,
            ),
            const SizedBox(height: 16),
            AuthCustomTextFormField(
              label: "Confirm Password",
              keyField: _conPsdKey,
              controller: _confirmPasswordController,
              obscure: true,
              validator: (value) => AppValidators.validateConfirmPassword(
                  value, _newPasswordController.text),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _resetButton,
              child: authState.isLoading
                  ? const CircularProgressIndicator()
                  : Text(authState.error != null ? "Retry" : 'Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
