final class Breed {
  const Breed({
    required this.name,
    required this.country,
    required this.origin,
    required this.coat,
    required this.pattern,
  });

  final String name;
  final String country;
  final String origin;
  final String coat;
  final String pattern;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Breed &&
          name == other.name &&
          country == other.country &&
          origin == other.origin &&
          coat == other.coat &&
          pattern == other.pattern;

  @override
  int get hashCode => Object.hash(name, country, origin, coat, pattern);
}
