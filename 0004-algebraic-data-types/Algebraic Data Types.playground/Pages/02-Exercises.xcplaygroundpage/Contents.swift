/*:
 # Algebraic Data Types Exercises

 1. What algebraic operation does the function type `(A) -> B` correspond to? Try explicitly enumerating all the values of some small cases like `(Bool) -> Bool`, `(Unit) -> Bool`, `(Bool) -> Three` and `(Three) -> Bool` to get some intuition.
 */
// B^A

// (Bool) -> Bool  (2^2)
// f(true) -> true, f(false) -> true
// f(true) -> true, f(false) -> false
// f(true) -> false, f(false) -> true
// f(true) -> false, f(false) -> false

// (Unit) -> Bool (2^1)
// f(()) -> true
// f(()) -> false

// (Bool) -> Three (3^2)
// f(true) -> one, f(false) -> one
// f(true) -> one, f(false) -> two
// f(true) -> one, f(false) -> three
// f(true) -> two, f(false) -> one
// f(true) -> two, f(false) -> two
// f(true) -> two, f(false) -> three
// f(true) -> three, f(false) -> one
// f(true) -> three, f(false) -> two
// f(true) -> three, f(false) -> three

// (Three) -> Bool (2^3)
// f(one) -> true, f(two) -> true, f(three) -> true
// f(one) -> true, f(two) -> true, f(three) -> false
// f(one) -> true, f(two) -> false, f(three) -> true
// f(one) -> true, f(two) -> false, f(three) -> false
// f(one) -> false, f(two) -> true, f(three) -> true
// f(one) -> false, f(two) -> true, f(three) -> false
// f(one) -> false, f(two) -> false, f(three) -> true
// f(one) -> false, f(two) -> false, f(three) -> false
/*:
 2. Consider the following recursively defined data structure. Translate this type into an algebraic equation relating `List<A>` to `A`.
 */
indirect enum List<A> {
  case empty
  case cons(A, List<A>)
}
// TODO
 // List(A) = A * List(A) + 1

struct Pair<A, B> {
  let first: A
  let second: B
}
/*:
 3. Is `Optional<Either<A, B>>` equivalent to `Either<Optional<A>, Optional<B>>`? If not, what additional values does one type have that the other doesn’t?
 */
// TODO
enum Either<A, B> {
  case left(A)
  case right(B)
}

struct A {}
struct B {}
// (A + B) + 1
let _: Either<A,B>? = nil
let _: Either<A,B>? = .left(A())
let _: Either<A,B>? = .right(B())

// (A + 1) + (B + 1)
let _: Either<A?,B?> = .left(A())
let _: Either<A?,B?> = .left(nil)
let _: Either<A?,B?> = .right(B())
let _: Either<A?,B?> = .right(nil)
/*:
 4. Is `Either<Optional<A>, B>` equivalent to `Optional<Either<A, B>>`?
 */
// TODO
// (A + 1) + B
let _: Either<A?, B> = .left(nil)
let _: Either<A?, B> = .left(A())
let _: Either<A?, B> = .right(B())

// (A + B) + 1
let _: Either<A, B>? = nil
let _: Either<A, B>? = .left(A())
let _: Either<A, B>? = .right(B())

/*:
 5. Swift allows you to pass types, like `A.self`, to functions that take arguments of `A.Type`. Overload the `*` and `+` infix operators with functions that take any type and build up an algebraic representation using `Pair` and `Either`. Explore how the precedence rules of both operators manifest themselves in the resulting types.
 */
// TODO

func + <A, B>(lhs: A.Type, rhs: B.Type) -> Either<A, B>.Type {
  Either<A, B>.self
}

func *<A, B>(lhs: A.Type, rhs: B.Type) -> Pair<A, B>.Type {
  Pair<A, B>.self
}

Int.self * Bool.self + Bool.self

Either<A,B>?.self + Either<A?,B?>.self

Int.self * Int.self * (Int.self + String.self)
