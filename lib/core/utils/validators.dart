class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$");
    if (!nameRegex.hasMatch(value)) return 'Solo se permiten letras y espacios';
    if (value.length < 2) return 'Debe tener al menos 2 caracteres';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) return 'Formato de correo inválido';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe contener una mayúscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe contener un número';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Debe contener un carácter especial';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El usuario es obligatorio';
    }
    final userRegex = RegExp(r"^[a-zA-Z0-9_]+$");
    if (!userRegex.hasMatch(value)) {
      return 'Solo letras, números y guiones bajos (_)';
    }
    if (value.length < 4 || value.length > 15) {
      return 'Debe tener entre 4 y 15 caracteres';
    }
    return null;
  }
}
