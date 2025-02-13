/*:
 # Functional Setters Exercises

 1. As we saw with free `map` on `Array`, define free `map` on `Optional` and use it to compose setters that traverse into an optional field.
 */
// TODO
func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  { xs in xs.map(f) }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
  { xs in xs.map(f) }
}

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> ((C, B)) {
  { pair in (f(pair.0), pair.1) }
}

func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> ((A, C)) {
  { pair in (pair.0, f(pair.1)) }
}

precedencegroup BackwardsComposition {
  associativity: left
}
infix operator <<<: BackwardsComposition

func <<< <A, B, C>(_ f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
  { a in f(g(a)) }
}

let x: ((Int, String?), Int) = ((5, "Hello"), 3)

x.0.1.map { $0.lowercased() }
x |> (first <<< second <<< map) { $0.lowercased() }

let complexTuple = [(5, ["Hello", "World"]), (0, [nil]), (1, ["D"])]

print(
  complexTuple
    |> (map <<< second <<< map <<< map) { $0.lowercased() + "!" }
)
/*:
 2. Take a `struct`, _e.g._:

```
struct User {
  let name: String
}
```

 Write a setter for its property. Take (or add) another property, and add a setter for it. What are some potential issues with building these setters?
 */
// TODO
struct User {
  let name: String
  let age: Int
}

func updateName(_ f: @escaping (String) -> String) -> (User) -> User {
  { user in User(name: f(user.name), age: user.age) }
}

func updateAge(_ f: @escaping (Int) -> Int) -> (User) -> User {
  { user in User(name: user.name, age: f(user.age)) }
}

print(
  User(name: "Angel", age: 28)
    |> updateAge { $0 / 2 }
    |> updateName(zurry(flip(String.uppercased)))
)
/*:
 3. Take a `struct` with a nested `struct`, _e.g._:

```
struct Location {
  let name: String
}

struct User {
  let location: Location
}
```

 Write a setter for `userLocationName`. Now write setters for `userLocation` and `locationName`. How do these setters compose?
 */
// TODO

struct Location {
  let name: String
}

struct UserLocation {
  let location: Location
}

func userLocationName(_ f: @escaping (String) -> String) -> (UserLocation) -> UserLocation {
  { userLocation in UserLocation(location: Location(name: f(userLocation.location.name))) }
}

func userLocation(_ f: @escaping (Location) -> Location) -> (UserLocation) -> (UserLocation) {
  { userLocation in UserLocation(location: f(userLocation.location))}
}

func locationName(_ f: @escaping (String) -> String) -> (Location) -> Location {
  { location in Location(name: f(location.name)) }
}

print(UserLocation(location: Location(name: "Mexico")) |> userLocationName { $0.uppercased() })
print(UserLocation(location: Location(name: "Mexico")) |> userLocation { Location(name: $0.name.uppercased()) })
Location(name: "Mexico") |> locationName { $0.uppercased() }

print(
  UserLocation(location: Location(name: "Mexico"))
    |> (locationName { $0.uppercased() } |> userLocation)
)

let userLocation = UserLocation(location: Location(name: "Mexico"))
print(
  userLocation(locationName { $0.uppercased() })(userLocation)
)

/*:
 4. Do `first` and `second` work with tuples of three or more values? Can we write `first`, `second`,`third`, and `nth` for tuples of _n_ values?
 */
// TODO

func first<A, B, C, D>(_ f: @escaping (A) -> D) -> ((A, B, C)) -> (D, B, C) {
  { triple in (f(triple.0), triple.1, triple.2) }
}

func second<A, B, C, D>(_ f: @escaping (B) -> D) -> ((A, B, C)) -> (A, D, C) {
  { triple in (triple.0, f(triple.1), triple.2) }
}

func third<A, B, C, D>(_ f: @escaping (C) -> D) -> ((A, B, C)) -> (A, B, D) {
  { triple in (triple.0, triple.1, f(triple.2)) }
}

dump(
  (5, "Hello", true)
    |> first(incr)
    |> third { !$0 }
    |> second(zurry(flip(String.uppercased)))
)
/*:
 5. Write a setter for a dictionary that traverses into a key to set a value.
 */
// TODO
func traverse<Key, Value>(_ key: Key, _ f: @escaping (Value?) -> Value?) -> ([Key: Value]) -> [Key: Value] {
  { dictionary in
    var dictionary = dictionary
    dictionary[key] = f(dictionary[key])
    return dictionary
  }
}

// func map<Key, Value>(

["Hello": "World", "Hallo": "World"]
  |> traverse("Hello", { $0?.lowercased() })
  |> traverse("Hallo", { _ in nil })
/*:
 6. What is the difference between a function of the form `((A) -> B) -> (C) -> (D)` and one of the form `(A) -> (B) -> (C) -> D`?
 */
// TODO
// First one receives a transformation ((A) -> B) and returns a function from (C) -> D. The second one receives a value A, then returns a function from B that returns another function from (C) -> D.
