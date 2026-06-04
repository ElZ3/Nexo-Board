import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nexoboard/features/auth/data/auth_service.dart';
import 'package:nexoboard/features/auth/presentation/views/main_feed_page.dart';
import 'dart:async';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- Controladores y Llaves ---
  late PageController _pageController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Timer? _carouselTimer;

  // --- Estados de la Vista ---
  int _currentPage = 0;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // --- Servicios ---
  final AuthService _authService = AuthService();

  // --- Items del Carrusel Informativo ---
  final List<Map<String, String>> _carouselItems = [
    {
      'title': 'Nexo Board',
      'description': 'Tu plataforma colaborativa',
    },
    {
      'title': 'Colaboración',
      'description': 'Trabaja en equipo sin límites',
    },
    {
      'title': 'Productividad',
      'description': 'Logra más en menos tiempo',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startCarouselAutoScroll();
  }

  void _startCarouselAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _carouselItems.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // ÚNICO MÉTODO DE LOGIN (CORREGIDO Y CONFIGURADO CON ITERACIÓN DE CARGA)
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.loginUser(
          identifier: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainFeedPage()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _carouselItems.length,
                  itemBuilder: (context, index) {
                    return _buildCarouselItem(
                      _carouselItems[index],
                      textTheme,
                      theme,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildCarouselIndicators(theme),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Inicia sesión',
                      style: textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accede a tu cuenta de Nexo Board',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEmailField(theme, textTheme)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.1),
                    const SizedBox(height: 16),
                    _buildPasswordField(theme, textTheme)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideX(begin: -0.1),
                    const SizedBox(height: 24),
                    _buildLoginButton(textTheme)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 24),
                    _buildSocialLoginSection(theme, textTheme)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms),
                    const SizedBox(height: 16),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(
    Map<String, String> item,
    TextTheme textTheme,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.1),
            theme.cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.dashboard_customize,
              color: theme.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item['title']!,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            item['description']!,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _carouselItems.length,
        (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? theme.primaryColor : Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField(ThemeData theme, TextTheme textTheme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email_outlined, color: theme.primaryColor),
        labelText: 'Correo o Nombre de Usuario', // Ajustado al login flexible
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu correo o usuario';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(ThemeData theme, TextTheme textTheme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outlined, color: theme.primaryColor),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          child: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: theme.primaryColor,
          ),
        ),
        labelText: 'Contraseña',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
        return null;
      },
    );
  }

  Widget _buildLoginButton(TextTheme textTheme) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Iniciar Sesión',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
    );
  }

  Widget _buildSocialLoginSection(ThemeData theme, TextTheme textTheme) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white24)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continúa con',
                style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white24)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.facebook, size: 24),
                label: const Text('Facebook'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta? ',
          style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          child: Text(
            'Regístrate aquí',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
