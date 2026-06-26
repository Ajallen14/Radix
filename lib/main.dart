import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/root_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const ProviderScope(child: RadixApp()));
}

class RadixApp extends StatelessWidget {
  const RadixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), 
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA4EB3F), 
          surface: Color(0xFF2A2A2A), 
        ),
        useMaterial3: true,
      ),
      home: const RootScreen(), 
    );
  }
}