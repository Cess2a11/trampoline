// Hier ist die Umwandlung von Tailcall-Recursion in Iteration bereits erfolgt
// aber die Typisierung stimmt nicht.

abstract class TailRec<A> {
  A value;

  A result<B, C>() {
    TailRec<A> tr = this;
    while (!(tr is _Done<A>)) {
      //
      if (tr is _Bounce<A>) {
        tr = (tr as _Bounce<A>).continuation(); // calling rest();Case 1
        //

      } else if (tr is Cont<B, A>) {
        TailRec<B> a = (tr as Cont<B, A>).a;
        TailRec<A> Function(B) f = (tr as Cont<B, A>).f;
        if (a is _Done<B>) {
          tr = f(a.value);

          ///
        } else if (a is _Bounce<B>) {
          TailRec<A> Function(B) f1 = f;
          tr = (a).continuation().flatMap<A>(f);

          ///

        } else if (a is Cont<B, A>) {
          /// Version 1:
          /**
          TailRec<B> b = (a as Cont<B, A>).a;
          TailRec<A> Function(B) g = (a as Cont<B, A>).f; // ok
          tr = b.flatMap<A>((B x) =>
              g(x).flatMap<A>(f)); // flatMap<C>(TailRec<C> Function(A) c.f)
          */

          ///
          /// Version 2:
          TailRec<B> b = (a as Cont<B, A>).a; // bereits definiert
          TailRec<A> Function(B) f = (a as Cont<B, A>).f; // ok
          TailRec<C> Function(A) g =
              (a as Cont<A, C>).f; // g2 sollte anstelle f stehen
          TailRec<C> tr2 = b.flatMap<C>((B x) =>
              (f(x).flatMap<C>(g))); // flatMap<C>(TailRec<C> Function(A) c.f)
          tr = tr2 as TailRec<A>;

          ///   C _result1<C>(_Cont<A, C> c) =>
          ///       b.flatMap<C>((B x) => TailRec<A> Function(B) f(x).flatMap<C>(TailRec<C> Function(A) c.f)).result;

          /// TailRec<C>  flatMap<C>(TailRec<C> Function(A) g)
          ///       =>   _Cont<B, C>(b, (B x) => f(x).flatMap<C>( g));

        }
      }
    }
    return tr.value;
  }

  TailRec<B> map<B>(B Function(A) f) {
    return flatMap((a) => _Bounce(() => _Done<B>(f(a))));
  }

  TailRec<B> flatMap<B>(TailRec<B> Function(A) f);
}

class Cont<B, A> extends TailRec<A> {
  Cont(this.a, this.f);

  TailRec<B> a;
  TailRec<A> Function(B x) f;

  @override
  TailRec<C> flatMap<C>(TailRec<C> Function(A) f) =>
      Cont<B, C>(this.a, (B x) => this.f(x).flatMap<C>(f));
}

// die Typisierung stimmt
class _Done<A> extends TailRec<A> {
  _Done(this.value);

  @override
  _Bounce<B> flatMap<B>(TailRec<B> Function(A) f) =>
      _Bounce<B>(() => f(this.value));

  @override
  final A value;
}

// die Typisierung stimmt
class _Bounce<A> extends TailRec<A> {
  _Bounce(this.continuation);

  TailRec<A> Function() continuation;

  @override
  TailRec<B> flatMap<B>(TailRec<B> Function(A) f) => Cont<A, B>(this, f);
}

TailRec<A> done<A>(A x) => _Done<A>(x);

TailRec<A> tailcall<A>(TailRec<A> continuation()) => _Bounce<A>(continuation);

// -------------------------------------------------

class Defs {
  ///
  static TailRec<bool> odd(int n) =>
      n == 0 ? done(false) : tailcall(() => even(n - 1));
  static TailRec<bool> even(int n) =>
      n == 0 ? done(true) : tailcall(() => odd(n - 1));

  ///
  static bool badodd(int n) => n == 0 ? false : badeven(n - 1);
  static bool badeven(int n) => n == 0 ? true : badodd(n - 1);

  ///
  static TailRec<int> fib(int n) {
    if (n < 2) {
      return done<int>(n);
    } else {
      return tailcall<int>(() => fib(n - 1)).flatMap<int>((x) {
        return tailcall<int>(() => fib(n - 2)).map<int>((y) {
          return (x + y);
        });
      });
    }
  }
}

void main() {
  bool res1;
  res1 = (Defs.even(101).result<int, int>());
  print("Ergebnis von Odd/Even ist $res1");
  for (int z = 20; z < 35; z++) {
    num res2;
    res2 = Defs.fib(z).result<int, int>();
    print("Ergebnis von Fibonacci für $z ist $res2");
  }
}

/*

'Cont<List<Tupl<String, Termtype<String>>>, List<Tupl<String, Termtype<String>>>>' 
'_Done<List<Tupl<String, Termtype<String>>>>'


 */
