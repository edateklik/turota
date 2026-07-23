import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/core/utils/user_avatar_initial.dart';

void main() {
  test('Eda için E üretir', () {
    expect(userAvatarInitial(fullName: 'Eda'), 'E');
  });

  test('Eda Teklik için E üretir', () {
    expect(userAvatarInitial(fullName: 'Eda Teklik'), 'E');
  });

  test('şule için Türkçe Ş üretir', () {
    expect(userAvatarInitial(fullName: 'şule'), 'Ş');
  });

  test('ad boşsa username kullanır', () {
    expect(userAvatarInitial(fullName: ' ', username: 'edateklik'), 'E');
  });

  test('ad ve username boşsa e-posta kullanır', () {
    expect(
      userAvatarInitial(fullName: '', username: '', email: 'eda@example.com'),
      'E',
    );
  });

  test('@ ile başlayan username için ilk geçerli harfi kullanır', () {
    expect(userAvatarInitial(username: '@edateklik'), 'E');
  });

  test('tüm alanlar boşsa ikon için boş fallback üretir', () {
    expect(userAvatarInitial(fullName: '', username: '', email: ''), '');
  });

  test('geçersiz başlangıç karakterlerini atlar', () {
    expect(userAvatarInitial(fullName: '  123-çınar'), 'Ç');
  });

  test('Türkçe küçük ı harfini I yapar', () {
    expect(userAvatarInitial(fullName: 'ışık'), 'I');
  });

  test('günaydın adı firstName alanından gelir', () {
    expect(
      currentUserGreetingName(
        firstName: 'Eda Nur',
        fullName: 'Başka İsim',
        email: 'mail@example.com',
      ),
      'Eda Nur',
    );
  });

  test('firstName boşsa fullName kullanılır', () {
    expect(
      currentUserGreetingName(firstName: ' ', fullName: 'Eda Teklik'),
      'Eda Teklik',
    );
  });

  test('isim alanları boşsa email yerel kısmı kullanılır', () {
    expect(currentUserGreetingName(email: 'eda@example.com'), 'eda');
  });

  test('günaydın için kullanılabilir alan yoksa null döner', () {
    expect(currentUserGreetingName(), isNull);
  });
}
