//
//  HTTPsManager.swift
//  GCD_codingPractice
//
//  Created by wu1221 on 2019/8/22.
//  Copyright © 2019 wu1221. All rights reserved.
//

import Foundation

enum Result<T> {
    
    case success(T)
    
    case failure(Error)
}

enum STHTTPClientError: Error {
    
    case decodeDataFail
    
    case clientError(Data)
    
    case serverError
    
    case unexpectedError
}

class HttpsManger {
    
    static var shared = HttpsManger()
    
    let semaphore = DispatchSemaphore(value: 1)
    let semaphoreForView = DispatchSemaphore(value: 1)
    let que = dispatch_queue_serial_t(label: "okok")
    
    
    func getSpeed(offset: Int = 0,completion:@escaping (Result<Data>) -> Void
        ) {
        
        
       
            
        
        guard let url = URL(string: "https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=5012e8ba-5ace-4821-8482-ee07c147fd0a&limit=1&offset=\(offset)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        
        let task = URLSession.shared.dataTask(with: request) { (data,  response, error) in
//            self.semaphore.wait()
            guard error == nil else {
                
                return completion(Result.failure(error!))
            }
            // swiftlint:disable force_cast
            let httpResponse = response as! HTTPURLResponse
            // swiftlint:enable force_cast
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
                
            case 200..<300:
                
                completion(Result.success(data!))
                
            case 400..<500:
                
                completion(Result.failure(STHTTPClientError.clientError(data!)))
                
            case 500..<600:
                
                completion(Result.failure(STHTTPClientError.serverError))
                
            default: return
                
                completion(Result.failure(STHTTPClientError.unexpectedError))
            }
            
        }
        
        task.resume()
        
    }
    
}
