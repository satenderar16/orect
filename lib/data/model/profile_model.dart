class Profile {
final String? id;
  final String? username;
  final String? businessName;
  final String? userAddress;
  final String? businessAddress;
  final String? phoneNo;
  final String? email;
  final String? businessEmail;
  final String? businessPhoneNo;

  Profile({
    this.id,
    this.username,
    this.businessName,
    this.userAddress,
    this.businessAddress,
    this.phoneNo,
    this.email,
    this.businessEmail,
    this.businessPhoneNo,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String?,
      username: map['username'] as String?,
      businessName: map['business_name'] as String?,
      userAddress: map['user_address'] as String?,
      businessAddress: map['business_address'] as String?,
      phoneNo: map['phone_no'] as String?,
      email: map['email'] as String?,
      businessEmail: map['business_email'] as String?,
      businessPhoneNo: map['business_phone_no'] as String?,
    );
  }

  Map<String, dynamic> toMap(String id) {
    return {
      'id': id,
      'username': username,
      'business_name': businessName,
      'user_address': userAddress,
      'business_address': businessAddress,
      'phone_no': phoneNo,
      'email': email,
      'business_email': businessEmail,
      'business_phone_no': businessPhoneNo,
    };
  }

  Map<String, dynamic> toMapTem() {
    return {
      'username': username,
      'business_name': businessName,
      'user_address': userAddress,
      'business_address': businessAddress,
      'phone_no': phoneNo,
      'email': email,
      'business_email': businessEmail,
      'business_phone_no': businessPhoneNo,
    };
  }

  /// Optional: helper for copyWith (if you'd like immutability helpers)
  Profile copyWith({
    String? id,
    String? username,
    String? businessName,
    String? userAddress,
    String? businessAddress,
    String? phoneNo,
    String? email,
    String? businessEmail,
    String? businessPhoneNo,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      businessName: businessName ?? this.businessName,
      userAddress: userAddress ?? this.userAddress,
      businessAddress: businessAddress ?? this.businessAddress,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      businessEmail: businessEmail ?? this.businessEmail,
      businessPhoneNo: businessPhoneNo ?? this.businessPhoneNo,
    );
  }
}
