import 'package:cards/utils/counter.dart';
import 'package:test/test.dart';

void main() {
  test('Counter works', () {
    Counter c = Counter(5);
    expect(c.get(), 5);
    c.inc();
    expect(c.get(), 6);
    c.inc();
    expect(c.get(), 7);
    c.dec();
    expect(c.get(), 6);
  });
}
