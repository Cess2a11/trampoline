import 'package:trampoline/trampoline.dart';

// Example 1

TailRec<int> fib(int n) {
  if (n < 2) {
    return done(n);
  } else {
    return tailcall(() => fib(n - 1)).flatMap((x) {
      return tailcall(() => fib(n - 2)).map((y) {
        return (x + y);
      });
    });
  }
}

// Example 2

TailRec<bool> odd(int n) => n == 0 ? done(false) : tailcall(() => even(n - 1));
TailRec<bool> even(int n) => n == 0 ? done(true) : tailcall(() => odd(n - 1));

void main() {
  bool res1;
  res1 = (even(101).result<int, int>());
  print("Ergebnis von Odd/Even ist $res1");
  for (int z = 20; z < 35; z++) {
    num res2;
    res2 = Defs.fib(z).result<int, int>();
    print("Ergebnis von Fibonacci für $z ist $res2");
  }
}
