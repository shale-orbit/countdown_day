import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CountdownDayApp());
}

class CountdownDayApp extends StatelessWidget {
  const CountdownDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '倒数日',
      debugShowCheckedModeBanner: false,
      // 橙红暖色调主题
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7043),
          primary: const Color(0xFFFF7043),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF7043),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
