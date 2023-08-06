import Foundation
import Alamofire
import Combine
import NetworkingInterface

extension NetworkingInterface.HTTPMethod {
    var alamofireValue: Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod(rawValue: self.rawValue)
    }
}

extension NetworkingInterface.ParameterEncoding {
    var alamofireValue: Alamofire.ParameterEncoding {
        switch self {
        case .url:
            return URLEncoding.default
        case .json:
            return JSONEncoding.default
        }
    }
}
