// This implementation is considered as copyleft from public domain.

import Foundation

extension NSObject {
  public func with(_ configure: (Self) -> Void) -> Self {
    configure(self)
    return self
  }
}
