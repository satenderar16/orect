import 'dart:async';

import 'package:amtnew/core/utils/app_validators.dart';
import 'package:amtnew/core/features/auth/auth_provider.dart';
import 'package:amtnew/core/features/profile/profile_provider.dart';
import 'package:amtnew/Screens/Authentication/widget/auth_container.dart';
import 'package:amtnew/widgets/Snackbars/dismissed_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_enums.dart';
import 'registration_provider.dart';
import '../../../widgets/Constants/auth_constants.dart';
import '../../../widgets/TextFields/label_textform_field.dart';
import '../../../widgets/bottom_sheet/two_large_buttom.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationForm();
  }
}

class RegistrationForm extends ConsumerStatefulWidget {
  const RegistrationForm({super.key});

  @override
  ConsumerState<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends ConsumerState<RegistrationForm> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool?> _quiting() {
    return twoLargeButtonBottomSheet(
      context: context,
      title: "Cancel Registration",
      fillButtonText: "No",
      outlineButtonText: "Yes",
      subtitle: 'Exit registration? All data will be lost.',
      outlineOnPressed: () => Navigator.of(context).pop(true),
      fillOnPressed: () => Navigator.of(context).pop(false),
      isDismissible: false,
    );
  }

  void needPop() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationProvider);
    final registrationNotifier = ref.watch(registrationProvider.notifier);
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _quiting() ?? false;
        if (shouldPop) {
          needPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Registration"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: (_currentPage + 1) / _totalPages,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
          ),
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildPage(
              context,
              _PersonalForm(
                fullNameCtr: registration.fullNameCtr,
                phoneCtr: registration.phoneCtr,
                addressCtr: registration.addressCtr,
                emailCtr: registration.personalEmailCtr,
                onNext: _nextPage,
              ),
            ),
            _buildPage(
              context,
              _BusinessForm(
                key: ValueKey(
                  '${registration.useSameAddress}_${registration.usePersonalEmail}',
                ),
                bizNameCtr: registration.bizNameCtr,
                bizLocationCtr: registration.bizLocationCtr,
                bizEmailCtr: registration.bizEmailCtr,
                addressCtr: registration.addressCtr,
                personalEmailCtr: registration.personalEmailCtr,
                useSameAddress: registration.useSameAddress,
                usePersonalEmail: registration.usePersonalEmail,
                onBack: _prevPage,
                onNext: _nextPage,
                onToggleAddress:
                    (val) => registrationNotifier.toggleUseSameAddress(val),
                onToggleEmail:
                    (val) => registrationNotifier.toggleUsePersonalEmail(val),
              ),
            ),
            _buildPage(
              context,
              _CredentialsForm(
                otpCtr: registration.otpCtr,
                personalEmailCtr: registration.personalEmailCtr,
                bizEmailCtr: registration.bizEmailCtr,
                confirmEmailCtr: registration.confirmEmailCtr,
                passwordCtr: registration.passwordCtr,
                confirmPwdCtr: registration.confirmPwdCtr,
                emailType: registration.emailType,
                onEmailTypeChanged:
                    (val) => registrationNotifier.setEmailType(val),
                onBack: _prevPage,

                otpButton:
                    authState.isLoading
                        ? null
                        : () async {
                          if (!registration.useSendOtp) {
                            //sent otp
                            registrationNotifier.setSentOtp();
                            registrationNotifier.setProfile();
                            final response = await authNotifier.signUpWithOtp(
                              registration.confirmEmailCtr.text
                                  .trim()
                                  .toString(),
                            );
                            if (!response) {
                              showSingleSnackBar(
                                message:
                                    authState.error ?? "Failed to send OTP",
                              );
                              return;
                            }

                            showSingleSnackBar(
                              message:
                                  "Otp send to ${registration.confirmEmailCtr.text.trim().toString()}",
                            );
                            return;
                          }

                          //verify otp and move to next page:

                          debugPrint(
                            registration.profile?.toMapTem().toString(),
                          );
                          final response = await authNotifier.verifyOtpSignUp(
                            registration.confirmEmailCtr.text.trim().toString(),
                            registration.otpCtr.text.toString(),
                            registration.profile!,
                          );
                          if (!response) {
                            showSingleSnackBar(
                              message:
                                  authState.error ?? "OTP verification failed",
                            );
                            return;
                          }
                          showSingleSnackBar(message: "User Verified");

                          _nextPage();
                        },
              ),
            ),
            _buildPage(
              context,
              _PassWord(
                personalEmailCtr: registration.personalEmailCtr,
                bizEmailCtr: registration.bizEmailCtr,
                confirmEmailCtr: registration.confirmEmailCtr,
                passwordCtr: registration.passwordCtr,
                confirmPwdCtr: registration.confirmPwdCtr,
                onBack: () => authNotifier.setIsAuthentication(true),
                onFinish:
                    authState.isLoading
                        ? null
                        : () async {
                          final response = await authNotifier.resetPassword(
                            registration.confirmEmailCtr.text.trim().toString(),
                          );
                          if (!response) {
                            showSingleSnackBar(
                              message:
                                  authState.error ??
                                  "Oops! something went wrong, Try again",
                            );
                            return;
                          }
                          showSingleSnackBar(
                            message:
                                "Welcome!! ${ref.read(profileNotifierProvider).profile?.username}",
                          );
                        },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final contentWidth = isTablet ? 400.0 : constraints.maxWidth * 0.90;

        return Center(
          child: SizedBox(
            width: contentWidth,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kMainContainerPaddingHorizontal,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PersonalForm extends StatelessWidget {
  final TextEditingController fullNameCtr;
  final TextEditingController phoneCtr;
  final TextEditingController addressCtr;
  final TextEditingController emailCtr;
  final VoidCallback onNext;

  const _PersonalForm({
    required this.fullNameCtr,
    required this.phoneCtr,
    required this.addressCtr,
    required this.emailCtr,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameKey = GlobalKey<FormFieldState>();
    final phoneKey = GlobalKey<FormFieldState>();
    final addressKey = GlobalKey<FormFieldState>();
    final emailKey = GlobalKey<FormFieldState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          authContainer(
            context: context,
            child: Column(
              children: [
                LabeledFormField(
                  fieldKey: nameKey,
                  label: "Full Name",
                  controller: fullNameCtr,
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: kBetweenTextFieldsPadding),
                LabeledFormField(
                  fieldKey: phoneKey,
                  label: "Phone Number",
                  controller: phoneCtr,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                    LengthLimitingTextInputFormatter(10), // Max 10 digits
                  ],
                  validator: AppValidators.validatePhoneNumber,
                ),
                const SizedBox(height: kBetweenTextFieldsPadding),
                LabeledFormField(
                  fieldKey: addressKey,
                  label: "Address",
                  controller: addressCtr,
                  validator: AppValidators.validateAddress,
                ),
                const SizedBox(height: kBetweenTextFieldsPadding),
                LabeledFormField(
                  fieldKey: emailKey,
                  label: "Email",
                  controller: emailCtr,
                  validator: AppValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(r'\s'),
                    ), // disallow spaces
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onNext();
                    }
                  },
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessForm extends StatelessWidget {
  final TextEditingController bizNameCtr;
  final TextEditingController bizLocationCtr;
  final TextEditingController bizEmailCtr;
  final TextEditingController addressCtr;
  final TextEditingController personalEmailCtr;
  final bool useSameAddress;
  final bool usePersonalEmail;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<bool> onToggleAddress;
  final ValueChanged<bool> onToggleEmail;

  const _BusinessForm({
    super.key,
    required this.bizNameCtr,
    required this.bizLocationCtr,
    required this.bizEmailCtr,
    required this.addressCtr,
    required this.personalEmailCtr,
    required this.useSameAddress,
    required this.usePersonalEmail,
    required this.onBack,
    required this.onNext,
    required this.onToggleAddress,
    required this.onToggleEmail,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final bizNameKey = GlobalKey<FormFieldState>();
    final bizAddressKey = GlobalKey<FormFieldState>();
    final bizEmailKey = GlobalKey<FormFieldState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Business Information",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          authContainer(
            context: context,
            child: Column(
              children: [
                LabeledFormField(
                  fieldKey: bizNameKey,
                  label: "Business Name",
                  controller: bizNameCtr,
                  validator:
                      (val) => val == null || val.isEmpty ? 'Required' : null,
                ),

                Row(
                  children: [
                    Checkbox(
                      value: useSameAddress,
                      onChanged: (val) => onToggleAddress(val ?? false),
                    ),
                    const Text("Use personal address"),
                  ],
                ),
                LabeledFormField(
                  fieldKey: bizAddressKey,
                  label: "Business Address",
                  controller: bizLocationCtr,
                  enabled: !useSameAddress,
                  validator: AppValidators.validateAddress,
                ),

                Row(
                  children: [
                    Checkbox(
                      value: usePersonalEmail,
                      onChanged: (val) => onToggleEmail(val ?? false),
                    ),
                    const Text("Use personal email"),
                  ],
                ),
                LabeledFormField(
                  fieldKey: bizEmailKey,
                  label: "Business Emaiil",
                  controller: bizEmailCtr,
                  enabled: !usePersonalEmail,
                  validator: AppValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: kBetweenTextFieldsPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: onBack,
                      child: const Text("Back"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          onNext();
                        }
                      },
                      child: const Text("Next"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialsForm extends ConsumerStatefulWidget {
  final TextEditingController personalEmailCtr;
  final TextEditingController bizEmailCtr;
  final TextEditingController confirmEmailCtr;
  final TextEditingController passwordCtr;
  final TextEditingController confirmPwdCtr;
  final TextEditingController otpCtr;
  final EmailType? emailType;
  final ValueChanged<EmailType?>? onEmailTypeChanged;
  final VoidCallback onBack;
  final void Function()? otpButton;

  const _CredentialsForm({
    required this.personalEmailCtr,
    required this.bizEmailCtr,
    required this.confirmEmailCtr,
    required this.passwordCtr,
    required this.confirmPwdCtr,
    required this.otpCtr,
    required this.emailType,
    required this.onEmailTypeChanged,
    required this.onBack,
    this.otpButton,
  });

  @override
  ConsumerState<_CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends ConsumerState<_CredentialsForm> {
  final formKey = GlobalKey<FormState>();
  final otpFieldKey = GlobalKey<FormFieldState>();

  late final ValueNotifier<int> _countdownNotifier;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _countdownNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownNotifier.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _countdownNotifier.value = 90;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNotifier.value <= 1) {
        timer.cancel();
        _countdownNotifier.value = 0;
      } else {
        _countdownNotifier.value -= 1;
      }
    });
  }

  void _handleResendOtp() async {
    _startTimer();
    final registration = ref.read(registrationProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.read(authNotifierProvider);
    if (registration.useSendOtp) {
      final response = await authNotifier.signUpWithOtp(
        registration.confirmEmailCtr.text.trim().toString(),
      );
      if (!response) {
        showSingleSnackBar(message: authState.error ?? "Failed to send OTP");
        return;
      }

      showSingleSnackBar(
        message:
            "Otp send to ${registration.confirmEmailCtr.text.trim().toString()}",
      );
      return; // Trigger resend OTP
    }
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationProvider);
    final authState = ref.watch(authNotifierProvider);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Credentials", style: Theme.of(context).textTheme.titleMedium),
          authContainer(
            context: context,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text("Account"),
                ),
                const SizedBox(height: kBetweenTextFieldsPadding - 8.0),
                DropdownButtonFormField<EmailType>(
                  value: null,
                  items: [
                    const DropdownMenuItem<EmailType>(
                      value: null,
                      child: Text(
                        'Select Email',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    DropdownMenuItem(
                      value: EmailType.personal,
                      child: Text(widget.personalEmailCtr.text),
                    ),
                    if (widget.personalEmailCtr.text != widget.bizEmailCtr.text)
                      DropdownMenuItem(
                        value: EmailType.business,
                        child: Text(widget.bizEmailCtr.text),
                      ),
                  ],
                  onChanged: widget.onEmailTypeChanged,
                  decoration: const InputDecoration(labelText: "Select Email"),
                  validator:
                      (val) => val == null ? 'Please select an email' : null,
                ),
                const SizedBox(height: kBetweenTextFieldsPadding),
                if (registration.useSendOtp) ...[
                  LabeledFormField(
                    fieldKey: otpFieldKey,
                    label: "Confirm OTP",
                    controller: widget.otpCtr,
                    obscureText: false,
                    validator: AppValidators.validateOtp,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueChangeNotifierButton(
                      countdownNotifier: _countdownNotifier,
                      onPressed: authState.isLoading ? null : _handleResendOtp,
                      buttonText: "Resend OTP",
                      countdownTextBuilder:
                          (secondsLeft) =>
                              "Resend in ${secondsLeft ~/ 60}:${(secondsLeft % 60).toString().padLeft(2, '0')}",
                    ),
                  ),
                ],
                const SizedBox(height: kBetweenTextFieldsPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: widget.onBack,
                      child: const Text("Back"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (!registration.useSendOtp) {
                          _startTimer(); // Start countdown when sending OTP
                        }
                        widget.otpButton?.call();
                      },
                      child:
                          authState.isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                registration.useSendOtp ? "Submit" : "Send OTP",
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassWord extends ConsumerWidget {
  final TextEditingController personalEmailCtr;
  final TextEditingController bizEmailCtr;
  final TextEditingController confirmEmailCtr;
  final TextEditingController passwordCtr;
  final TextEditingController confirmPwdCtr;
  final VoidCallback onBack;
  final void Function()? onFinish;

  const _PassWord({
    required this.personalEmailCtr,
    required this.bizEmailCtr,
    required this.confirmEmailCtr,
    required this.passwordCtr,
    required this.confirmPwdCtr,
    required this.onBack,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context, ref) {
    final formKey = GlobalKey<FormState>();
    final GlobalKey<FormFieldState> passwordFieldKey =
        GlobalKey<FormFieldState>();
    final GlobalKey<FormFieldState> confirmPwdFieldKey =
        GlobalKey<FormFieldState>();
    // final registration  = ref.watch(registrationProvider);
    final authState = ref.watch(authNotifierProvider);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Complete", style: Theme.of(context).textTheme.titleMedium),
          authContainer(
            context: context,
            child: Column(
              spacing: kBetweenTextFieldsPadding,
              children: [
                LabeledFormField(
                  fieldKey: passwordFieldKey,
                  label: "Password",
                  controller: passwordCtr,
                  validator: AppValidators.validatePassword,
                  obscureText: true,
                ),

                LabeledFormField(
                  fieldKey: confirmPwdFieldKey,
                  label: "Confirm Password",
                  controller: confirmPwdCtr,
                  obscureText: true,
                  validator:
                      (val) => AppValidators.validateConfirmPassword(
                        val,
                        passwordCtr.text,
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: onBack,
                      child: const Text("Skip"),
                    ),

                    ElevatedButton(
                      onPressed: onFinish,
                      child:
                          authState.isLoading
                              ? CircularProgressIndicator()
                              : Text("Confirm"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ValueChangeNotifierButton extends StatelessWidget {
  final ValueNotifier<int> countdownNotifier;
  final void Function()? onPressed;
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
