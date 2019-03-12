import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

public class Requester<T> {
    
    public enum Status {
        case resolved
        case rejected
        case pending
        case cancelled
    }
    
    public enum Kind {
        case json
        case image
    }
    
    public enum Result {
        case success(T)
        case error(RequesterError)
        case cancelled
    }
    
    var errorCodes: [Int: String] {
        return [
            NSURLErrorNotConnectedToInternet: "no_internet",
            404: "not_found",
            500: "general_error"
        ]
    }
    
    private var successCallbacks: [((T) -> Void)] = []
    private var errorCallbacks: [((RequesterError) -> Void)] = []
    private var completeCallbacks: [((Result) -> Void)] = []
    
    private var value: AnyObject??
    private var status: Status = .pending
    
    private var r: DataRequest?
    
    public init(_ r: DataRequest? = nil, responseType: Kind = .json, processor: ((JSON) -> (T?, RequesterError?))? = nil) {
        if let req = r {
            self.r = req
            
            RequesterApi.requestsCount += 1
            
            switch responseType {
            case .json:
                r!.responseJSON() { response in
                    if self.handleGeneralResponseError(response) {
                        let result = response.result.value!
                        let json = JSON(result)
                        
                        if let result = processor?(json) {
                            let _ = self.resolve(value: result.0, error: result.1)
                        } else {
                            let _ = self.resolve(value: Nil(T.self), error: nil)
                        }
                    }
                }
            case .image:
                r!.responseImage { response in
                    if self.handleGeneralResponseError(response) {
                        let _ = self.resolve(value: response.result.value as? T, error: nil)
                    }
                }
            }
            
            req.response { response in
                RequesterApi.requestsCount -= 1
            }
        }
    }
    
    private func handleGeneralResponseError<T>(_ response: DataResponse<T>) -> Bool {
        var code: Int?
        var msg: String?
        
        var jsonDataResponse: JSON?
        if let data = response.data {
            jsonDataResponse = try? JSON(data: data)
        }
        
        if response.result.value == nil && jsonDataResponse == nil {
            let err = response.error as? URLError
            if err != nil && err!.code == .cancelled {
                self.status = .cancelled
                self.completeCallbacks.forEach { self.executeCompleteCallback($0) }
                return false
            } else if err != nil && errorCodes[err!.errorCode] != nil {
                code = err!.errorCode
                msg = errorCodes[err!.errorCode]
            } else {
                code = response.response?.statusCode ?? 500
                msg = errorCodes[code!] ?? errorCodes[500]!
            }
        } else {
            let json = jsonDataResponse ?? JSON(response.result.value!)
            code = json["code"].int ?? response.response?.statusCode ?? 500
            msg = json["errorMessage"].string
        }
        
        if code != nil && msg != nil {
            let err = RequesterError(code: code!, message: msg!)
            let _ = self.resolve(value: nil, error: err)
            return false
        }
        
        return true
    }
    
    public func success(callback: @escaping (T) -> Void) -> Requester {
        if status == .resolved {
            callback(value as! T)
        } else {
            successCallbacks.append(callback)
        }
        return self
    }
    
    public func error(callback: @escaping (RequesterError) -> Void) -> Requester {
        if status == .rejected {
            callback(value as! RequesterError)
        } else {
            errorCallbacks.append(callback)
        }
        return self
    }
    
    public func complete(callback: @escaping (Result) -> Void) -> Requester {
        if status != .pending {
            executeCompleteCallback(callback)
        } else {
            completeCallbacks.append(callback)
        }
        return self
    }
    
    public func resolve(value: T?, error: RequesterError?) -> Requester {
        if status != .pending { return self }
        
        self.value = error ?? value as AnyObject
        
        if error != nil {
            status = .rejected
            errorCallbacks.forEach{ $0(error!) }
        } else {
            status = .resolved
            successCallbacks.forEach { $0(value!) }
        }
        
        completeCallbacks.forEach { executeCompleteCallback($0) }
        return self
    }
    
    private func executeCompleteCallback(_ callback: (Result) -> Void) {
        if status == .cancelled {
            callback(.cancelled)
        } else if let v = value as? RequesterError {
            callback(.error(v))
        } else {
            callback(.success(value as! T))
        }
    }
    
    public func request() -> Request? {
        return r
    }
}
