import Foundation
import SharedServicesInterface

public struct EnterUsernameDependencies: HasUserService {
    public let userService: UserServiceProtocol

    public init(userService: UserServiceProtocol) {
        self.userService = userService
    }
}
