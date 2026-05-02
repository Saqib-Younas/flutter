import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/auth_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final ok = controller.isLogin.value
          ? await controller.signIn(
              emailController.text.trim(),
              passwordController.text.trim(),
            )
          : await controller.signUp(
              emailController.text.trim(),
              passwordController.text.trim(),
              nameController.text.trim(),
            );

      if (!ok) return;
      Get.offAllNamed(controller.isAdmin ? '/admin' : '/home');
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColor.gradientAuth),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _AuthHeader(),
                  const SizedBox(height: 45),
                  Obx(
                    () => _AuthFormCard(
                      formKey: formKey,
                      isLogin: controller.isLogin.value,
                      isLoading: controller.isLoading.value,
                      error: controller.errorMessage.value,
                      nameController: nameController,
                      emailController: emailController,
                      passwordController: passwordController,
                      onSubmit: submit,
                      onToggle: controller.toggleAuthMode,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'LuxeCart',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          'Shop the future of luxury',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.formKey,
    required this.isLogin,
    required this.isLoading,
    required this.error,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onToggle,
  });

  final GlobalKey<FormState> formKey;
  final bool isLogin;
  final bool isLoading;
  final String? error;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLogin ? 'Welcome Back' : 'Join LuxeCart',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 25),
            if (!isLogin) ...[
              _AuthField(
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                controller: nameController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 18),
            ],
            _AuthField(
              label: 'Email Address',
              icon: Icons.alternate_email_rounded,
              controller: emailController,
              validator: (v) =>
                  (v != null && v.contains('@')) ? null : 'Enter a valid email',
            ),
            const SizedBox(height: 18),
            _AuthField(
              label: 'Password',
              icon: Icons.lock_open_rounded,
              controller: passwordController,
              isPassword: true,
              validator: (v) =>
                  (v != null && v.length >= 6) ? null : 'Minimum 6 characters',
            ),
            if (error != null) ...[
              const SizedBox(height: 15),
              _ErrorBanner(message: error!),
            ],
            const SizedBox(height: 35),
            _GradientSubmit(
              text: isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: onToggle,
                child: RichText(
                  text: TextSpan(
                    text: isLogin
                        ? "Don't have an account? "
                        : 'Already a member? ',
                    style: TextStyle(color: Colors.grey.shade600),
                    children: [
                      TextSpan(
                        text: isLogin ? 'Register' : 'Login',
                        style: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.validator,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF7C3AED), size: 22),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientSubmit extends StatelessWidget {
  const _GradientSubmit({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF7C3AED)],
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
