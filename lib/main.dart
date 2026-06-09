import 'package:flowcash/features/app/presentation/pages/application_fluent.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;

  await initDependencies();

  runApp(const ApplicationFluent());

  ErrorWidget.builder = (details) {
    return Center(
      child: fluent.SelectableText(
        details.exception.toString(),
        textDirection: TextDirection.ltr,
        style: fluent.TextStyle(fontSize: 16, fontWeight: fluent.FontWeight.bold),
      ),
    );
  };
}
