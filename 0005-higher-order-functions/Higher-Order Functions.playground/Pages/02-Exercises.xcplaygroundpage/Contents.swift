/*:
 # Higher-Order Functions Exercises

 1. Write `curry` for functions that take 3 arguments.
 */
// TODO
func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}

func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
  { a in { b in { c in f(a, b, c) }}}
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  { b in { a in f(a)(b) }}
}

func flip<A, B, C, D>(_ f: @escaping (A) -> (B, C) -> D) -> (B, C) -> (A) -> D {
  { b, c in { a in f(a)(b,c) }}
}

URLCache(memoryCapacity: 10, diskCapacity: 10, directory: nil)
let cacheBuilder = curry(URLCache.init(memoryCapacity:diskCapacity:directory: ))
let kilobyteCache = cacheBuilder(1024)(1024)

let downloadsDirectory = flip(FileManager.urls)(.downloadsDirectory, .userDomainMask)
let urls = .default |> downloadsDirectory
let directory = urls.first!

directory |> kilobyteCache
/*:
 2. Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using `curry`, `zurry`, `flip`, or by hand.
 */
// TODO
[String].joined

let join = flip([String].joined)
let joinWithCommas = join(", ")
joinWithCommas(["Hello", "World"])
/*:
 3. Explore the associativity of function arrow `->`. Is it fully associative, _i.e._ is `((A) -> B) -> C` equivalent to `(A) -> ((B) -> C)`, or does it associate to only one side? Where does it parenthesize as you build deeper, curried functions?
 */

// The function arrow (->) in Swift is right-associative.
// Parentheses group function types explicitly, but when omitted, Swift automatically assumes right-associativity.
// ((A) -> B) -> C and (A) -> ((B) -> C) are not equivalent because they represent fundamentally different function structures.
// Right-associativity is ideal for currying and functional composition, which are common patterns in Swift.
/*:
 4. Write a function, `uncurry`, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?
 */
// TODO
func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
  { a, b in f(a)(b) }
}
/*:
 5. Write `reduce` as a curried, free function. What is the configuration _vs._ the data?
 */
// TODO

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> ([B]) {
  return { $0.map(f) }
}
[1, 2, 3].map(incr >>> square)
map(incr >>> square)([1, 2, 3])

func reduce<A,B>() -> ([A], [B]) {
  ([], [])
}

func reduce<Result, Element>(_ f: @escaping (Result, Element) -> Result) -> (Result) -> ([Element]) -> Result {
  //{ result, data in data.reduce(result, f) }
  { initialResult in { data in data.reduce(initialResult, f) }}
}

func string(acc: String, from number: Double) -> String {
  joinWithCommas([acc, String(number)])
}

[1, 2, 3].reduce(0, +)
let x = reduce(string)("")([1.0, 2.0, 3.0, 4.0])



/*:
 6. In programming languages that lack sum/enum types one is tempted to approximate them with pairs of optionals. Do this by defining a type `struct PseudoEither<A, B>` of a pair of optionals, and prevent the creation of invalid values by providing initializers.

    This is “type safe” in the sense that you are not allowed to construct invalid values, but not “type safe” in the sense that the compiler is proving it to you. You must prove it to yourself.
 */
// TODO
enum Either<A, B> {
  case left(A)
  case right(B)
}

Either<Bool, Void>.left(true)
Either<Bool, Void>.left(false)
Either<Bool, Void>.right(())

struct PseudoEither<A, B> {
  let left: A?
  let right: B?

  init(left: A) {
    self.left = left
    self.right = nil
  }

  init(right: B) {
    self.right = right
    self.left = nil
  }
}

PseudoEither<Bool, Void>(left: true)
PseudoEither<Bool, Void>(left: false)
PseudoEither<Bool, Void>(right: ())
/*:
 7. Explore how the free `map` function composes with itself in order to transform a nested array. More specifically, if you have a doubly nested array `[[A]]`, then `map` could mean either the transformation on the inner array or the outer array. Can you make sense of doing `map >>> map`?
 */
// TODO

import AppKit

extension NSView {
  func subviews() -> [NSView] {
    self.subviews
  }
}

func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
  { { a in f(a)() }}
}

func zurry<A>(_ f: @escaping () -> A) -> A {
  f()
}

let directSubviews = zurry(flip(NSView.subviews))

func f(_ number: Int) -> String { String(number) }

// f: (Int) -> String
// map: ((A) -> B) -> ([A]) -> [B]
// map >>> map => map(map(f)) => map(([A]) -> [B]) => ([[A]]) -> [[B]]

(map >>> map)(square >>> String.init)
let value1 = [[1, 2, 3]] |> map(map(square >>> String.init))
let value2 = [[1, 2, 3]] |> (map >>> map)(square >>> String.init)
value1 == value2
value1 == [["1", "4", "9"]]
