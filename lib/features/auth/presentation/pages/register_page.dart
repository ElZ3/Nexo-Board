import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/media_service.dart';
import '../../data/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  final List<String> _genders = [
    'Masculino',
    'Femenino',
    'Otro',
    'Prefiero no decirlo'
  ];

  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _profileImage;
  final MediaService _mediaService = MediaService();
  final AuthService _authService = AuthService();

  Future<void> _pickImage() async {
    try {
      final file = await _mediaService.pickProfileImage();
      if (file != null) {
        setState(() {
          _profileImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onStepContinue() async {
    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (_selectedDate == null || _selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Comleta todos los campos de detalles.')),
        );
        return;
      }
    } else if (_currentStep == 2) {
      if (!_formKeyStep3.currentState!.validate()) return;
      await _submitRegistration();
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _selectedDate!,
        gender: _selectedGender!,
        username: _usernameController.text.trim(),
        description: _descriptionController.text.trim(),
        profileImage: _profileImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado con éxito.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              steps: _buildSteps(theme),
            ),
    );
  }

  List<Step> _buildSteps(ThemeData theme) {
    return [
      Step(
        title: const Text('Datos Personales'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeyStep1,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: Validators.validatePassword,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Detalles Personales'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeyStep2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration:
                      const InputDecoration(labelText: 'Fecha de Nacimiento'),
                  child: Text(
                    _selectedDate == null
                        ? 'Seleccionar fecha'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sexo'),
                initialValue: _selectedGender,
                items: _genders.map((String gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Perfil de Usuario'),
        isActive: _currentStep >= 2,
        content: Form(
          key: _formKeyStep3,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            theme.primaryColor.withValues(alpha: 0.2),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Icon(Icons.person,
                                size: 50, color: theme.primaryColor)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.primaryColor,
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de usuario'),
                validator: Validators.validateUsername,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
