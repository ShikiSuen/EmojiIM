import Foundation

extension NSObject {
    func with(_ configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}
