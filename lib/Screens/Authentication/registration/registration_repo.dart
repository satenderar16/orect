import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_enums.dart';
import '../../../data/model/profile_model.dart';
import 'registration_state_model.dart';

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(RegistrationState.initial());

  void setProfile() {
    final profile = Profile(
      username: state.fullNameCtr.text.trim(),
      phoneNo: state.phoneCtr.text.trim(),
      userAddress: state.addressCtr.text.trim(),
      email: state.personalEmailCtr.text.trim(),
      businessName: state.bizNameCtr.text.trim(),
      businessAddress: state.bizLocationCtr.text.trim(),
      businessEmail: state.bizEmailCtr.text.trim(),
    );

    state = state.copyWith(profile: profile,);
  }

  void toggleUseSameAddress(bool value) {
    if (value) {
      state.bizLocationCtr.text = state.addressCtr.text;
    } else {
      state.bizLocationCtr.clear();
    }
    state = state.copyWith(useSameAddress: value);
  }

  void toggleUsePersonalEmail(bool value) {
    if (value) {
      state.bizEmailCtr.text = state.personalEmailCtr.text;
    } else {
      state.bizEmailCtr.clear();
    }
    state = state.copyWith(usePersonalEmail: value);
  }

  void setEmailType(EmailType? type) {
    if (type == null) return;

    final confirmEmail = type == EmailType.personal
        ? state.personalEmailCtr.text
        : state.bizEmailCtr.text;
    state.confirmEmailCtr.text = confirmEmail;

    state = state.copyWith(emailType: type);
  }

  void setSentOtp() {
    state = state.copyWith(useSendOtp: true);
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}