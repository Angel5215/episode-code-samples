/*:
 # Tagged Exercises

 1. Conditionally conform Tagged to ExpressibleByStringLiteral in order to restore the ergonomics of initializing our User’s email property. Note that ExpressibleByStringLiteral requires a couple other prerequisite conformances.
 */
// TODO
struct Tagged<Tag, RawValue> {
  var rawValue: RawValue
}

extension Tagged: Decodable where RawValue: Decodable {
  init(from decoder: any Decoder) throws {
    self.init(rawValue: try RawValue(from: decoder))
  }
}

extension Tagged: Equatable where RawValue: Equatable {
  static func == (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    lhs.rawValue == rhs.rawValue
  }
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
  typealias IntegerLiteralType = RawValue.IntegerLiteralType

  init(integerLiteral value: RawValue.IntegerLiteralType) {
    self.init(rawValue: RawValue(integerLiteral: value))
  }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
  typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType

  init(unicodeScalarLiteral value: RawValue.UnicodeScalarLiteralType) {
    self.init(rawValue: RawValue(unicodeScalarLiteral: value))
  }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
  typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType

  init(extendedGraphemeClusterLiteral value: RawValue.ExtendedGraphemeClusterLiteralType) {
    self.init(rawValue: RawValue(extendedGraphemeClusterLiteral: value))
  }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
  typealias StringLiteralType = RawValue.StringLiteralType

  init(stringLiteral value: RawValue.StringLiteralType) {
    self.init(rawValue: RawValue(stringLiteral: value))
  }
}

enum EmailTag {}
typealias Email = Tagged<EmailTag, String>

struct Subscription: Decodable {
  typealias Id = Tagged<Subscription, Int>

  let id: Id
  let ownerId: User.Id
}

let brandon = User(
  id: 1,
  name: "Brandon",
  email: "brandon@pointfree.co",
  subscriptionId: 1,
  age: 30
)

let stephen = User(
  id: 2,
  name: "Stephen",
  email: "stephen@pointfree.co",
  subscriptionId: nil,
  age: 35
)

let blob = User(
  id: 3,
  name: "Blob",
  email: "blob@pointfree.co",
  subscriptionId: 1,
  age: 32
)

let users = [blob, brandon, stephen]

brandon.email.rawValue
/*:
 2. Conditionally conform Tagged to Comparable and sort users by their id in descending order.
 */
// TODO
extension Tagged: Comparable where RawValue: Comparable {
  static func < (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

let sortedUsers = users.sorted { $0.id < $1.id }.map(\.name)

/*:
 3. Let’s explore what happens when you have multiple fields in a struct that you want to strengthen at the type level. Add an age property to User that is tagged to wrap an Int value. Ensure that it doesn’t collide with User.Id. (Consider how we tagged Email.)
 */
// TODO
struct User: Decodable {
  enum AgeTag {}
  typealias Id = Tagged<User, Int>
  typealias Age = Tagged<AgeTag, Int>

  let id: Id
  let name: String
  let email: Email
  let subscriptionId: Subscription.Id?
  let age: Age
}

let integerAge = 3
// brandon.age == brandon.id
/*:
 4. Conditionally conform Tagged to Numeric and alias a tagged type to Int representing Cents. Explore the ergonomics of using mathematical operators and literals to manipulate these values.
 */
// TODO

extension Tagged: AdditiveArithmetic where RawValue: AdditiveArithmetic {
  static var zero: Self {
    Self(rawValue: .zero)
  }

  static func + (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: lhs.rawValue + rhs.rawValue)
  }

  static func += (lhs: inout Self, rhs: Self) {
    lhs.rawValue += rhs.rawValue
  }

  static func - (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: lhs.rawValue - rhs.rawValue)
  }

  static func -= (lhs: inout Self, rhs: Self) {
    lhs.rawValue -= rhs.rawValue
  }
}

extension Tagged: Numeric where RawValue: Numeric {
  init?(exactly source: some BinaryInteger) {
    guard let rawValue = RawValue(exactly: source) else { return nil }
    self.init(rawValue: rawValue)
  }

  var magnitude: RawValue.Magnitude {
    rawValue.magnitude
  }

