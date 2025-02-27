import Foundation

/// Matcher is container class, responsible for storing and resolving comparators for given types.
public class Matcher {
    /// Shared **Matcher** instance
    nonisolated(unsafe) public static let `default` = Matcher()
    /// [Internal] Matchers storage
    private var matchers: [(Mirror,Any)] = []
    /// [Internal] file where comparison faiure should be recorded
    private var file: StaticString?
    /// [Internal] line where comparison faiure should be recorded
    private var line: UInt?
    /// [Internal] matcher fatal error handler
    public static var fatalErrorHandler: (String, StaticString, UInt) -> Void = { _,_,_ in}

    /// Create new clean matcher instance.
    public init() {
        registerBasicTypes()
        register(GenericAttribute.self) { [unowned self] (a, b) -> Bool in
            return a.compare(a.value,b.value,self)
        }
    }

    /// Creante new matcher instance, copying existing comparator from another instance.
    ///
    /// - Parameter matcher: other matcher instance
    public init(matcher: Matcher) {
        self.matchers = matcher.matchers
    }

    /// Registers array comparators for all basic types, their optional versions
    /// and arrays containing elements of that type. For all of them, no manual
    /// registering of comparator is needed.
    ///
    /// We defined basic types as:
    ///
    /// - Bool
    /// - String
    /// - Float
    /// - Double
    /// - Character
    /// - Int
    /// - Int8
    /// - Int16
    /// - Int32
    /// - Int64
    /// - UInt
    /// - UInt8
    /// - UInt16
    /// - UInt32
    /// - UInt64
    ///
    /// Called automatically in every Matcher init.
    ///
    internal func registerBasicTypes() {
        register([Bool].self)
        register([String].self)
        register([Float].self)
        register([Double].self)
        register([Character].self)
        register([Int].self)
        register([Int8].self)
        register([Int16].self)
        register([Int32].self)
        register([Int64].self)
        register([UInt].self)
        register([UInt8].self)
        register([UInt16].self)
        register([UInt32].self)
        register([UInt64].self)
        register([Data].self)
        register([Bool?].self)
        register([String?].self)
        register([Float?].self)
        register([Double?].self)
        register([Character?].self)
        register([Int?].self)
        register([Int8?].self)
        register([Int16?].self)
        register([Int32?].self)
        register([Int64?].self)
        register([UInt?].self)
        register([UInt8?].self)
        register([UInt16?].self)
        register([UInt32?].self)
        register([UInt64?].self)
        register([Data?].self)

        // Types
        register(Bool.self)
        register(String.self)
        register(Float.self)
        register(Double.self)
        register(Character.self)
        register(Int.self)
        register(Int8.self)
        register(Int16.self)
        register(Int32.self)
        register(Int64.self)
        register(UInt.self)
        register(UInt8.self)
        register(UInt16.self)
        register(UInt32.self)
        register(UInt64.self)
        register(Data.self)
        register(Bool?.self)
        register(String?.self)
        register(Float?.self)
        register(Double?.self)
        register(Character?.self)
        register(Int?.self)
        register(Int8?.self)
        register(Int16?.self)
        register(Int32?.self)
        register(Int64?.self)
        register(UInt?.self)
        register(UInt8?.self)
        register(UInt16?.self)
        register(UInt32?.self)
        register(UInt64?.self)
        register(Data?.self)

        // Types
        register(Any.Type.self) { _, _ in return true }
        register(Bool.Type.self)
        register(String.Type.self)
        register(Float.Type.self)
        register(Double.Type.self)
        register(Character.Type.self)
        register(Int.Type.self)
        register(Int8.Type.self)
        register(Int16.Type.self)
        register(Int32.Type.self)
        register(Int64.Type.self)
        register(UInt.Type.self)
        register(UInt8.Type.self)
        register(UInt16.Type.self)
        register(UInt32.Type.self)
        register(UInt64.Type.self)
        register(Data.Type.self)
        register(Any?.Type.self) { _, _ in return true }
        register(Bool?.Type.self)
        register(String?.Type.self)
        register(Float?.Type.self)
        register(Double?.Type.self)
        register(Character?.Type.self)
        register(Int?.Type.self)
        register(Int8?.Type.self)
        register(Int16?.Type.self)
        register(Int32?.Type.self)
        register(Int64?.Type.self)
        register(UInt?.Type.self)
        register(UInt8?.Type.self)
        register(UInt16?.Type.self)
        register(UInt32?.Type.self)
        register(UInt64?.Type.self)
        register(Data?.Type.self)
    }

    public func set(file: StaticString?, line: UInt?) {
        self.file = file
        self.line = line
    }

