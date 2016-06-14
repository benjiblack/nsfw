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
    
    var boards = [String]()
//    let url = "https://a.4cdn.org/gif/catalog.json"
    
    func getInfo(url: String, completion: JSON? -> Void) {
        Alamofire.request(.GET, url).validate().responseJSON {
            response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
//                    print(String(json[0]["threads"][0]["tim"]))
//                    print(json[0]["threads"][0]["ext"].string!)
//                    let img = String(json[0]["threads"][0]["tim"]) + json[0]["threads"][0]["ext"].string!
                    completion(json)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func getBoards (completion: [String]? -> Void) {
        let boardUrl = "https://a.4cdn.org/boards.json"
        Alamofire.request(.GET, boardUrl).validate().responseJSON {
            response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let size = json["boards"].count
                    for x in 0 ..< size {
                        self.boards.append(json["boards"][x]["board"].string!)
                    }
                    completion(self.boards)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
}
