/// Validation Helper
class ValidationHelper {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'fieldRequired';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'invalidEmail';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'fieldRequired';
    }
    if (value.length < 8) {
      return 'passwordTooShort';
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'fieldRequired';
    }
    return null;
  }

  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'fieldRequired';
    }
    if (password != confirmPassword) {
      return 'passwordsDoNotMatch';
    }
    return null;
  }
}

