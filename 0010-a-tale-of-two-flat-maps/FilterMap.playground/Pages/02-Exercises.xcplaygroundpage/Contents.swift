/*:
 # A Tale of Two Flat-Maps, Exercises

 1. Define `filtered` as a function from `[A?]` to `[A]`.
 */
// TODO
func filtered<A>(_ array: [A?]) -> [A] {
  var filtered = [A]()
  for element in array {
    switch element {
    case let .some(value):
      filtered.append(value)
    case .none:
      continue
    }
  }
  return filtered
}

filtered([1, 2, 3, nil, 5])
/*:
 2. Define `partitioned` as a function from `[Either<A, B>]` to `(left: [A], right: [B])`. What does this function have in common with `filtered`?
 */
// TODO

enum Either<A, B> {
  case left(A)
  case right(B)
}

func partitioned<A, B>(_ array: [Either<A, B>]) -> (left: [A], right: [B]) {
  var partition = (left: [A](), right: [B]())

  for element in array {
    switch element {
    case let .left(a):
      partition.left.append(a)
    case let .right(b):
      partition.right.append(b)
    }
  }

  return partition
}

let values: [Either<Int, String>] = [.left(1), .left(2), .left(3), .right("Fire"), .left(5)]

partitioned(values)
/*:
 3. Define `partitionMap` on `Optional`.
 */
// TODO
extension Array {
  func partitionMap<A, B>(_ transform: (Element) -> Either<A, B>) -> (lefts: [A], rights: [B]) {
    var result = (lefts: [A](), rights: [B]())
    for x in self {
      switch transform(x) {
      case let .left(a):
        result.lefts.append(a)
      case let .right(b):
        result.rights.append(b)
      }
    }
    return result
  }
}

extension Optional {
  func partitionMap<A, B>(_ transform: (Wrapped) -> Either<A, B>) -> (left: A?, right: B?) {
    var result = (left: A?.none, right: B?.none)

    switch self {
    case let .some(wrapped):
        switch transform(wrapped) {
        case let .left(a):
          result.left = a
        case let .right(b):
          result.right = b
        }
    case .none:
      break
    }

    return result
  }
}

let value: Int? = 42
let result = value.partitionMap { $0 % 2 == 0 ? .left("Even") : .right("Odd") }

let emptyValue: Int? = nil
let emptyResult = emptyValue.partitionMap { $0 % 2 == 0 ? .left("Even") : .right("Odd") }
/*:
 4. Dictionary has `mapValues`, which takes a transform function from `(Value) -> B` to produce a new dictionary of type `[Key: B]`. Define `filterMapValues` on `Dictionary`.
 */
// TODO
//[0: ""].mapValues(<#T##transform: (String) throws -> T##(String) throws -> T#>)

// Dictionary<String, String>().filter(<#T##isIncluded: (Dictionary<String, String>.Element) throws -> Bool##(Dictionary<String, String>.Element) throws -> Bool#>)
extension Dictionary {
  func filterMapValues(_ p: @escaping (Value) -> Bool) -> [Key: Value] {
    var filtered = [Key: Value]()

    for (key, value) in self {
      if p(value) {
        filtered[key] = value
      } else {
        continue
      }
    }

    return filtered
  }
}

[0: "Hello", 1: "World", 3: "Even"]
  .filterMapValues { !$0.count.isMultiple(of: 2) }
/*:
 5. Define `partitionMapValues` on `Dictionary`.
 */
// TODO
extension Dictionary {
  func partitionMapValues<A, B>(_ p: @escaping (Value) -> Either<A, B>) -> (left: [Key: A], right: [Key: B]) {
    var partition = (left: [Key: A](), right: [Key: B]())
    for (key, value) in self {
      switch p(value) {
      case let .left(a):
        partition.left[key] = a
      case let .right(b):
        partition.right[key] = b
      }
    }
    return partition
  }
}

[0: "Hello", 1: "World", 3: "Even"]
  .partitionMapValues { $0.count.isMultiple(of: 2) ? .left($0) : .right($0) }

/*:
 6. Rewrite `filterMap` and `filter` in terms of `partitionMap`.
 */

extension Dictionary {
  func filterMap(_ p: @escaping (Value) -> Bool) -> [Key: Value] {
    partitionMapValues { p($0) ? .left($0) : .right($0) }.left
  }
}


/*:
 7. Is it possible to define `partitionMap` on `Either`?
 */

