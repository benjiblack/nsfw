//
//  contentViewController.swift
//  nsfw
//
//  Created by Maxime VALLET on 8/24/16.
//  Copyright © 2016 Tchang. All rights reserved.
//

import UIKit

class contentViewController: UIViewController {

    var content = [[String: String]]()
    var index = 0
    
    override func viewDidLoad() {
        print(content[index]["url"]!)
        print(content[index]["com"]!)
    }
}