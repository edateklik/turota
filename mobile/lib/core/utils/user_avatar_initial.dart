String userAvatarInitial({String? fullName, String? username, String? email}) {
  for (final candidate in [fullName, username, _emailLocalPart(email)]) {
    final initial = _firstLetter(candidate);
    if (initial != null) return _turkishUppercase(initial);
  }
  return '';
}

String? currentUserGreetingName({
  String? firstName,
  String? fullName,
  String? displayName,
  String? username,
  String? email,
}) {
  for (final candidate in [
    firstName,
    fullName,
    displayName,
    username,
    _emailLocalPart(email),
  ]) {
    final cleaned = candidate?.trim();
    if (cleaned != null && cleaned.isNotEmpty) return cleaned;
  }
  return null;
}

String? _emailLocalPart(String? email) {
  if (email == null) return null;
  final separator = email.indexOf('@');
  return separator < 0 ? email : email.substring(0, separator);
}

String? _firstLetter(String? value) {
  if (value == null) return null;
  for (final rune in value.runes) {
    final character = String.fromCharCode(rune);
    if (_isLetter(character)) return character;
  }
  return null;
}

bool _isLetter(String character) {
  const turkishLetters = 'abcçdefgğhıijklmnoöprsştuüvyz';
  final lower = character.toLowerCase();
  return turkishLetters.contains(lower) ||
      character.toUpperCase() != character.toLowerCase();
}

String _turkishUppercase(String character) {
  const replacements = {
    'i': 'İ',
    'ı': 'I',
    'ş': 'Ş',
    'ç': 'Ç',
    'ğ': 'Ğ',
    'ö': 'Ö',
    'ü': 'Ü',
  };
  return replacements[character.toLowerCase()] ?? character.toUpperCase();
}
