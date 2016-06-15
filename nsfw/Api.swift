//
//  Api.swift
//  nsfw
//
//  Created by Tchang on 12/06/16.
//  Copyright © 2016 Tchang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Api: NSObject {
    
    var boards = [[String]]()
    
    func getInfo(url: String, completion: JSON? -> Void) {
        Alamofire.request(.GET, url).validate().responseJSON {
            response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    completion(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func getBoards (completion: [[String]]? -> Void) {
        let boardUrl = "https://a.4cdn.org/boards.json"
        Alamofire.request(.GET, boardUrl).validate().responseJSON {
            response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let size = json["boards"].count
                    for x in 0 ..< size {
                        let elem = [json["boards"][x]["title"].string!, json["boards"][x]["board"].string!]
                        self.boards.append(elem)
                    }
                    completion(self.boards)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
}
