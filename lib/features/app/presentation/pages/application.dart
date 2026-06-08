import 'package:flowcash/core/services/navigation_service.dart';
import 'package:flowcash/core/theme/app_theme.dart';
import 'package:flowcash/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flowcash/features/auth/presentation/bloc/session/session_bloc.dart';
import 'package:flowcash/features/auth/presentation/bloc/session/session_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_bloc.dart';
import 'package:flowcash/features/home/presentation/pages/home_page.dart';
import 'package:flowcash/features/auth/presentation/pages/login_page.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/user_session.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/app/presentation/bloc/app_bloc.dart';
import 'package:flowcash/features/app/presentation/bloc/app_event.dart';
import 'package:flowcash/features/app/presentation/bloc/app_state.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<UserSession>()),
        BlocProvider<AppBloc>(create: (_) => sl<AppBloc>()..add(AppStarted())),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<SessionBloc>(
          create: (_) => sl<SessionBloc>()..add(LoadSessionUsersEvent()),
        ),
        BlocProvider<CategoriesBloc>(create: (_) => sl<CategoriesBloc>()),
      ],
      child: const _MaterialApp(),
    );
  }
}

class _MaterialApp extends StatelessWidget {
  const _MaterialApp();

  @override
  Widget build(BuildContext context) {
    final session = context.read<UserSession>();

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: session,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'التدفق النقدي',
              theme: Themes.light,
              darkTheme: Themes.dark,
              themeMode: state.appData.themeMode,
              routerConfig: NavigationService.router,
              debugShowCheckedModeBanner: false,
              localeResolutionCallback: _localeResolutionCallback,
              locale: state.appData.locale,
              localizationsDelegates: _localizationsDelegates,
              supportedLocales: _supportedLocales,
            );
          },
        );
      },
    );
  }

  static const _supportedLocales = [Locale('ar', 'YE'), Locale('en', 'US')];

  static const _localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  Locale? _localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedlocales,
  ) {
    for (var supportedlocale in supportedlocales) {
      if (supportedlocale.countryCode == locale?.countryCode &&
          supportedlocale.languageCode == locale?.languageCode) {
        return locale;
      }
    }
    return const Locale('ar', 'YE');
  }
}
