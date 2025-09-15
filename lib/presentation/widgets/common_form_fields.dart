import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/app_theme.dart';




class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDims.r12()),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        enabled: enabled,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
    );
  }
}




class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;

  const PasswordField({
    super.key,
    this.controller,
    this.hint = 'Пароль',
    this.textInputAction = TextInputAction.next,
    this.onChanged,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDims.r12()),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        textInputAction: widget.textInputAction,
        obscureText: _obscure,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          suffixIconConstraints: BoxConstraints(minWidth: 48.w, minHeight: 49.h),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 22.r,
            icon: Transform.translate(
              offset: Offset(0, _obscure ? -1 : 0),
              child: Image.asset(
                _obscure ? 'assets/icons/eye_closed.png' : 'assets/icons/eye_open.png',
                width: 23.w,
                height: (_obscure ? 13.h : 17.h),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}




class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDims.h52(),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: AppText.button),
      ),
    );
  }
}




class DividerWithLabel extends StatelessWidget {
  final String text;
  const DividerWithLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(text, style: AppText.body.copyWith(color: AppColors.textGray)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}




class GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  const GoogleButton({
    super.key,
    this.label = 'Войти',
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDims.h52(),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const Icon(Icons.g_mobiledata),
        label: Text(label),
      ),
    );
  }
}
