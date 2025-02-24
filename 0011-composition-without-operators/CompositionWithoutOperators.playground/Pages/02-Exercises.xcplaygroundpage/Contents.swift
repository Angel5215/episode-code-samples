/*:
 # Composition without Operators

 1. Write concat for functions (inout A) -> Void.
 */
func concat<A>(
  _ f: @escaping (inout A) -> Void,
  _ g: @escaping (inout A) -> Void,
  _ hs: ((inout A) -> Void)...
) -> (inout A) -> Void {
  { a in
    f(&a)
    g(&a)
    hs.forEach { h in h(&a) }
  }
}

func with<A>(_ a: inout A, _ f: @escaping (inout A) -> Void) {
  f(&a)
}

func inoutIncr(_ x: inout Int) {
  x += 1
}

func inoutSquare(_ x: inout Int) {
  x *= x
}

var value = 2
inoutIncr(&value)
inoutSquare(&value)
inoutIncr(&value)

var anotherValue = 2
concat(inoutIncr, inoutSquare, inoutIncr)

var yetAnotherValue = 2
with(&yetAnotherValue, concat(inoutIncr, inoutSquare, inoutIncr))


/*:
 2. Write concat for functions (A) -> A.
 */
// TODO

func concat<A>(
  _ f: @escaping (A) -> A,
  _ g: @escaping (A) -> A,
  _ hs: ((A) -> A)...
) -> (A) -> A {
  { a in
    var a = a
    a = f(a)
    a = g(a)
    hs.forEach { h in a = h(a) }
    return a
  }
}

func with<A, B>(_ a: A, _ f: @escaping (A) -> B) -> B {
  f(a)
}

with(2, concat(incr, square, incr))
/*:
 3. Write compose for backward composition. Recreate some of the examples from our functional setters episodes (part 1 and part 2) using compose and pipe.
 */
// TODO

func compose<A, B, C>(
  _ f: @escaping (B) -> C,
  _ g: @escaping (A) -> B
) -> (A) -> C {
  { a in
    f(g(a))
  }
}


