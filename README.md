# Corrige+

Corrige+ é um aplicativo feito em Flutter/Dart para ajudar professores que aplicam provas objetivas. A ideia nasceu de um problema bem simples: corrigir prova por prova, à mão, toma tempo demais.

Com o app, o professor monta a prova a partir de um banco de questões, imprime uma folha de resposta diferente para cada aluno (cada uma com seu próprio QR code), aponta a câmera do celular para a folha e recebe a nota na hora. No final ainda dá para ver quais questões a turma errou mais.

Nesta primeira entrega (N1) todas as telas já funcionam e podem ser navegadas, mas os dados são fictícios: ainda não existe banco de dados nem servidor.

## 1. Objetivo

Acabar com a correção manual das provas objetivas. Ao ler o QR code da folha, o app já sabe de qual aluno ela é e qual variação da prova ele recebeu, calcula a nota na hora e mostra quais alternativas a turma marcou em cada questão.

## 2. Escopo

### O que entra na N1

- Todas as telas navegáveis por botão: painel, questões, provas, nova prova, folhas, correção, resultados e alunos.
- Banco de questões fictício, com disciplina, assunto, dificuldade, alternativas e gabarito.
- Montagem da prova escolhendo questões, embaralhando e gerando uma variação por aluno.
- Folha de resposta na tela, com QR code de verdade (prova, variação e matrícula).
- Correção por leitura de QR pela câmera no Android e no iOS; no navegador e no Windows existe um modo simulado, só para demonstrar.
- Resultados com a nota de cada aluno e as alternativas mais marcadas em cada questão.

### O que fica para depois

- Banco de dados, login e sincronização na nuvem.
- Leitura óptica real das marcações a lápis na folha impressa.
- Exportar boletins ou planilhas e conversar com sistemas acadêmicos.
- Provas discursivas.

## 3. Requisitos

### Funcionais

| Cód. | Requisito |
| --- | --- |
| RF01 | Mostrar um painel com resumo de provas, turmas e correções recentes. |
| RF02 | Listar o banco de questões com disciplina, assunto, dificuldade e gabarito. |
| RF03 | Buscar e filtrar as questões do banco. |
| RF04 | Criar uma prova escolhendo questões do banco. |
| RF05 | Escolher o modo de geração: mesmas questões embaralhadas ou provas diferentes. |
| RF06 | Gerar uma variação de prova para cada aluno da turma. |
| RF07 | Gerar a folha de resposta individual com nome, matrícula, variação e grade A–D. |
| RF08 | Colocar em cada folha um QR code que identifica prova, variação e aluno. |
| RF09 | Ler o QR code da folha pela câmera do aparelho. |
| RF10 | Calcular acertos e nota comparando as respostas com o gabarito da variação. |
| RF11 | Listar as folhas corrigidas na sessão, com acertos e nota. |
| RF12 | Mostrar os resultados da turma em tabela, com a nota de cada aluno. |
| RF13 | Mostrar, em cada questão, o percentual de cada alternativa e qual é o gabarito. |
| RF14 | Listar turmas e alunos com a matrícula. |

### Não funcionais

| Cód. | Requisito |
| --- | --- |
| RNF01 | Feito em Flutter/Dart, usando Material 3. |
| RNF02 | Roda no Android; também compila para Web e Windows. |
| RNF03 | Tela que se adapta a celular, tablet e janela de navegador. |
| RNF04 | Interface em português do Brasil. |
| RNF05 | Nesta etapa os dados são fictícios e ficam na memória (`lib/mock_data.dart`). |
| RNF06 | Chegar a qualquer tela em no máximo 2 toques a partir do painel. |
| RNF07 | O QR deve ser reconhecido em menos de 2 segundos depois de enquadrado. |
| RNF08 | Código separado por responsabilidade: tema, dados, componentes e telas. |
| RNF09 | Bibliotecas open source usadas: google_fonts, qr_flutter e mobile_scanner. |

## 4. Telas

| Tela | Arquivo | O que faz |
| --- | --- | --- |
| Painel | `lib/screens/painel_screen.dart` | Números gerais e atalhos para as outras telas. |
| Questões | `lib/screens/questoes_screen.dart` | Banco de questões, com busca e o gabarito de cada uma. |
| Provas | `lib/screens/provas_screen.dart` | Provas criadas, situação de cada uma e acesso às folhas. |
| Nova prova | `lib/screens/provas_screen.dart` | Escolha das questões, modo de geração e variações. |
| Folhas de resposta | `lib/screens/folhas_screen.dart` | Uma folha por aluno, com grade A–D e QR code real. |
| Correção | `lib/screens/correcao_screen.dart` | Leitura do QR pela câmera e cálculo da nota. |
| Resultados | `lib/screens/resultados_screen.dart` | Notas da turma e desempenho por questão. |
| Alunos | `lib/screens/alunos_screen.dart` | Turmas e alunos com matrícula. |

## 5. Organização dos arquivos

```
lib/
  main.dart          navegação principal do app
  theme.dart         tema Material 3, cores e fontes
  mock_data.dart     dados fictícios (turmas, alunos, questões, provas, correções)
  widgets.dart       componentes reaproveitados (cards, cabeçalhos, etiquetas)
  screens/           uma tela por arquivo
```

## 6. Como rodar

Precisa do Flutter SDK 3.4 ou mais novo (confira com `flutter --version`).

```bash
# 1. dentro da pasta do projeto, crie as pastas de plataforma
flutter create .

# 2. baixe as dependências
flutter pub get

# 3. rode
flutter run -d chrome     # no navegador
flutter run               # em um celular Android conectado
```

Para gerar o APK:

```bash
flutter build apk --release
# o arquivo sai em build/app/outputs/flutter-apk/app-release.apk
```

Uma observação: a leitura do QR pela câmera funciona de verdade no Android e no iOS. No Chrome e no Windows a tela de correção usa um modo simulado, só para conseguir demonstrar o fluxo.

## 7. Vídeo de demonstração

https://youtu.be/D6YPwx4ws3E

## 8. Autoria

Este trabalho foi feito individualmente.

| Aluna | GitHub | O que fez |
| --- | --- | --- |
| Ana Vicini | @Aninha0303 | Levantamento dos requisitos, planejamento das telas, todo o desenvolvimento em Flutter/Dart, os dados fictícios, a documentação e a geração do APK. |

Como o trabalho é individual, todos os commits saem da mesma conta. Mesmo assim segui o fluxo combinado: uma branch por funcionalidade, Pull Request, revisão registrada por mim mesma e merge na `master`.
