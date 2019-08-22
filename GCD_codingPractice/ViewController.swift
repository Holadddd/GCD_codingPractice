//
//  ViewController.swift
//  GCD_codingPractice
//
//  Created by wu1221 on 2019/8/22.
//  Copyright © 2019 wu1221. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var apiRequest: UIButton!
    
    @IBOutlet weak var offsetTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiRequest.addTarget(self, action: #selector(ViewController.make), for: .touchUpInside)
    }
    let group: DispatchGroup = DispatchGroup()
    
    
    
    @objc func make() {
        

        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        group.enter()
        queue1.async(group: group){
            self.makeRequest(offset: 0)
        }
        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        group.enter()
        queue2.async(group: group){
            self.makeRequest(offset: 10)
        }
        let queue3 = DispatchQueue(label: "queue3", attributes: .concurrent)
        group.enter()
        queue3.async(group: group){
            self.makeRequest(offset: 20)
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("done")
        }
        
    }
    
    
    func makeRequest(offset: Int) {
        
        HttpsManger.shared.getSpeed(offset: offset) { [weak self] result in
            guard let strongSelf = self else { fatalError() }
            switch result {
            case .success(let data):
                strongSelf.parseData(data: data)
            case .failure(let error):
                print(error)
            }
            self?.group.leave()
        }
    }
    
    
    
    func parseData(data:Data) {
        
        let decoder = JSONDecoder()
        do {
            let data = try decoder.decode(SpeedDate.self, from: data)
            print(data.result.results[0].road)
        } catch {
            print(error)
        }
        
    }
    
}

struct SpeedDate :Codable {
    var result: SpeedInfo
    enum Codingkeys: String, CodingKey {
        case result
    }
}

struct SpeedInfo: Codable {
    var limit: Int
    var offset: Int
    var count: Int
    var sort: String
    var results: [Detail]
    enum Codingkeys: String, CodingKey {
        case limit
        case offset
        case count
        case sort
        case results
    }
}

struct Detail: Codable {
    var functions: String
    var area: String
    var no: String
    var direction: String
    var speed_limit: String
    var location: String
    var _id: Int
    var road: String
    enum Codingkeys: String, CodingKey {
        case functions
        case area
        case no
        case direction
        case speed_limit
        case location
        case _id
        case road
    }
}
