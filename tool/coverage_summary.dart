import 'dart:io';

/// Summarizes instrumented application lines, excluding generated Dart files.
/// Usage: dart run tool/coverage_summary.dart [coverage/lcov.info]
void main(List<String> arguments) {
  final file = File(
    arguments.isEmpty ? 'coverage/lcov.info' : arguments.single,
  );
  if (!file.existsSync()) {
    stderr.writeln('Primero ejecuta flutter test --coverage.');
    exitCode = 1;
    return;
  }
  final sources = <String, Map<int, bool>>{};
  String? source;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      final path = line.substring(3).replaceAll('\\', '/');
      source =
          path.startsWith('lib/') &&
              !RegExp(r'\.(g|freezed)\.dart$').hasMatch(path)
          ? path
          : null;
    } else if (line.startsWith('DA:') && source != null) {
      final fields = line.substring(3).split(',');
      final number = int.parse(fields[0]);
      final lines = sources.putIfAbsent(source, () => {});
      lines[number] = (lines[number] ?? false) || int.parse(fields[1]) > 0;
    } else if (line == 'end_of_record') {
      source = null;
    }
  }
  var total = 0;
  var covered = 0;
  for (final entry
      in sources.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
    final hit = entry.value.values.where((v) => v).length;
    total += entry.value.length;
    covered += hit;
    stdout.writeln('$hit/${entry.value.length} ${entry.key}');
  }
  final percentage = total == 0
      ? '0.00'
      : (100 * covered / total).toStringAsFixed(2);
  stdout.writeln('Total (sin generados): $covered/$total ($percentage%).');
}
