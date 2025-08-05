
import 'package:flutter/material.dart';

import '../../../core/utils/app_enums.dart';
import '../../../data/model/profile_model.dart';

class RegistrationState {
  final TextEditingController fullNameCtr;
  final TextEditingController phoneCtr;
  final TextEditingController addressCtr;
  final TextEditingController personalEmailCtr;
  final TextEditingController bizNameCtr;
  final TextEditingController bizLocationCtr;
  final TextEditingController bizEmailCtr;
  final TextEditingController confirmEmailCtr;
  final TextEditingController passwordCtr;
  final TextEditingController confirmPwdCtr;
  final TextEditingController otpCtr;
  final Profile? profile;
  final bool useSameAddress;
  final bool usePersonalEmail;
  final bool useSendOtp;
  final EmailType emailType;

  RegistrationState({
    required this.fullNameCtr,
    required this.phoneCtr,
    required this.addressCtr,
    required this.personalEmailCtr,
    required this.bizNameCtr,
    required this.bizLocationCtr,
    required this.bizEmailCtr,
    required this.confirmEmailCtr,
    required this.passwordCtr,
    required this.confirmPwdCtr,
    required this.otpCtr,
    this.profile,
    this.useSameAddress = false,
    this.usePersonalEmail = false,
    this.useSendOtp = false,
    this.emailType = EmailType.personal,
  });

  /// Copy only relevant fields; keep controller references the same
  RegistrationState copyWith({
    Profile? profile,
    bool? useSameAddress,
    bool? usePersonalEmail,
    bool? useSendOtp,
    EmailType? emailType,
  }) {
    return RegistrationState(
      fullNameCtr: fullNameCtr,
      phoneCtr: phoneCtr,
      addressCtr: addressCtr,
      personalEmailCtr: personalEmailCtr,
      bizNameCtr: bizNameCtr,
      bizLocationCtr: bizLocationCtr,
      bizEmailCtr: bizEmailCtr,
      confirmEmailCtr: confirmEmailCtr,
      passwordCtr: passwordCtr,
      confirmPwdCtr: confirmPwdCtr,
      otpCtr: otpCtr,
      profile: profile ?? this.profile,
      useSameAddress: useSameAddress ?? this.useSameAddress,
      usePersonalEmail: usePersonalEmail ?? this.usePersonalEmail,
      useSendOtp: useSendOtp ?? this.useSendOtp,
      emailType: emailType ?? this.emailType,
    );
  }

  void dispose() {
    fullNameCtr.dispose();
    phoneCtr.dispose();
    addressCtr.dispose();
    personalEmailCtr.dispose();
    bizNameCtr.dispose();
    bizLocationCtr.dispose();
    bizEmailCtr.dispose();
    confirmEmailCtr.dispose();
    passwordCtr.dispose();
    confirmPwdCtr.dispose();
    otpCtr.dispose();
  }

  /// Factory to create initial state
  factory RegistrationState.initial() {
    return RegistrationState(
      fullNameCtr: TextEditingController(),
      phoneCtr: TextEditingController(),
      addressCtr: TextEditingController(),
      personalEmailCtr: TextEditingController(),
      bizNameCtr: TextEditingController(),
      bizLocationCtr: TextEditingController(),
      bizEmailCtr: TextEditingController(),
      confirmEmailCtr: TextEditingController(),
      passwordCtr: TextEditingController(),
      confirmPwdCtr: TextEditingController(),
      otpCtr: TextEditingController(),
    );
  }
}
