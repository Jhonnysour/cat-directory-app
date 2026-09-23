final class CatFact {
  const CatFact({required this.text, required this.length});

  final String text;
  final int length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatFact && text == other.text && length == other.length;

  @override
  int get hashCode => Object.hash(text, length);
}
