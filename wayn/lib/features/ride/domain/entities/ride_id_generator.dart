class RideIdGenerator {
  final String value;

  const RideIdGenerator._(this.value);

  factory RideIdGenerator.generate() {
    final now = DateTime.now();
    final date =
        now.toIso8601String().replaceAll(RegExp(r'[-:]'), '').substring(0, 8);
    final time = '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    final random = String.fromCharCodes(
        List.generate(3, (_) => 65 + (DateTime.now().microsecond % 26)));

    return RideIdGenerator._('RT-$date-$time-$random');
  }

  // Création depuis une string
  factory RideIdGenerator.fromString(String value) {
    return RideIdGenerator._(value);
  }

  @override
  String toString() => value;
}
