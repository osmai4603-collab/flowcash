
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flowcash/features/app/presentation/pages/application.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;

  await initDependencies();

  runApp(const Application());


}
