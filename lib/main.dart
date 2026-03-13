import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/network/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await SupabaseClientManager.initialize();

  // Initialize Dependency Injection
  await di.initDependencies();

  runApp(ShellaPayApp());
}
