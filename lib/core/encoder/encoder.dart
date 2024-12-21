abstract class Encoder<E, D> {
  D encode(E input);
  E decode(D encodedInput);
}
