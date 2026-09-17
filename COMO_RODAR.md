# Como rodar o Corrige+

Este pacote contém **todo o código do aplicativo** (pasta `lib/`, `pubspec.yaml`,
README, diário e configurações). As pastas de plataforma (`android/`, `web/`,
`windows/`, `ios/`) **não vêm no zip de propósito**: elas são geradas pelo
próprio Flutter na sua máquina, com centenas de arquivos automáticos.

Passo a passo, dentro da pasta do projeto:

```bash
flutter create .        # gera android, web, windows, ios (não apaga lib/)
flutter pub get         # baixa as dependências
flutter run -d chrome   # roda no navegador
```

Para gerar o APK da entrega:

```bash
flutter build apk --release
```
O arquivo sai em `build/app/outputs/flutter-apk/app-release.apk`.
