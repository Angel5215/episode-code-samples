/*:
 # Tagged Exercises

 1. Conditionally conform Tagged to ExpressibleByStringLiteral in order to restore the ergonomics of initializing our User’s email property. Note that ExpressibleByStringLiteral requires a couple other prerequisite conformances.
 */
// TODO
struct Tagged<Tag, RawValue> {
  let rawValue: RawValue
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

struct User: Decodable {
  typealias Id = Tagged<User, Int>

  let id: Id
  let name: String
  let email: Email
  let subscriptionId: Subscription.Id?
}


let brandon = User(
  id: 1,
  name: "Brandon",
  email: "brandon@pointfree.co",
  subscriptionId: 1
)

brandon.email.rawValue
/*:
 2. Conditionally conform Tagged to Comparable and sort users by their id in descending order.
 */
// TODO
/*:
 3. Let’s explore what happens when you have multiple fields in a struct that you want to strengthen at the type level. Add an age property to User that is tagged to wrap an Int value. Ensure that it doesn’t collide with User.Id. (Consider how we tagged Email.)
 */
// TODO
/*:
 4. Conditionally conform Tagged to Numeric and alias a tagged type to Int representing Cents. Explore the ergonomics of using mathematical operators and literals to manipulate these values.
 */
// TODO
/*:
 5. Create a tagged type, Light<A> = Tagged<A, Color>, where A can represent whether the light is on or off. Write turnOn and turnOff functions to toggle this state.
 */
// TODO
/*:
 6. Write a function, changeColor, that changes a Light’s color when the light is on. This function should produce a compiler error when passed a Light that is off.
 */
// TODO
/*:
 7. Create two tagged types with Double raw values to represent Celsius and Fahrenheit temperatures. Write functions celsiusToFahrenheit and fahrenheitToCelsius that convert between these units.
 */
// TODO
/*:
 8. Create Unvalidated and Validated tagged types so that you can create a function that takes an Unvalidated<User> and returns an Optional<Validated<User>> given a valid user. A valid user may be one with a non-empty name and an email that contains an @.
 */
// TODO
