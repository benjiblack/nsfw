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