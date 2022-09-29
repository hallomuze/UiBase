import Foundation

public struct UiBase {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

extension Array {
    public subscript(safe index: Int) -> Element? {
        // indices meaning range, 0.1.2.3 if 4 items exist
        // if index == 2
        //  [0..<4] ~= 2 will be true
        get {
            if indices ~= index {
               return self[index]
            }
            return nil
        }
        
        set {
            if let newValue = newValue {
                self[index] = newValue
            }
        }
    }
}
 
// Box_Closures
// ========================================
public typealias VoidHandler = () -> Void
public typealias VoidIntHandler = () -> Int
public typealias VoidFloatHandler = () -> Float
public typealias VoidDoubleHandler = () -> Double
public typealias VoidStringHandler = () -> String
public typealias BoolVoidHandler = (_ isAction: Bool) -> Void
 
public typealias TextHandler = (String) -> Void
public typealias BoolHandler = (Bool) -> Void
public typealias IntHandler = (Int) -> Void
public typealias DecimalHandler = (Decimal) -> Void
public typealias StringHandler = (String) -> Void
public typealias StringOptionalHandler = (String?) -> Void
public typealias UIntVoidHandler = (UInt) -> Void
public typealias StringStringHandler = (String) -> String
 
public protocol Letting { }
public protocol Applying { }

// =======================================
public extension Letting {
    func lets(closure: (Self) -> Void) {
        closure(self)
    }
}

extension NSObject: Letting { }
// ========================================

public extension Applying {
    @discardableResult
    func apply(closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Applying { }
// ========================================
