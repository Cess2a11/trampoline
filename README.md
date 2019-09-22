trampoline
==========

A library for trampolining recursive calls. 

# Example 1:


```dart

import 'package:trampoline/trampoline.dart';

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

void main() {
  int z = 10;
  print("fib(${z}) is ${fib(z).result}!");
}

```

# Example 2:


```dart

import 'package:trampoline/trampoline.dart';

TailRec<bool> odd(int n) => n == 0 ? done(false) : tailcall(() => even(n - 1));
TailRec<bool> even(int n) => n == 0 ? done(true) : tailcall(() => odd(n - 1));

void main() {
  int z = 1000;
  print("${z} is odd? ${odd(z).result}!");
}

```

