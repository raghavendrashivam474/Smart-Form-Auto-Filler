class User {
  final String id;
  final String email;
  final String? phoneNumber;
  final UserProfile? profile;

  User({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      profile: json['profile'] != null && json['profile'] is Map
          ? UserProfile.fromJson(Map<String, dynamic>.from(json['profile']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (profile != null) 'profile': profile!.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    UserProfile? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profile: profile ?? this.profile,
    );
  }
}

class UserProfile {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final Address? address;
  final String? annualIncome;
  final String? category;
  final String? gender;
  final Map<String, dynamic>? _rawData;

  UserProfile({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.annualIncome,
    this.category,
    this.gender,
    Map<String, dynamic>? rawData,
  }) : _rawData = rawData;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // ✅ Safely convert to Map<String, dynamic>
    final safeJson = Map<String, dynamic>.from(json);
    
    // ✅ SAFE address parsing - handle both Map and String
    Address? parsedAddress;
    final addressData = safeJson['address'];
    if (addressData != null) {
      if (addressData is Map) {
        parsedAddress = Address.fromJson(Map<String, dynamic>.from(addressData));
      } else if (addressData is String) {
        // If address is a string, put it in street field
        parsedAddress = Address(street: addressData);
      }
    }
    
    return UserProfile(
      fullName: safeJson['fullName']?.toString(),
      email: safeJson['email']?.toString(),
      phoneNumber: safeJson['phoneNumber']?.toString(),
      dateOfBirth: safeJson['dateOfBirth'] != null
          ? DateTime.tryParse(safeJson['dateOfBirth'].toString())
          : null,
      address: parsedAddress,
      annualIncome: safeJson['annual_income']?.toString(),
      category: safeJson['category']?.toString(),
      gender: safeJson['gender']?.toString(),
      rawData: safeJson,
    );
  }

  // ✅ FIXED - Returns Map<String, dynamic> safely
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    
    // Add known fields
    if (fullName != null) result['fullName'] = fullName;
    if (email != null) result['email'] = email;
    if (phoneNumber != null) result['phoneNumber'] = phoneNumber;
    if (dateOfBirth != null) result['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (annualIncome != null) result['annual_income'] = annualIncome;
    if (category != null) result['category'] = category;
    if (gender != null) result['gender'] = gender;
    
    // ✅ Handle address safely
    if (address != null) {
      result['address'] = address!.toJson();
    }
    
    // ✅ Include raw data fields with safe conversion
    if (_rawData != null) {
      _rawData!.forEach((key, value) {
        if (!result.containsKey(key) && value != null) {
          if (value is Map) {
            try {
              result[key] = Map<String, dynamic>.from(value);
            } catch (e) {
              result[key] = value.toString();
            }
          } else if (value is List) {
            result[key] = value;
          } else {
            result[key] = value;
          }
        }
      });
    }
    
    return result;
  }

  // ✅ Get any field value dynamically
  dynamic getField(String fieldName) {
    switch (fieldName) {
      case 'fullName':
        return fullName;
      case 'email':
        return email;
      case 'phoneNumber':
        return phoneNumber;
      case 'dateOfBirth':
        return dateOfBirth?.toIso8601String();
      case 'annual_income':
        return annualIncome;
      case 'category':
        return category;
      case 'gender':
        return gender;
      default:
        return _rawData?[fieldName];
    }
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Address? address,
    String? annualIncome,
    String? category,
    String? gender,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      annualIncome: annualIncome ?? this.annualIncome,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      rawData: _rawData,
    );
  }

  bool get isComplete {
    return fullName != null &&
        email != null &&
        phoneNumber != null &&
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

  // ✅ SAFE - Handles any input type
  factory Address.fromJson(dynamic json) {
    if (json == null) {
      return Address();
    }
    
    if (json is String) {
      // Address is a string - put it in street
      return Address(street: json);
    }
    
    if (json is! Map) {
      return Address();
    }
    
    final safeJson = Map<String, dynamic>.from(json);
    
    return Address(
      street: safeJson['street']?.toString(),
      city: safeJson['city']?.toString(),
      state: safeJson['state']?.toString(),
      pincode: safeJson['pincode']?.toString(),
    );
  }

  // ✅ Returns Map<String, dynamic> safely
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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