import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../widgets/common_form_fields.dart';
import '../../navigation/app_router.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailC = TextEditingController();

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  void _onSend(BuildContext context) {
    FocusScope.of(context).unfocus(); // спрятать клавиатуру
    final email = _emailC.text.trim();

    // простая валидация email
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
    if (!emailOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный email')),
      );
      return;
    }

    context.read<AuthCubit>().resetPassword(email);
  }

  @override
  Widget build(BuildContext context) {
    // размеры как на других экранах
    const designBlockHeight = 258.0;
    final safeTop = MediaQuery.of(context).padding.top;

    // отступ до заголовка по макету
    final topTitle = 102.h;

    final available = MediaQuery.of(context).size.height - safeTop - topTitle;
    final factor = (available / designBlockHeight.h).clamp(0.85, 1.0);
    double vh(double v) => (v.h * factor);

    final titleStyle =
    factor < 0.95 ? AppText.h1.copyWith(fontSize: 30.sp) : AppText.h1;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            resetLinkSent: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ссылка отправлена. Проверьте почту и папку «Спам».'),
                ),
              );
              context.go(Routes.login);
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
              // Заголовок: по бокам 82.5 как в макете
              Padding(
                padding: EdgeInsets.only(
                  top: safeTop + topTitle,
                  left: 82.5.w,
                  right: 82.5.w,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Сброс пароля',
                    style: titleStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Контент-блок: по 16
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Введите свой email, чтобы получить ссылку для сброса пароля.',
                      textAlign: TextAlign.center, // центрируем текст
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    AppTextField(
                      hint: 'Email',
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: vh(16)),

                    SizedBox(
                      height: vh(52),
                      child: PrimaryButton(
                        label: loading ? 'Отправляем…' : 'Отправить ссылку',
                        onPressed: loading ? null : () => _onSend(context),
                      ),
                    ),

                    SizedBox(height: vh(12)),

                    Center(
                      child: TextButton(
                        onPressed: () => context.go(Routes.login),
                        child: Text(
                          'Вернуться ко входу',
                          style: AppText.link,
                        ),
                      ),
                    ),
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
