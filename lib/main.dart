import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

import 'screens/alunos_screen.dart';
import 'screens/correcao_screen.dart';
import 'screens/login_screen.dart';
import 'screens/painel_screen.dart';
import 'screens/provas_screen.dart';
import 'screens/questoes_screen.dart';
import 'screens/resultados_screen.dart';
import 'screens/turmas_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CorrigeApp());
}

class CorrigeApp extends StatelessWidget {
  const CorrigeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corrige+',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: StreamBuilder<User?>(
        stream: AuthService.instance.mudancas,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snap.data;
          if (user == null) return const LoginScreen();
          FirestoreService.instance.setProfessor(user.uid);
          return const AppShell();
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  String _nome = 'Professor';

  static const _titles = [
    'Corrige+',
    'Questões',
    'Provas',
    'Correção',
    'Resultados',
    'Alunos',
    'Turmas',
  ];

  final _screens = const [
    PainelScreen(),
    QuestoesScreen(),
    ProvasScreen(),
    CorrecaoScreen(),
    ResultadosScreen(),
    AlunosScreen(),
    TurmasScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AuthService.instance.nomeProfessor().then((n) {
      if (mounted) setState(() => _nome = n);
    });
  }

  Future<void> _sair() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja sair do Corrige+?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (ok == true) await AuthService.instance.sair();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('C',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(_titles[_index])),
            IconButton(
              tooltip: 'Sair',
              onPressed: _sair,
              icon: const Icon(Icons.logout, size: 20),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(_nome,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Painel'),
              NavigationDestination(
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                  label: 'Questões'),
              NavigationDestination(
                  icon: Icon(Icons.description_outlined),
                  selectedIcon: Icon(Icons.description),
                  label: 'Provas'),
              NavigationDestination(
                  icon: Icon(Icons.qr_code_scanner_outlined),
                  selectedIcon: Icon(Icons.qr_code_scanner),
                  label: 'Correção'),
              NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Notas'),
              NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Alunos'),
              NavigationDestination(
                  icon: Icon(Icons.class_outlined),
                  selectedIcon: Icon(Icons.class_),
                  label: 'Turmas'),
            ],
          ),
        ],
      ),
    );
  }
}
