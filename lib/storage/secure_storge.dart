import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mod_do_an/models/user/user.dart';

class SecureStorage {
  final _storage = new FlutterSecureStorage();

  static const _tokenKey = 'TOKEN';

  static const _isSaveData = 'IS_SAVE_DATA';

  static const _user = 'USER';

  static const _upper = 'upper';

  static const _under = 'under';

  Future<void> saveToken({required String token}) async {
    print("Đã lưu token");
    print(token);
    await _storage.write(key: _tokenKey, value: "Bearer " + token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveIsSaveData({required String isSaveData}) async {
    await _storage.write(key: _isSaveData, value: isSaveData);
  }

  Future<String?> getIsSaveData() async {
    return await _storage.read(key: _isSaveData);
  }

  Future<void> deleteToken() async {
    return _storage.delete(key: _tokenKey);
  }

  Future<void> deleteAll() async {
    return _storage.deleteAll();
  }

  Future<void> saveCustomer({required ProfileUser user}) async {
    await _storage.write(key: _user, value: user.toString());
  }

  Future<ProfileUser> getUser() async {
    String? userString = await _storage.read(key: _user);

    if (userString != null) {
      ProfileUser user = ProfileUser.fromJson(jsonDecode(userString));

      return user;
    }

    return new ProfileUser(
        id: "",
        firstName: "",
        lastName: "",
        email: "",
        phone: "",
        dob: "",
        gender: "",
        nationality: "",
        customerId: "");
  }

  Future<void> saveUpperBound({required String upper}) async {
    await _storage.write(key: _upper, value: upper);
  }

  Future<String?> getUpperBound() async {
    return await _storage.read(key: _upper);
  }

  Future<void> saveUnderBound({required String under}) async {
    await _storage.write(key: _under, value: under);
  }

  Future<String?> getUnderBound() async {
    return await _storage.read(key: _under);
  }
}
