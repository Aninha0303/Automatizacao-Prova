# Diário de Bordo — N1

**Aluna:** Ana Vicini
**GitHub:** @<seu usuário>
**Grupo:** <número do grupo>
**Projeto:** Corrige+ — Correção Automatizada de Provas Objetivas
**Modalidade:** trabalho individual (uma única integrante)

---

## Tarefa 1 — Levantamento de requisitos e escopo da N1
- **Data:** 10/09/2026
- **Tipo:** pesquisa / alinhamento
- **Descrição:** leitura do material do cliente e definição do problema: eliminação da correção
  manual de provas objetivas. Liste os requisitos funcionais (RF01–RF14) e não funcionais
  (RNF01–RNF09) e delimitei o que fica fora da N1 (banco de dados, OMR real, discursivas).
- **Link:** issue correspondente no GitHub
- **Evidências:**
  - `print-01.png` — lista de RF e RNF no README

## Tarefa 2 — Estrutura base do app, tema e navegação
- **Data:** 10/09/2026
- **Tipo:** desenvolvimento
- **Descrição:** criei o projeto Flutter com Material 3, tema próprio (`lib/theme.dart`),
  widgets reutilizáveis (`lib/widgets.dart`) e o shell com navegação entre as telas
  (`lib/main.dart`).
- **Link:** branch `feat/estrutura-e-tema` → Pull Request → merge na `master`
- **Evidências:**
  - `print-02.png` — painel do app aberto no Chrome

## Tarefa 3 — Banco de questões com busca e filtros
- **Data:** 10/09/2026
- **Tipo:** desenvolvimento
- **Descrição:** montei os dados fictícios (`lib/mock_data.dart`) e a tela de questões com
  disciplina, assunto, dificuldade, alternativas, gabarito, busca e filtro por dificuldade.
- **Link:** branch `feat/banco-questoes` → Pull Request → merge na `master`
- **Evidências:**
  - `print-03.png` — lista de questões com o filtro aplicado

## Tarefa 4 — Provas com geração aleatória e variações
- **Data:** 17/09/2026
- **Tipo:** desenvolvimento
- **Descrição:** implementei a criação de prova selecionando questões do banco, o modo de
  geração (mesmas questões embaralhadas ou provas diferentes) e a variação por aluno da turma.
- **Link:** branch `feat/provas-e-variacoes` → Pull Request → merge na `master`
- **Evidências:**
  - `print-04.png` — tela Nova prova com as questões selecionadas

## Tarefa 5 — Folhas de resposta com QR code por aluno
- **Data:** 17/09/2026
- **Tipo:** desenvolvimento
- **Descrição:** gerei a folha individualizada com nome, matrícula, variação e grade A–D, e o
  QR code real com a codificação `prova|variação|matrícula` usando `qr_flutter`.
- **Link:** branch `feat/folhas-qrcode` → Pull Request → merge na `master`
- **Evidências:**
  - `print-05.png` — folha de resposta com o QR code visível

## Tarefa 6 — Correção por câmera e cálculo da nota
- **Data:** 17/09/2026
- **Tipo:** desenvolvimento
- **Descrição:** implementei a leitura do QR com `mobile_scanner` em Android/iOS e o modo
  simulado na Web/Desktop, comparando as marcações com o gabarito da variação para calcular
  acertos e nota.
- **Link:** branch `feat/correcao-camera` → Pull Request → merge na `master`
- **Evidências:**
  - `print-06.png` — tela de correção com a folha corrigida na lista

## Tarefa 7 — Resultados por aluno e análise por questão
- **Data:** 17/09/2026
- **Tipo:** desenvolvimento
- **Descrição:** montei a tabela de notas da turma e a análise por questão com o percentual de
  marcação de cada alternativa e o gabarito destacado; na tela de alunos listei turmas e
  matrículas.
- **Link:** branch `feat/resultados-e-alunos` → Pull Request → merge na `master`
- **Evidências:**
  - `print-07.png` — resultados com a análise por questão

## Tarefa 8 — Documentação (README v1) e empacotamento da entrega
- **Data:** 17/09/2026
- **Tipo:** documentação
- **Descrição:** escrevi o README v1 com objetivo, escopo, requisitos, telas, estrutura e
  instruções de execução, o guia `COMO_RODAR.md` e este diário; organizei o ZIP da entrega.
- **Link:** branch `docs/readme-v1` → Pull Request → merge na `master`
- **Evidências:**
  - `print-08.png` — README renderizado no GitHub

---

### Checklist da entrega
- [ ] Issues criadas no GitHub para cada parte do trabalho
- [x] Commits feitos com o meu próprio usuário
- [ ] Pull Requests abertos, revisados e mergeados
- [x] Contribuí com o README v1
- [ ] Prints de evidência anexados a cada tarefa
- [ ] APK da entrega gerado e incluído no ZIP
- [ ] Vídeo de demonstração (2–5 min) gravado e linkado no README

> Nome do arquivo final: `N1_AnaVicini_diario.pdf`
