import 'dart:async';

import 'package:amtnew/core/features/auth/auth_provider.dart';
import 'package:amtnew/core/config/connectivity/internet_provider.dart';
import 'package:amtnew/core/features/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_validators.dart';
import '../../widgets/Constants/auth_constants.dart';
import '../../widgets/Snackbars/dismissed_snackbar.dart';
import '../../widgets/TextFields/auth_text_field.dart';
import '../../widgets/animated_size.dart';
// import '../../../widgets/animation_overlay.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool passwordBool = true;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _forgotPassword() {
    context.push("/auth?screen=forgot");
  }

  // void _checkNetworkConnection(){
  //   if (!ref.read(internetProvider)) {
  //     showSingleSnackBar(message: "No internet Connection");
  //     return;
  //   }
  // }
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authRepo = ref.watch(authNotifierProvider.notifier);

    final res = await authRepo.login(
      emailController.text.trim().toString(),
      passwordController.text.trim().toString(),
    );

    if (!res) {
      showSingleSnackBar(
        message: ref.read(authNotifierProvider).error ?? "Login failed",
      );
      return;
    }
    showSingleSnackBar(
      message: "Welcome Back!! ${ref.read(profileNotifierProvider).profile?.username}",
    );
    // authRepo.setAuthentication(true);// to set user is there:
  }

  void _loginWithOtp() {
    context.push("/auth?screen=otp");
  }

  void _register() {
    context.push("/auth?screen=register");
  }

  Timer? _backPressTimer;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isOnline = ref.watch(internetProvider);
    return PopScope(
      canPop: false, // prevent automatic pop
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        if (_backPressTimer == null || !_backPressTimer!.isActive) {
          // First back press
          FocusScope.of(context).unfocus();
          showSingleSnackBar(
            message: "Press again",
            onPressed: () {
              SystemNavigator.pop();
            },
            label: "Exit",
            duration: Duration(milliseconds: 2000)
          );
          // Start 2.0-second countdown
          _backPressTimer = Timer(Duration(milliseconds: 2000), () {
            // Timer ends, reset
            _backPressTimer = null;
          });

          return;
        }
        // final bool shouldPop = await exitAlertDialog(context) ?? false;
        // if (shouldPop) {
        SystemNavigator.pop();
        // }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final contentWidth = isTablet ? 400.0 : constraints.maxWidth * 0.90;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kMainContainerPaddingHorizontal,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedSizeContainer(
                    curve: Curves.bounceInOut,
                    child: Container(
                      width: contentWidth,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                        border: Border.all(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                        ),
                        borderRadius: BorderRadius.circular(
                          kMainContainerBorderRadius,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: kMainContainerPaddingHorizontal,
                        vertical: kMainContainerPaddingVertical,
                      ),
                      child: Column(
                        children:
                            isOnline.hasInternet
                                ? [
                                  Image.asset(
                                    kImagePathAsset,
                                    width: kImageSize,
                                    height: kImageSize,
                                    fit: BoxFit.contain,
                                  ),

                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AuthCustomTextFormField(
                                          label: "Email",
                                          keyField: _emailKey,

                                          controller: emailController,
                                          validator:
                                              AppValidators.validateEmail,
                                        ),
                                        const SizedBox(
                                          height: kBetweenTextFieldsPadding,
                                        ),
                                        AuthCustomTextFormField(
                                          label: "Password",

                                          keyField: _passwordKey,
                                          controller: passwordController,

                                          obscure: passwordBool,
                                          validator:
                                              AppValidators.validatePassword,
                                        ),
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: TextButton(
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textButtonTheme.style,
                                            onPressed:
                                                () =>
                                                    authState.isLoading
                                                        ? null
                                                        : _forgotPassword(),
                                            child: Text(
                                              "Forgot password?",
                                              style: TextTheme.of(
                                                context,
                                              ).labelLarge!.copyWith(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed:
                                              () =>
                                                  authState.isLoading
                                                      ? null
                                                      : _login(),
                                          child:
                                              authState.isLoading
                                                  ? CircularProgressIndicator()
                                                  : const Text('Login'),
                                        ),
                                        Text('OR'),
                                        OutlinedButton(
                                          onPressed:
                                              () =>
                                                  authState.isLoading
                                                      ? null
                                                      : _loginWithOtp(),
                                          child: Text('Login with OTP'),
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                              0.6,
                                          child: Divider(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  _accountWidget(),
                                ]
                                : [
                                  Image.asset(
                                    "assets/image_offline_login.png",
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "No Internet Connection",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Please check your network settings and try again.",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Text _accountWidget() {
    return Text.rich(
      TextSpan(
        text: "Don't have an account?",
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ), // Removes padding
                minimumSize: Size.zero, // Removes minimum size constraints
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, ),
              onPressed:
                  () =>
                      ref.read(authNotifierProvider).isLoading
                          ? null
                          : _register(),
              child: Text("Register", style: TextTheme.of(context).titleLarge),
            ),
          ),
        ],
      ),
    );
  }

  // void _showFlag({
  //   required String message,
  //   Color color = Colors.green,
  //   bool error = false,
  // }) {
  //   final overlay = Overlay.of(context);
  //   late OverlayEntry overlayEntry;
  //   overlayEntry = OverlayEntry(
  //     builder:
  //         (_) => Positioned(
  //           top: MediaQuery.of(context).padding.top + 20,
  //
  //           right: 10,
  //           child: Align(
  //             alignment: Alignment.topCenter,
  //             child: AnimatedFlag(
  //               message: message,
  //               color: color,
  //               onDismissed: () {
  //                 overlayEntry.remove();
  //               },
  //               error: error,
  //             ),
  //           ),
  //         ),
  //   );
  //
  //   overlay.insert(overlayEntry);
  // }
}
