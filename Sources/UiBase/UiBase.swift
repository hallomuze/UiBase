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
typealias VoidHandler = () -> Void
typealias VoidIntHandler = () -> Int
typealias VoidFloatHandler = () -> Float
typealias VoidDoubleHandler = () -> Double
typealias VoidStringHandler = () -> String
typealias BoolVoidHandler = (_ isAction: Bool) -> Void
 
typealias TextHandler = (String) -> Void
typealias BoolHandler = (Bool) -> Void
typealias IntHandler = (Int) -> Void
typealias DecimalHandler = (Decimal) -> Void
typealias StringHandler = (String) -> Void
typealias StringOptionalHandler = (String?) -> Void
typealias UIntVoidHandler = (UInt) -> Void
typealias StringStringHandler = (String) -> String
 
public protocol Letting { }
public protocol Applying { }

// =======================================
extension Letting {
    func lets(closure: (Self) -> Void) {
        closure(self)
    }
}

extension NSObject: Letting { }
// ========================================

extension Applying {
    @discardableResult
    func apply(closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Applying { }
// ========================================
