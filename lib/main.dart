import 'package:flutter/material.dart';
import 'screens/enroll_screen.dart';
import 'screens/punch_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PontoAI());
}

class PontoAI extends StatelessWidget {
  const PontoAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ponto-AI (MVP)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ponto-AI (MVP)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EnrollScreen()),
                );
              },
              child: const Text('Cadastrar rosto'),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PunchScreen()),
                );
              },
              child: const Text('Bater ponto'),
            ),
          ],
        ),
      ),
    );
  }
}