    public func setupCorrentFileAndLine(file: StaticString = #file, line: UInt = #line) {
        self.set(file: file, line: line)
    }

    public func clearFileAndLine() {
        self.set(file: nil, line: nil)
    }

    public func onFatalFailure(_ message: String) {
        guard let file = self.file, let line = self.line else { return }
        Matcher.fatalErrorHandler(message, file, line)
    }

    /// Registers comparator for given type **T**.
    ///
    /// Comparator is a closure of `(T,T) -> Bool`.
    ///
    /// When several comparators for same type  are registered to common
    /// **Matcher** instance - it will resolve the most receont one.
    ///
    /// - Parameters:
    ///   - valueType: compared type
    ///   - match: comparator closure
    public func register<T>(_ valueType: T.Type, match: @escaping (T,T) -> Bool) {
        let mirror = Mirror(reflecting: valueType)
        matchers.append((mirror, match as Any))
    }

    /// Registers comparator for type, like comparing Int.self to Int.self. These types of comparators always returns true. Register like: `Matcher.default.register(CustomType.Type.self)`
    ///
    /// - Parameter valueType: Type.Type.self
    public func register<T>(_ valueType: T.Type.Type) {
        self.register(valueType, match: { _, _ in return true })
    }

    /// Register default comparatot for Equatable types. Required for generic mocks to work.
    ///
    /// - Parameter valueType: Equatable type
    public func register<T>(_ valueType: T.Type) where T: Equatable {
        let mirror = Mirror(reflecting: valueType)
        matchers.append((mirror, comparator(for: T.self) as Any))
    }

    /// Returns comparator closure for given type (if any).
    ///
    /// Comparator is a closure of `(T,T) -> Bool`.
    ///
    /// When several comparators for same type  are registered to common
    /// **Matcher** instance - it will resolve the most receont one.
    ///
    /// - Parameter valueType: compared type
    /// - Returns: comparator closure
    public func comparator<T>(for valueType: T.Type) -> ((T,T) -> Bool)? {
        let mirror = Mirror(reflecting: valueType)
        let comparator = matchers.reversed().first { (current, _) -> Bool in
            return current.subjectType == mirror.subjectType
        }?.1

        return comparator as? (T,T) -> Bool
    }

    /// Default Sequence comparator, compares count, and then depending on sequence type:
    /// - for Arrays, elements will be compared element by element (verifying order as well)
    /// - other Sequences would be treated as unordered, so every element has to have matching element
    ///
    /// - Parameter valueType: Sequence type
    /// - Returns: comparator closure
    public func comparator<T>(for valueType: T.Type) -> ((T,T) -> Bool)? where T: Sequence {
        let mirror = Mirror(reflecting: valueType)
        let comparator = matchers.reversed().first { (current, _) -> Bool in
            return current.subjectType == mirror.subjectType
        }?.1

        if let compare = comparator as? (T,T) -> Bool {
            return compare
        } else if let compare = self.comparator(for: T.Element.self) {
            return { (l: T, r: T) -> Bool in
                let lhs = l.map { $0 }
                let rhs = r.map { $0 }
                guard lhs.count == rhs.count else { return false }

                if valueType is [T.Element].Type {
                    // Compare as ordered sequence:
                    for i in 0..<lhs.count {
                        guard compare(lhs[i],rhs[i]) else { return false }
                    }

                    return true
                } else {
                    // Compare as unordered sequence:
                    var lbuff = lhs
                    var rbuff = rhs

                    while !lbuff.isEmpty {
                        let rIndex = rbuff.firstIndex { compare(lbuff[0],$0) }
                        if let rIndex = rIndex {
                            // There is a match, remove both matching elements.
                            rbuff.remove(at: rIndex)
                            lbuff.remove(at: 0)
                        } else {
                            // There is no matching element - stop execution.
                            return false
                        }
                    }

                    return lbuff.isEmpty && rbuff.isEmpty
                }
            }
        } else {
            return nil
        }
    }

    /// Default Equatable comparator, compares if elements are equal.
    ///
    /// - Parameter valueType: Equatable type
    /// - Returns: comparator closure
    public func comparator<T>(for valueType: T.Type) -> ((T,T) -> Bool)? where T: Equatable {
        return { $0 == $1 }
    }

    /// Default Equatable Sequence comparator, compares count, and then for every element equal element.
    ///
    /// - Parameter valueType: Equatable Sequence type
    /// - Returns: comparator closure
    public func comparator<T>(for valueType: T.Type) -> ((T,T) -> Bool)? where T: Equatable, T: Sequence {
        return { $0 == $1 }
    }
}
