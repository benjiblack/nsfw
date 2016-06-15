//
//  ViewController.swift
//  nsfw
//
//  Created by Tchang on 12/06/16.
//  Copyright © 2016 Tchang. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SwiftGifOrigin
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var sideBar: UIView!
    @IBOutlet weak var boardTableVw: UITableView!
    @IBOutlet weak var catalogCollectionVw: UICollectionView!
    
    let api = Api()
    let width = UIScreen.mainScreen().bounds.width
    var boards = [[String]]()
    var data: JSON?
    var imageArray = [String?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        addSwipe()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(imageLiteral: "background"))
        sideBar.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        sideBar.translatesAutoresizingMaskIntoConstraints = false
        boardTableVw.dataSource = self
        boardTableVw.delegate = self
        boardTableVw.backgroundColor = UIColor.clearColor()
        catalogCollectionVw.dataSource = self
        catalogCollectionVw.delegate = self
        catalogCollectionVw.backgroundColor = UIColor.clearColor()
        api.getBoards() {
            completion in
            if let ret = completion {
                self.boards = ret
                self.boardTableVw.reloadData()
            }
        }
        showSideBar()
    }
    
    func addSwipe() {
        let swipeRigt = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe))
        swipeLeft.direction = .Left
        self.view.addGestureRecognizer(swipeRigt)
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Right:
            if sideBar.superview == nil {
                showSideBar()
            }
        case UISwipeGestureRecognizerDirection.Left:
            hideSideBar()
        default:
            break
        }
    }
    
    func showSideBar() {
        view.addSubview(sideBar)
        let bottomConstraint = sideBar.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        let leftConstraint = sideBar.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let topConstraint = sideBar.topAnchor.constraintEqualToAnchor(view.topAnchor)
        let widthConstraint = sideBar.widthAnchor.constraintEqualToConstant(self.width / 3)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        view.layoutIfNeeded()
        self.sideBar.center.x -= width / 3
        UIView.animateWithDuration(0.3) {
            self.sideBar.center.x += self.width / 3
        }
    }
    
    func hideSideBar() {
        UIView.animateWithDuration(0.3, animations: {
            self.sideBar.center.x -= self.width / 3
        }) { completed in
            if completed == true {
                self.sideBar.removeFromSuperview()
            }
        }
    }
    
    /* ========== TABLE VIEW ========== */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.boards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = boardTableVw.dequeueReusableCellWithIdentifier("boardCell", forIndexPath: indexPath)
        cell.textLabel?.text = "/" + self.boards[indexPath.row][1] + "/"
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = "https://a.4cdn.org/" + boards[indexPath.row][1] + "/catalog.json"
        self.title = boards[indexPath.row][0]
        api.getInfo(url) {
            completion in
            if let check = completion {
                self.data = check
                self.imageArray.removeAll()
                self.downloadImage(self.boards[indexPath.row][1])
                self.catalogCollectionVw.reloadData()
                self.catalogCollectionVw.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .Top, animated: false)
            }
        }
        hideSideBar()
    }
    
    /* ========== COLLECTION VIEW ========== */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var ret = 0
        if let check = data {
            let size = check.count
            for x in 0 ..< size {
                ret += check[x]["threads"].count
            }
        }
        return ret
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = catalogCollectionVw.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! CustomCell
        if data == nil {
            return cell
        }
        Alamofire.request(.GET, imageArray[indexPath.row]!).responseImage {
            response in
            if let image = response.result.value {
                cell.imageCell.image = image
            } else {
                cell.imageCell.image = nil
            }
        }
        return cell
    }
    
    func downloadImage(board: String) {
        let total = data!.count
        for y in 0 ..< total {
            let size = data![y]["threads"].count
            for x in 0 ..< size {
                if data![y]["threads"][x]["tim"] == nil {
                    self.imageArray.append("")
                } else {
                    let url = "https://i.4cdn.org/" + board + "/" + String(data![y]["threads"][x]["tim"]) + "s.jpg"
                    self.imageArray.append(url)
                }
            }
        }
    }
}