  static func * (lhs: Self, rhs: Self) -> Self {
    Self(rawValue: lhs.rawValue * rhs.rawValue)
  }

  static func *= (lhs: inout Self, rhs: Self) {
    lhs.rawValue *= rhs.rawValue
  }
}

extension Tagged: Hashable where RawValue: Hashable {}

extension Tagged: SignedNumeric where RawValue: SignedNumeric {}

extension Tagged: Sequence where RawValue: Sequence {
  consuming func makeIterator() -> RawValue.Iterator {
    rawValue.makeIterator()
  }
}

extension Tagged: Strideable where RawValue: Strideable {
  func distance(to other: Self) -> RawValue.Stride {
    rawValue.distance(to: other.rawValue)
  }

  func advanced(by n: RawValue.Stride) -> Self {
    Tagged(rawValue: rawValue.advanced(by: n))
  }
}

enum CentsTag {}
typealias Cents = Tagged<CentsTag, Int>

let cents = Cents(rawValue: 3)
let moreCents = Cents(rawValue: 11)
let result = cents + moreCents
result.rawValue
/*:
 5. Create a tagged type, Light<A> = Tagged<A, Color>, where A can represent whether the light is on or off. Write turnOn and turnOff functions to toggle this state.
 */
// TODO
struct Color {
  let red: Int
  let green: Int
  let blue: Int
}
enum On {}
enum Off {}
typealias Light<A> = Tagged<A, Color>

func turnOn(_ light: Light<Off>) -> Light<On> {
  Light<On>(rawValue: light.rawValue)
}

func turnOff(_ light: Light<On>) -> Light<Off> {
  Light<Off>(rawValue: light.rawValue)
}

let white = Color(red: 255, green: 255, blue: 255)
let lightsOn = Light<On>(rawValue: white)

turnOn(turnOff(lightsOn))
/*:
 6. Write a function, changeColor, that changes a Light’s color when the light is on. This function should produce a compiler error when passed a Light that is off.
 */
// TODO

func changeColor(_ color: Color, _ light: Light<On>) -> Light<On> {
  Light<On>(rawValue: color)
}

let lightOn = Light<On>(rawValue: .init(red: 3, green: 21, blue: 0))

//changeColor(.init(red: 0, green: 0, blue: 0), turnOff(lightOn))
/*:
 7. Create two tagged types with Double raw values to represent Celsius and Fahrenheit temperatures. Write functions celsiusToFahrenheit and fahrenheitToCelsius that convert between these units.
 */
// TODO
enum CelsiusTag {}
enum FahrenheitTag {}
typealias Celsius = Tagged<CelsiusTag, Double>
typealias Fahrenheit = Tagged<FahrenheitTag, Double>

func celsiusToFahrenheit(_ celsius: Celsius) -> Fahrenheit {
    let fahrenheitValue = (celsius.rawValue * 9/5) + 32
    return Fahrenheit(rawValue: fahrenheitValue)
}

func fahrenheitToCelsius(_ fahrenheit: Fahrenheit) -> Celsius {
    let celsiusValue = (fahrenheit.rawValue - 32) * 5/9
    return Celsius(rawValue: celsiusValue)
}

fahrenheitToCelsius(32).rawValue
/*:
 8. Create Unvalidated and Validated tagged types so that you can create a function that takes an Unvalidated<User> and returns an Optional<Validated<User>> given a valid user. A valid user may be one with a non-empty name and an email that contains an @.
 */
// TODO
enum UnvalidatedTag {}
enum ValidatedTag {}

typealias Unvalidated<A> = Tagged<UnvalidatedTag, A>
typealias Validated<A> = Tagged<ValidatedTag, A>

func validate(_ user: Unvalidated<User>) -> Validated<User>? {
  guard !user.rawValue.name.isEmpty, user.rawValue.email.rawValue.contains("@") else { return nil }
  return Validated(rawValue: user.rawValue)
}

let invalidUser = User(
  id: -3,
  name: "",
  email: "someemal@.com",
  subscriptionId: 3,
  age: 29
)

let validatedBrandon = validate(Unvalidated(rawValue: brandon))
validatedBrandon != nil

let validatedAnonymous = validate(Unvalidated(rawValue: invalidUser))
validatedAnonymous == nil
