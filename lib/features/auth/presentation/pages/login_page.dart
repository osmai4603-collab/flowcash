import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/session/session_bloc.dart';
import '../bloc/session/session_event.dart';
import '../bloc/session/session_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    final colors = ColorScheme.of(context);
    return fluent.ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<SessionBloc, SessionState>(
            listener: (context, state) {
              if (state.status == SessionStatus.authenticated) {
                fluent.displayInfoBar(
                  context,
                  builder: (context, close) => fluent.InfoBar(
                    title: const fluent.Text('تنبيه'),
                    content: fluent.Text(
                      'مرحباً بك ${state.currentUser?.userName}!',
                      textAlign: TextAlign.right,
                      style: TextTheme.of(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onTertiary,
                      ),
                    ),
                  ),
                );
              }
              if (state.status == SessionStatus.failure) {
                fluent.displayInfoBar(
                  context,
                  builder: (context, close) => fluent.InfoBar(
                    title: const fluent.Text('تنبيه'),
                    content: SelectableText(
                      state.errorMessage ?? 'فشل تسجيل الدخول',
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 450 : double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // شعار أو عنوان
                    // const fluent.Icon(
                    //   FluentIcons.payment_card,
                    //   size: 80,
                    //   color: Colors.blue,
                    // ),
                    // const SizedBox(height: 24),
                    fluent.Text(
                      'تدفق كاش',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    fluent.Text(
                      'نظام إدارة التدفقات النقدية',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 48),

                    // نموذج تسجيل الدخول
                    Card(
                      elevation: 4,
                      color: colors.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: Radiuses.mediumAll,
                      ),
                      child: Padding(
                        padding: Paddings.largeAll,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              fluent.Text(
                                'تسجيل الدخول',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _userNameController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'اسم المستخدم',
                                  prefixIcon: fluent.Icon(Icons.person),
                                ),
                                textAlign: TextAlign.right,
                                validator: (value) => value?.isEmpty == true
                                    ? 'يرجى إدخال اسم المستخدم'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                textInputAction: TextInputAction.send,
                                onFieldSubmitted: (_) => _onLoginPressed(),
                                decoration: const InputDecoration(
                                  labelText: 'كلمة المرور',
                                  prefixIcon: fluent.Icon(Icons.lock),
                                  hintText: 'ادخل كلمة المرور',
                                ),
                                obscureText: true,
                                textAlign: TextAlign.right,
                                validator: (value) => value?.isEmpty == true
                                    ? 'يرجى إدخال كلمة المرور'
                                    : null,
                              ),
                              const SizedBox(height: Spacings.large),
                              if (state.status == SessionStatus.loading)
                                const Center(child: fluent.ProgressRing())
                              else
                                fluent.FilledButton(
                                  onPressed: _onLoginPressed,

                                  child: const fluent.Text(
                                    'دخول',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // const SizedBox(height: 32),

                    // // قائمة المستخدمين (اختياري، متاح فقط في وضع التطوير أو للتجربة)
                    // if (state.users.isNotEmpty) ...[
                    //   const fluent.Text(
                    //     'المستخدمين المسجلين في النظام',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    //   ),
                    //   const SizedBox(height: 12),
                    //   Wrap(
                    //     alignment: WrapAlignment.center,
                    //     spacing: 8,
                    //     children: state.users.map((user) {
                    //       return ActionChip(
                    //         label: fluent.Text(user.userName),
                    //         avatar: const fluent.Icon(fluent.FluentIcons.personalize, size: 16),
                    //         onPressed: () {
                    //           _userNameController.text = user.userName;
                    //         },
                    //       );
                    //     }).toList(),
                    //  ),
                    // ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() == true) {
      context.read<SessionBloc>().add(
        LoginRequested(
          userName: _userNameController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }
}
