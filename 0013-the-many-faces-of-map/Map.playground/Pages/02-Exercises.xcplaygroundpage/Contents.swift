/*:
 # The Many Faces of Map Exercises

 1. Implement a `map` function on dictionary values, i.e.

    ```
    map: ((V) -> W) -> ([K: V]) -> [K: W]
    ```

    Does it satisfy `map(id) == id`?

 */
// TODO
func map<K, V, W>(_ f: @escaping (V) -> W) -> ([K: V]) -> [K: W] {
  { dictionary in
    var result = [K: W]()
    for (key, value) in dictionary {
      result[key] = f(value)
    }
    return result
  }
}

func id<A>(_ a: A) -> A { a }

id(3)

["Hello": "World"]
  |> map(\.count)

["Hello": "World"] |> map(id)
id(["Hello": "World"])

(["Hello": "World"] |> map(id)) == id(["Hello": "World"])

/*:
 2. Implement the following function:

    ```
    transformSet: ((A) -> B) -> (Set<A>) -> Set<B>
    ```

    We do not call this `map` because it turns out to not satisfy the properties of `map` that we saw in this episode. What is it about the `Set` type that makes it subtly different from `Array`, and how does that affect the genericity of the `map` function?
 */
// TODO
func transformSet<A, B>(_ f: @escaping (A) -> B) -> (Set<A>) -> Set<B> {
  { xs in
    var result = Set<B>()
    for x in xs {
      result.insert(f(x))
    }
    return result
  }
}

[1, 2, 3, 1, 2, 3] as Set<Int>
  |> transformSet(id)

// Set has a uniqueness restriction. When f: (A) -> B produces values that are the same, the set automatically discards them which is different from Arrays which would retain them.
/*:
 3. Recall that one of the most useful properties of `map` is the fact that it distributes over compositions, _i.e._ `map(f >>> g) == map(f) >>> map(g)` for any functions `f` and `g`. Using the `transformSet` function you defined in a previous example, find an example of functions `f` and `g` such that:

    ```
    transformSet(f >>> g) != transformSet(f) >>> transformSet(g)
    ```

    This is why we do not call this function `map`.
 */
struct A: Equatable, Hashable {
  let value: Double

  init(_ value: Double) {
    self.value = value
  }

  static func == (lhs: A, rhs: A) -> Bool {
    lhs.value.rounded() == rhs.value.rounded()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(value.rounded())
  }
}

func f(_ x: A) -> A {
  A(x.value / 10)
}

func g(_ x: A) -> A {
  A(x.value * 10)
}

f(A(11.2)) == f(A(12.3))
f(A(13.4)) == f(A(12.3))

dump(f(A(11.2))).value
dump(f(A(12.3))).value
dump(f(A(13.4))).value
print("--")
dump(g(f(A(11.2)))).value
dump(g(f(A(12.3)))).value
dump(g(f(A(13.4)))).value


Set([A(11.2), A(12.3), A(13.4)])
  |> transformSet(f)
  |> transformSet(g)
  |> transformSet(\.value)

Set([A(11.2), A(12.3), A(13.4)])
  |> transformSet(f >>> g)
  |> transformSet(\.value)
/*:
 4. There is another way of modeling sets that is different from `Set<A>` in the Swift standard library. It can also be defined as function `(A) -> Bool` that answers the question "is `a: A` contained in the set." Define a type `struct PredicateSet<A>` that wraps this function. Can you define the following?

     ```
     map: ((A) -> B) -> (PredicateSet<A>) -> PredicateSet<B>
     ```

     What goes wrong?
 */
// TODO
struct PredicateSet<A> {
  let isContained: (A) -> Bool
}

let set = PredicateSet<Int> { $0 > 3 }
set.isContained(8)
set.isContained(2)

//func map<A, B>(_ f: @escaping (A) -> B) -> (PredicateSet<A>) -> PredicateSet<B> {
//  { xs in
//    // (A) -> Bool
//    // xs.isContained
//
//    // f: (A) -> B
//
//    // (B) -> Bool
//    // PredicateSet<B> {
//    // }
//  }
//}


/*:
 5. Try flipping the direction of the arrow in the previous exercise. Can you define the following function?

    ```
    fakeMap: ((B) -> A) -> (PredicateSet<A>) -> PredicateSet<B>
    ```
 */
// TODO

func fakeMap<A, B>(_ f: @escaping (B) -> A) -> (PredicateSet<A>) -> PredicateSet<B> {
  { xs in
    PredicateSet(isContained: f >>> xs.isContained)
  }
}
/*:
 6. What kind of laws do you think `fakeMap` should satisfy?
 */
// TODO
// ID possibly? Backwards composition??
/*:
 7. Sometimes we deal with types that have multiple type parameters, like `Either` and `Result`. For those types you can have multiple `map`s, one for each generic, and no one version is “more” correct than the other. Instead, you can define a `bimap` function that takes care of transforming both type parameters at once. Do this for `Result` and `Either`.
 */
// TODO

enum Either<A, B> {
  case left(A)
  case right(B)
}

func map<A, B, C>(_ f: @escaping (A) -> C) -> (Either<A, B>) -> Either<C, B> {
  { either in
    switch either {
    case let .left(a): .left(f(a))
    case let .right(b): .right(b)
    }
  }
}

func bimap<Success, Failure, NewSuccess, NewFailure>(
  _ f: @escaping (Success) -> NewSuccess,
  _ g: @escaping (Failure) -> NewFailure
) -> (Result<Success, Failure>) -> Result<NewSuccess, NewFailure> {
  { result in
    switch result {
    case let .success(success): .success(f(success))
    case let .failure(error): .failure(g(error))
    }
  }
}

func bimap<A, B, C, D>(
  _ f: @escaping (A) -> C,
  _ g: @escaping (B) -> D
) -> (Either<A, B>) -> Either<C, D> {
  { either in
    switch either {
    case let .left(a): .left(f(a))
    case let .right(b): .right(g(b))
    }
  }
}

func string(_ x: Int) -> String {
  String(x)
}

func count(_ x: String) -> Int {
  x.count
}

Either<Int, String>.left(2)
  |> bimap(string, count)
Either<Int, String>.right("Hello")
  |> bimap(string, count)



