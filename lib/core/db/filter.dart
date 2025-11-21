abstract class Filter<T> implements Comparable<T> {
  late String label;
  bool ok(T t);

  @override
  bool operator ==(Object other) {
    if (other is! Filter) return false;
    return label == other.label;
  }

  @override
  int get hashCode => label.hashCode;

  @override
  int compareTo(T other) {
    if (other is! Filter) return 0;
    return label.compareTo(other.label);
  }
}
