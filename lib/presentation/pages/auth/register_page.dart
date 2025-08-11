  // lib/presentation/pages/register_page.dart
  import 'package:go_router/go_router.dart';
  import '../../navigation/app_router.dart'; // где лежит Routes
  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/app_theme.dart'; // если тема лежит в core/ui/app_theme.dart — поправь путь
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../widgets/common_form_fields.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    final pass = _passC.text.trim();
    final confirm = _confirmC.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }
    if (pass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль должен быть не короче 8 символов')),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают')),
      );
      return;
    }
    context.read<AuthCubit>().register(name, email, pass);
  }

  @override
  Widget build(BuildContext context) {
    // параметры из макета
    const designBlockHeight = 540.0; // высота контент-блока (от полей до низа)
    final safeTop = MediaQuery.of(context).padding.top;
    final topTitle = 102.h; // отступ заголовка сверху

    // доступная высота под блок (без заголовка)
    final available = MediaQuery.of(context).size.height - safeTop - topTitle;

    // коэффициент сжатия вертикалей на маленьких экранах
    final factor = (available / designBlockHeight.h).clamp(0.85, 1.0);
    double vh(double v) => (v.h * factor);

    final titleStyle =
    factor < 0.95 ? AppText.h1.copyWith(fontSize: 30.sp) : AppText.h1;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Регистрация успешна')),
              );
            },
            error: (msg) =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final loading =
          state.maybeWhen(loading: () => true, orElse: () => false);

          // сам контент (без скролла)
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // заголовок — по бокам 36
              Padding(
                padding: EdgeInsets.only(
                  top: safeTop + topTitle,
                  left: 36.w,
                  right: 36.w,
                ),
                child: FittedBox( // гарантирует одну строку: подожмёт шрифт, чтобы влезло
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Добро пожаловать!',
                    style: titleStyle,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
// по макету: от заголовка до поля "Имя" — 16
              SizedBox(height: 16.h),

              // блок полей — по бокам 16
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(hint: 'Имя', controller: _nameC),
                    SizedBox(height: 8.h),
                    AppTextField(
                      hint: 'Email',
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 8.h),
                    PasswordField(controller: _passC, hint: 'Пароль'),
                    SizedBox(height: 8.h),
                    PasswordField(
                      controller: _confirmC,
                      hint: 'Подтверждение пароля',
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      'Пароль должен содержать не менее 8 символов',
                      style: AppText.body.copyWith(
                        fontSize: 15.sp,
                        height: 1.0,
                        color: AppColors.textGray,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.start,
                    ),


                    SizedBox(height: vh(16)),

                    SizedBox(
                      height: vh(52),
                      child: PrimaryButton(
                        label: 'Зарегистрироваться',
                        onPressed: loading ? null : () => _onRegister(context),
                      ),
                    ),
                    SizedBox(height: vh(16)),

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

                    TextButton(
                      onPressed: () => context.go(Routes.login), // ← вот так
                      child: Text.rich(
                        TextSpan(
                          text: 'Уже есть аккаунт? ',
                          style: AppText.body.copyWith(color: AppColors.black),
                          children: [TextSpan(text: 'Войти', style: AppText.link)],
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

          // обёртка, гарантирующая отсутствие overflow
          return SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // если помещается — скролла не будет (physics отключит прокрутку)
                  physics: constraints.maxHeight >
                      (safeTop + topTitle + designBlockHeight.h * 0.95)
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight( // аккуратно растягивает колонку при большой высоте
                      child: content,
                    ),
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
