import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'di/di.dart';
import 'presentation/cubit/auth/auth_cubit.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ← включаем Firestore для профиля:
  await initDependencies(useMocks: false);

  runApp(const FootLogApp());
}

class FootLogApp extends StatelessWidget {
  const FootLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
          ],
          child: Builder(
            builder: (context) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
                child: MaterialApp.router(
                  title: 'FootLog',
                  theme: buildAppTheme(),
                  routerConfig: appRouter, // 👈 старт — /register
                ),
              );
            },
          ),
        );
      },
    );
  }
}
