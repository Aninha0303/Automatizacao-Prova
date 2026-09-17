import 'package:flutter/material.dart';

import 'screens/painel_screen.dart';
import 'screens/questoes_screen.dart';
import 'screens/provas_screen.dart';
import 'screens/correcao_screen.dart';
import 'screens/resultados_screen.dart';
import 'screens/alunos_screen.dart';
import 'theme.dart';

void main() => runApp(const CorrigeApp());

class CorrigeApp extends StatelessWidget {
  const CorrigeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corrige+',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AppShell(),
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

  static const _titles = [
    'Corrige+',
    'Questões',
    'Provas',
    'Correção',
    'Resultados',
    'Alunos',
  ];

  final _screens = const [
    PainelScreen(),
    QuestoesScreen(),
    ProvasScreen(),
    CorrecaoScreen(),
    ResultadosScreen(),
    AlunosScreen(),
  ];

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
            Text(_titles[_index]),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
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
        ],
      ),
    );
  }
}
