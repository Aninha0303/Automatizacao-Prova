/// Endereço público (https) do Corrige+ no Firebase Hosting.
/// O QR da folha é um link para este endereço: a câmera do iPhone abre
/// o app já na folha do aluno, sem digitar nem colar nada.
const String kEnderecoApp = 'https://corrigemais-e2d79.web.app';

/// Código interno da folha: provaId|variação|matrícula.
String codigoDaFolha(String provaId, String variacao, String matricula) =>
    '$provaId|$variacao|$matricula';

/// Conteúdo gravado no QR: link que abre a folha direto no app.
String linkDaFolha(String provaId, String variacao, String matricula) =>
    '$kEnderecoApp/?folha='
    '${Uri.encodeComponent(codigoDaFolha(provaId, variacao, matricula))}';

/// Aceita tanto o link novo quanto o código antigo (provaId|V-01|matrícula)
/// e devolve sempre o código provaId|variação|matrícula.
String extrairCodigoDaFolha(String lido) {
  final texto = lido.trim();
  final uri = Uri.tryParse(texto);
  if (uri != null && uri.hasScheme) {
    final folha = uri.queryParameters['folha'];
    if (folha != null && folha.isNotEmpty) return folha.trim();
  }
  return texto;
}

/// Folha recebida pelo link (quando o app foi aberto pela câmera do iPhone).
String? folhaDoEndereco() {
  final folha = Uri.base.queryParameters['folha'];
  if (folha == null || folha.trim().isEmpty) return null;
  return folha.trim();
}
