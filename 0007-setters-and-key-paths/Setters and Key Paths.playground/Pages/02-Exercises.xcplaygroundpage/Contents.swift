/*:
 # Setters and Key Paths Exercises

 1. In this episode we used `Dictionary`’s subscript key path without explaining it much. For a `key: Key`, one can construct a key path `\.[key]` for setting a value associated with `key`. What is the signature of the setter `prop(\.[key])`? Explain the difference between this setter and the setter `prop(\.[key]) <<< map`, where `map` is the optional map.
 */
// TODO
let dictionary = ["Hello": "World"]

func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
  { a in a.map(f) }
}

func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root)
  -> Root {
    return { update in
      { root in
        var copy = root
        copy[keyPath: kp] = update(copy[keyPath: kp])
        return copy
      }
    }
}

// WritableKeyPath<[String: Int], Int>
\[String:Int].["Hello"]

//(@escaping (Int?) -> Int?) -> ([String: Int]) -> [String: Int]
prop(\[String:Int].["Hello"])

// prop(\.[key]) -> (@escaping (Value?) -> Value?) -> ([Key: Value]) -> [Key: Value]


// ((String?) -> String?) -> ([String: String)] -> [String: String]
(prop(\[String:String].["Hello"]))

// ((String) -> String) -> ([String: String)] -> [String: String]
(prop(\[String:String].["Hello"]) <<< map)

dictionary
  |> (prop(\[String:String].["Hello"])) { $0?.uppercased() }

dictionary
  |> (prop(\[String:String].["Hello"]) <<< map) { $0.uppercased() }



/*:
 2. The `Set<A>` type in Swift does not have any key paths that we can use for adding and removing values. However, that shouldn't stop us from defining a functional setter! Define a function `elem` with signature `(A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>`, which is a functional setter that allows one to add and remove a value `a: A` to a set by providing a transformation `(Bool) -> Bool`, where the input determines if the value is already in the set and the output determines if the value should be included.
 */
// TODO
func elem<A>(_ value: A) -> (@escaping (Bool) -> Bool) -> (Set<A>) -> Set<A> {
  { include in
    { data in
      let contains = data.contains(value)
      let shouldInclude = include(contains)
      if shouldInclude {
        return data.union([value])
      } else {
        return data.subtracting([value])
      }
    }
  }
}

[1, 2, 3]
  |> (elem(42)){ _ in true }
/*:
 3. Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler generated key path. Use array’s subscript key path to uppercase the first favorite food for a user. What happens if the user’s favorite food array is empty?
 */
// TODO
struct Food {
  var name: String
}

struct Location {
  var name: String
}

struct User {
  var favoriteFoods: [Food]
  var location: Location
  var name: String
}

let user = User(
  favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")],
  location: Location(name: "Brooklyn"),
  name: "Blob"
)

dump(user
  |> (prop(\User.favoriteFoods[0].name)) { $0.uppercased() })

// Error if array is empty
/*:
 4. Recall from a [previous episode](https://www.pointfree.co/episodes/ep5-higher-order-functions) that the free `filter` function on arrays has the signature `((A) -> Bool) -> ([A]) -> [A]`. That’s kinda setter-like! What does the composed setter `prop(\\User.favoriteFoods) <<< filter` represent?
 */
// TODO
func filter<A>(_ f: @escaping (A) -> Bool) -> ([A]) -> [A] {
  { xs in xs.filter(f) }
}

[1, 2, 3, 4, 5]
  |> filter { $0 < 3 }

// f <<< g => g(f(x))

dump(
  user
    |> (prop(\User.favoriteFoods) <<< filter) { $0.name.starts(with: "T")}
)

// prop(\User.favoriteFoods) ==>  (([Food]) -> ([Food])) -> (User) -> User
/*:
 5. Define the `Result<Value, Error>` type, and create `value` and `error` setters for safely traversing into those cases.
 */
// TODO
enum Result<Value, Err> {
  case value(Value)
  case error(Err)
}

func value<Value, Err>(_ f: @escaping (Value) -> Value) -> (Result<Value, Err>) -> Result<Value, Err> {
  { result in
    switch result {
    case let .error(err): .error(err)
    case let .value(value): .value(f(value))
    }
  }
}

func error<Value, Err>(_ f: @escaping (Err) -> Err) -> (Result<Value, Err>) -> Result<Value, Err> {
  { result in
    switch result {
    case let .error(err): .error(f(err))
    case let .value(value): .value(value)
    }
  }
}

Result<String, Int>.value("Hello")
  |> value { $0.uppercased() }

Result<String, Int>.error(3)
  |> error(incr)
/*:
 6. Is it possible to make key path setters work with `enum`s?
 */
// TODO

enum Either<A, B> {
  case left(A)
  case right(B)

  var left: A? {
    get {
      guard case let .left(a) = self else { return nil }
      return a
    } set {
      newValue.map { newValue in
        self = .left(newValue)
      }
    }
  }

  var right: B? {
    get {
      guard case let .right(b) = self else { return nil }
      return b
    } set {
      newValue.map { newValue in
        self = .right(newValue)
      }
    }
  }
}

Either<Bool, Int>.left(true)
  |> (prop(\.left) <<< map) { !$0 }

Either<Bool, Int>.right(41)
  |> (prop(\.right) <<< map)(incr)

/*:
 7. Redefine some of our setters in terms of `inout`. How does the type signature and composition change?
 */
// TODO
