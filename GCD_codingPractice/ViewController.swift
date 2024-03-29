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
    @IBOutlet weak var cleanBtn: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            
        }
    }
    var infoArr:[LabelText] = [] {
        didSet {
            HttpsManger.shared.semaphore.signal()
            DispatchQueue.main.async {
               
                self.tableView.reloadData()
                guard self.infoArr.count != 0 else { return }
                self.tableView.scrollToRow(at: IndexPath(row: self.infoArr.count - 1, section: 0), at: .bottom, animated: true)
            }
            
        }
    }
    
    @IBOutlet weak var offsetOneRoadLabel: UILabel!
    @IBOutlet weak var offsetOneSpeedLabel: UILabel!
    var offsetOne: LabelText?
    
    @IBOutlet weak var offsetTwoRoadLabel: UILabel!
    @IBOutlet weak var offsetTwoSpeedLabel: UILabel!
    var offsetTwo: LabelText?
    
    @IBOutlet weak var offsetThreeRoadLabel: UILabel!
    @IBOutlet weak var offsetThreeSpeedLabel: UILabel!
    var offsetThree: LabelText?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiRequest.addTarget(self, action: #selector(ViewController.make), for: .touchUpInside)
        cleanBtn.addTarget(self, action: #selector(ViewController.clean), for: .touchUpInside)
        
    }
    let group: DispatchGroup = DispatchGroup()
    

    
    
    @objc func make() {
//
//        //Group
//        let queue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
//
//        group.enter()
//
//        queue1.async(group: group){
//
//            HttpsManger.shared.getSpeed(offset: 0) { [weak self] result in
//                guard let strongSelf = self else { fatalError() }
//                switch result {
//                case .success(let data):
//                    strongSelf.offsetOne = strongSelf.parseData(data: data)
//
//                case .failure(let error):
//                    print(error)
//                }
//                self?.group.leave()
//                print("queue1")
//            }
//
//        }
//
//        let queue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
//
//        group.enter()
//
//        queue2.async(group: group){
//
//            HttpsManger.shared.getSpeed(offset: 10) { [weak self] result in
//                guard let strongSelf = self else { fatalError() }
//                switch result {
//                case .success(let data):
//                    strongSelf.offsetTwo = strongSelf.parseData(data: data)
//
//                case .failure(let error):
//                    print(error)
//                }
//                self?.group.leave()
//                print("queue2")
//            }
//
//        }
//        let queue3 = DispatchQueue(label: "queue3", attributes: .concurrent)
//
//        group.enter()
//
//        queue3.async(group: group){
//
//            HttpsManger.shared.getSpeed(offset: 20) { [weak self] result in
//                guard let strongSelf = self else { fatalError() }
//                switch result {
//                case .success(let data):
//                    strongSelf.offsetThree = strongSelf.parseData(data: data)
//
//                case .failure(let error):
//                    print(error)
//                }
//                self?.group.leave()
//                print("queue3")
//            }
//
//        }
//
//        group.notify(queue: DispatchQueue.main) {
//            print("done")
//            self.offsetOneRoadLabel.text = self.offsetOne?.road
//            self.offsetOneSpeedLabel.text = self.offsetOne?.limit
//
//            self.offsetTwoRoadLabel.text = self.offsetTwo?.road
//            self.offsetTwoSpeedLabel.text = self.offsetTwo?.limit
//
//            self.offsetThreeRoadLabel.text = self.offsetThree?.road
//            self.offsetThreeSpeedLabel.text = self.offsetThree?.limit
//        }
        
        //Semaphore
        
        for i in 0...100 {
            
            HttpsManger.shared.getSpeed(offset: i) { [weak self] result in
                guard let strongSelf = self else { fatalError() }
                //                self?.semaphore.wait()
                HttpsManger.shared.semaphore.wait()
                switch result {
                case .success(let data):
                    let lableText = strongSelf.parseData(data: data)
                    self?.infoArr.append(lableText)
                    
                case .failure(let error):
                    print(error)
                }
                
                print(i)
            }
        }
        

    }
    

    
    func parseData(data:Data) -> LabelText {
        var labelText = LabelText(road: "", limit: "")
        let decoder = JSONDecoder()
        do {
            let data = try decoder.decode(SpeedDate.self, from: data)
            let info = data.result.results[0]
            labelText = LabelText(road: info.road, limit: info.speed_limit)
        } catch {
            print(error)
        }
        
        return labelText
    }
    
    @objc func clean() {
        self.offsetOneRoadLabel.text = ""
        self.offsetOneSpeedLabel.text = ""
        
        self.offsetTwoRoadLabel.text = ""
        self.offsetTwoSpeedLabel.text = ""
        
        self.offsetThreeRoadLabel.text = ""
        self.offsetThreeSpeedLabel.text = ""
        
        infoArr.removeAll()
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = infoArr[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TableViewCell else { fatalError() }
        cell.roadLabel.text = info.road
        cell.speedLabel.text = info.limit
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    }
    
}

struct LabelText {
    var road: String
    var limit: String
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
