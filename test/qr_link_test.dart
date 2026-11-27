import 'package:corrige_mais/qr_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('o QR da folha é um link https que abre o app na folha', () {
    final link = linkDaFolha('VKjlIWtWpvJvmuFCnKYp', 'V-01', '01');
    expect(link.startsWith('https://corrigemais-e2d79.web.app/?folha='), isTrue);
    expect(extrairCodigoDaFolha(link), 'VKjlIWtWpvJvmuFCnKYp|V-01|01');
  });

  test('o código antigo provaId|variação|matrícula continua aceito', () {
    expect(extrairCodigoDaFolha(' VKjlIWtWpvJvmuFCnKYp|V-01|01 '),
        'VKjlIWtWpvJvmuFCnKYp|V-01|01');
  });
}
