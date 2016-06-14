//
//  loadImage.swift
//  nsfw
//
//  Created by Tchang on 14/06/16.
//  Copyright © 2016 Tchang. All rights reserved.
//

import UIKit
import SwiftyJSON

func loadGif(data: String) -> UIImage? {
    print("data:", data)
    let strUrl = data
    if let url = NSURL(string: strUrl) {
        if let data = NSData(contentsOfURL: url) {
            let gif = UIImage.gifWithData(data)
            return gif
        }
    }
    return nil
}


func loadImage(data: String) -> UIImage? {
    let strUrl = data
    if let url = NSURL(string: strUrl) {
        if let data = NSData(contentsOfURL: url) {
            return UIImage(data: data)
        }
    }
    return nil
}

func downloadContent(data: JSON, board: String) -> [UIImage?] {
    let size = data[0]["threads"].count
    var array = [UIImage?]()
    for x in 0 ..< size {
        var url = "https://i.4cdn.org/" + board + "/"
        url += String(data[0]["threads"][x]["tim"]) + "s.jpg"
        array.append(loadImage(url))
    }
    return array
}