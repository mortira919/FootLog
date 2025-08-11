import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../widgets/common_form_fields.dart'; // AppTextField, PasswordField, GoogleButton, DividerWithLabel
import '../../navigation/app_router.dart';      // Routes

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _passC  = TextEditingController();

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    final email = _emailC.text.trim();
    final pass  = _passC.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните email и пароль')),
      );
      return;
    }
    context.read<AuthCubit>().login(email, pass);
  }

  @override
  Widget build(BuildContext context) {
    // те же приёмы, что и на регистрации
    const designBlockHeight = 460.0;
    final safeTop  = MediaQuery.of(context).padding.top;
    final topTitle = 102.h; // отступ до заголовка по макету

    final available = MediaQuery.of(context).size.height - safeTop - topTitle;
    final factor = (available / designBlockHeight.h).clamp(0.85, 1.0);
    double vh(double v) => (v.h * factor);

    final titleStyle =
    factor < 0.95 ? AppText.h1.copyWith(fontSize: 30.sp) : AppText.h1;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (_) {
              // TODO: когда появится Home — заменить на context.go(Routes.home)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Вход выполнен')),
              );
            },
            error: (msg) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg))),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final loading =
          state.maybeWhen(loading: () => true, orElse: () => false);

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок
              Padding(
                padding: EdgeInsets.only(
                  top: safeTop + topTitle,
                  left: 51.5.w,
                  right: 51.5.w,
                ),

                child: FittedBox(
                  // гарантируем одну строку, как в фигме
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'С возвращением!',
                    style: titleStyle,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Поля и кнопки
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      hint: 'Email',
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 8.h),
                    PasswordField(
                      controller: _passC,
                      hint: 'Пароль',
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 8.h),

                    // Забыли пароль?
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => context.go(Routes.forgot),
                        child: Text(
                          'Забыли пароль?',
                          style: AppText.link,
                        ),
                      ),
                    ),

                    SizedBox(height: vh(8)),

                    SizedBox(
                      height: vh(52),
                      child: PrimaryButton(
                        label: 'Войти',
                        onPressed: loading ? null : () => _onLogin(context),
                      ),
                    ),

                    SizedBox(height: vh(8)),

                    Text.rich(
                      TextSpan(
                        text: 'Продолжая, вы принимаете ',
                        style: AppText.body,
                        children: [
                          TextSpan(text: 'условия сервиса', style: AppText.link),
                          const TextSpan(text: ' и '),
                          TextSpan(
                            text: 'политику конфиденциальности',
                            style: AppText.link,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: vh(16)),
                    const DividerWithLabel('Или'),
                    SizedBox(height: vh(8)),

                    SizedBox(
                      height: vh(52),
                      child: GoogleButton(
                        label: 'Войти',
                        onPressed: loading
                            ? null
                            : () => context.read<AuthCubit>().signInWithGoogle(),
                      ),
                    ),

                    SizedBox(height: vh(16)),

                    // «Ещё нет аккаунта? Создать»
                    TextButton(
                      onPressed: () => context.go(Routes.register),
                      child: Text.rich(
                        TextSpan(
                          text: 'Ещё нет аккаунта? ',
                          style:
                          AppText.body.copyWith(color: AppColors.black),
                          children: [
                            TextSpan(text: 'Создать', style: AppText.link),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: vh(8)),
                  ],
                ),
              ),
            ],
          );

          return SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: constraints.maxHeight >
                      (safeTop + topTitle + designBlockHeight.h * 0.95)
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(child: content),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
