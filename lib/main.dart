import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/dependency_injection.dart';

void main() {
  configureDependencies();
  runApp(const StoreApp());
}
