import '../base_validators.dart';

abstract final class AuthValidators {
  static final _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r'[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$',
  );

  static final AppFieldValidator username = BaseValidators.combine([
    BaseValidators.required(fieldName: 'Username'),
    BaseValidators.minLength(3, fieldName: 'Username'),
    BaseValidators.maxLength(30, fieldName: 'Username'),
    BaseValidators.startsWithLetter(fieldName: 'Username'),
  ]);

  static final AppFieldValidator password = BaseValidators.combine([
    BaseValidators.required(fieldName: 'Password'),
    BaseValidators.minLength(6, fieldName: 'Password'),
    BaseValidators.maxLength(64, fieldName: 'Password'),
  ]);

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Email is required.';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }
}
