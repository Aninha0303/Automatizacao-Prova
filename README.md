# Corrige+ — Correção Automatizada de Provas Objetivas

Aplicativo Flutter/Dart para professores que aplicam provas objetivas: monta a prova a partir de
um banco de questões, gera folhas de resposta individualizadas com QR code, corrige pela câmera do
celular e apresenta os resultados por aluno e por questão.

> **Entrega N1** — todas as telas são navegáveis e populadas com **dados fictícios (mock)**.
> Não há banco de dados nem backend nesta etapa.

## 1. Objetivo

Eliminar a correção manual de provas objetivas. O professor fotografa/escaneia o QR code da folha
de resposta e o app identifica o aluno, a variação da prova aplicada e calcula a nota na hora,
mostrando também quais alternativas a turma mais marcou em cada questão.

## 2. Escopo delimitado

### Dentro do escopo da N1
- Telas principais navegáveis por botão (painel, questões, provas, nova prova, folhas, correção, resultados, alunos).
- Banco de questões fictício com disciplina, assunto, dificuldade, alternativas e gabarito.
- Criação de prova com seleção de questões, embaralhamento e geração de variações por aluno.
- Geração visual da folha de resposta com **QR code real** (`prova|variação|matrícula`).
- Correção: leitura de QR pela câmera em Android/iOS e modo simulado em Web/Desktop.
- Resultados: nota por aluno e distribuição de alternativas marcadas por questão.

### Fora do escopo da N1
- Banco de dados, autenticação e sincronização em nuvem.
- Reconhecimento óptico real das marcações a lápis (OMR) na folha impressa.
- Exportação oficial de planilhas/boletins e integração com sistemas acadêmicos.
- Provas discursivas.

## 3. Requisitos

### Requisitos Funcionais (RF)
| Cód. | Requisito |
|------|-----------|
| RF01 | O app deve exibir um painel com o resumo de provas, turmas e correções recentes. |
| RF02 | O app deve listar o banco de questões com disciplina, assunto, dificuldade e gabarito. |
| RF03 | O app deve permitir filtrar/buscar questões do banco. |
| RF04 | O app deve permitir criar uma prova selecionando questões do banco. |
| RF05 | O app deve permitir escolher o modo de geração: mesmas questões embaralhadas ou provas diferentes. |
| RF06 | O app deve gerar uma variação de prova por aluno da turma. |
| RF07 | O app deve gerar a folha de resposta individualizada com nome, matrícula, variação e grade A–D. |
| RF08 | Cada folha de resposta deve conter um QR code que identifica prova, variação e aluno. |
| RF09 | O app deve ler o QR code da folha pela câmera do dispositivo. |
| RF10 | O app deve calcular acertos e nota comparando as respostas com o gabarito da variação. |
| RF11 | O app deve listar as folhas corrigidas na sessão com acertos e nota. |
| RF12 | O app deve exibir os resultados da turma em tabela com nota por aluno. |
| RF13 | O app deve exibir, por questão, o percentual de marcação de cada alternativa e o gabarito. |
| RF14 | O app deve listar turmas e alunos com matrícula. |

### Requisitos Não Funcionais (RNF)
| Cód. | Requisito |
|------|-----------|
| RNF01 | Desenvolvido em Flutter/Dart, com Material 3. |
| RNF02 | Executável em Android; também compila para Web e Windows. |
| RNF03 | Interface responsiva, adaptando-se a celular, tablet e janela de navegador. |
| RNF04 | Interface em português do Brasil. |
| RNF05 | Nesta etapa os dados são mock, mantidos em memória (`lib/mock_data.dart`). |
| RNF06 | Navegação entre telas em no máximo 2 toques a partir do painel. |
| RNF07 | Leitura do QR deve responder em menos de 2 segundos após o enquadramento. |
| RNF08 | Código organizado por responsabilidade (tema, dados, widgets, telas). |
| RNF09 | Uso de bibliotecas open source: `google_fonts`, `qr_flutter`, `mobile_scanner`. |

## 4. Telas principais

| Tela | Arquivo | Descrição |
|------|---------|-----------|
| Painel | `lib/screens/painel_screen.dart` | Indicadores gerais e atalhos para as demais telas. |
| Questões | `lib/screens/questoes_screen.dart` | Banco de questões com busca e detalhe do gabarito. |
| Provas | `lib/screens/provas_screen.dart` | Lista de provas, status e acesso às folhas. |
| Nova prova | `lib/screens/provas_screen.dart` | Seleção de questões, modo de geração e variações. |
| Folhas de resposta | `lib/screens/folhas_screen.dart` | Folha por aluno com grade A–D e QR code real. |
| Correção | `lib/screens/correcao_screen.dart` | Leitura do QR pela câmera e cálculo da nota. |
| Resultados | `lib/screens/resultados_screen.dart` | Notas da turma e análise por questão. |
| Alunos | `lib/screens/alunos_screen.dart` | Turmas e alunos com matrícula. |

## 5. Estrutura do projeto

```
lib/
  main.dart          navegação principal e shell do app
  theme.dart         tema Material 3, cores e tipografia
  mock_data.dart     dados fictícios (turmas, alunos, questões, provas, correções)
  widgets.dart       componentes reutilizáveis (cards, cabeçalhos, badges)
  screens/           uma tela por arquivo
```

## 6. Como rodar

Pré-requisitos: Flutter SDK 3.4 ou superior (`flutter --version`).

```bash
# 1. dentro da pasta do projeto, gere as pastas de plataforma
flutter create .

# 2. baixe as dependências
flutter pub get

# 3. execute
flutter run -d chrome     # navegador
flutter run               # celular Android conectado
```

Gerar o APK:

```bash
flutter build apk --release
# saída: build/app/outputs/flutter-apk/app-release.apk
```

Observação: a leitura real do QR code pela câmera funciona em Android/iOS. No Chrome e no Windows a
tela de correção usa um modo simulado equivalente, para permitir a demonstração.

## 7. Vídeo de demonstração

Link: `<inserir aqui o link do YouTube (não listado) ou do Google Drive com acesso liberado>`

## 8. Autoria

Projeto desenvolvido individualmente.

| Aluna | GitHub | Responsabilidades |
|-------|--------|-------------------|
| Ana Vicini | @<seu usuário> | Levantamento de requisitos, planejamento das telas, desenvolvimento completo em Flutter/Dart, dados mock, documentação e geração do APK. |

Por se tratar de trabalho individual, todos os commits são da mesma conta. O fluxo de trabalho
seguiu branch por funcionalidade → Pull Request → auto-revisão documentada → merge na `master`.

## Video de apresentacao

https://youtu.be/D6YPwx4ws3E
