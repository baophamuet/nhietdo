import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Validator {
  // static  String REGEX_PASSWORD = "^(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{10}";
  // static  String REGEX_EMAIL = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static String REGEX_EMAIL =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  static String? validateEmail(String? value) {
    print(value);
    if (value!.isEmpty) {
      return 'invalid email';
    }
    if (!RegExp(REGEX_EMAIL).hasMatch(value)) {
      return 'Please Enter Correct Email Form';
    }
    return null;
  }

  static String? validatePassWord(String? value) {
    if (value!.isEmpty) {
      return 'Please Enter Your Password';
    }
    return null;
  }

  static String? validateRePassWord(String? value, String? password) {
    if (value!.isEmpty) {
      return 'Please Enter Your Re_Password';
    }
    if (value != password) {
      return 'Please Corect Re_Password';
    }
    return null;
  }

  static String? validateRequired(String? value, String lable) {
    if (value!.isEmpty) {
      return 'Please Enter ' + lable;
    }
    return null;
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    print(newText);
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 3 && nonZeroIndex != newText.length ||
          nonZeroIndex == 6 && nonZeroIndex != newText.length) {
        buffer.write('-');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
