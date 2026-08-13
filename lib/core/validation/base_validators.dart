typedef AppFieldValidator = String? Function(String? value);

abstract final class BaseValidators {
  static AppFieldValidator combine(List<AppFieldValidator> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  static AppFieldValidator required({required String fieldName}) {
    return (value) {
      if ((value ?? '').trim().isEmpty) return '$fieldName is required.';
      return null;
    };
  }

  static AppFieldValidator minLength(int length, {required String fieldName}) {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isNotEmpty && text.length < length) {
        return '$fieldName must be at least $length characters.';
      }
      return null;
    };
  }

  static AppFieldValidator maxLength(int length, {required String fieldName}) {
    return (value) {
      final text = (value ?? '').trim();
      if (text.length > length) {
        return '$fieldName must be at most $length characters.';
      }
      return null;
    };
  }

  static AppFieldValidator startsWithLetter({required String fieldName}) {
    final letter = RegExp(r'^[A-Za-z]');
    return (value) {
      final text = (value ?? '').trim();
      if (text.isNotEmpty && !letter.hasMatch(text)) {
        return '$fieldName must start with a letter.';
      }
      return null;
    };
  }
}
