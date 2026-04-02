class User {
  final String id;
  final String phoneNumber;
  final UserProfile? profile;

  User({
    required this.id,
    required this.phoneNumber,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'profile': profile?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? phoneNumber,
    UserProfile? profile,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profile: profile ?? this.profile,
    );
  }
}

class UserProfile {
  final String? fullName;
  final String? email;
  final DateTime? dateOfBirth;
  final Address? address;

  UserProfile({
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (address != null) 'address': address!.toJson(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    DateTime? dateOfBirth,
    Address? address,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
    );
  }

  bool get isComplete {
    return fullName != null &&
        email != null &&
        dateOfBirth != null &&
        address != null &&
        address!.isComplete;
  }
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;

  Address({
    this.street,
    this.city,
    this.state,
    this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
    };
  }

  bool get isComplete {
    return street != null && city != null && state != null && pincode != null;
  }
}
