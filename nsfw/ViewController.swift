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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    @IBOutlet var sideBar: UIView!
    @IBOutlet var blurView: UIView!
    @IBOutlet weak var boardTableVw: UITableView!
    @IBOutlet weak var catalogCollectionVw: UICollectionView!
    
    let api = Api()
    let width = UIScreen.mainScreen().bounds.width
    var boards = [[String: String]]()                   /* keys: board, title */
    var content = [[String: String]]()                  /* Keys: url, com */
    var data: JSON?
    
    // Mark: - Data for collectionView
    private let leftAndRightPaddings: CGFloat = 32.0    /* 8.0 space between tiles */
    private let numberOfItemPerRow: CGFloat = 3.0
    private let heightAdjustment: CGFloat = 30.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionWidth = (width - leftAndRightPaddings) / numberOfItemPerRow
        collectionLayout.itemSize = CGSizeMake(collectionWidth, collectionWidth + heightAdjustment)
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
        blurView.backgroundColor = UIColor.clearColor()
        blurView.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Gesture Recognizer
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
    
    // MARK: - External views handling
    func showBlurView() {
        view.addSubview(blurView)
        let bottomConstraint = blurView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        let leftConstraint = blurView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let topConstraint = blurView.topAnchor.constraintEqualToAnchor(view.topAnchor)
        let rightConstraint = blurView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, topConstraint, rightConstraint])
        view.layoutIfNeeded()
        self.blurView.alpha = 0
        UIView.animateWithDuration(0.3) {
            self.blurView.alpha = 1
        }
    }
    
    func hideBlurView() {
        UIView.animateWithDuration(0.3, animations: {
            self.blurView.alpha = 0
        }) { completed in
            if completed == true {
                self.blurView.removeFromSuperview()
            }
        }
    }
    
    func showSideBar() {
        showBlurView()
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
        hideBlurView()
        UIView.animateWithDuration(0.3, animations: {
            self.sideBar.center.x -= self.width / 3
        }) { completed in
            if completed == true {
                self.sideBar.removeFromSuperview()
                self.hideBlurView()
            }
        }
    }
    
    // MARK: - tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.boards.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = boardTableVw.dequeueReusableCellWithIdentifier("boardCell", forIndexPath: indexPath)
        cell.textLabel?.text = "/" + self.boards[indexPath.row]["board"]! + "/"
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = "https://a.4cdn.org/" + boards[indexPath.row]["board"]! + "/catalog.json"
        self.title = boards[indexPath.row]["title"]
        api.getInfo(url) {
            completion in
            if let check = completion {
                self.data = check
                self.content.removeAll()
                self.downloadImage(self.boards[indexPath.row]["board"]!)
                self.catalogCollectionVw.reloadData()
                self.catalogCollectionVw.scrollToItemAtIndexPath(NSIndexPath(forItem: 1, inSection: 0), atScrollPosition: .Top, animated: false)
            }
        }
        hideSideBar()
    }
    
    // MARK: - collectionView
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
        
        Alamofire.request(.GET, content[indexPath.row]["url"]!).responseImage {
            response in
            if let image = response.result.value {
                cell.imageCell.image = image
            } else {
                cell.imageCell.image = nil
            }
        }
        cell.textCell.text = content[indexPath.row]["com"]
        cell.textCell.textColor = UIColor.whiteColor()
        cell.textCell.backgroundColor = UIColor.clearColor()
        cell.imageCell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("contentSegue", sender: collectionView.cellForItemAtIndexPath(indexPath))
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Download function
    func downloadImage(board: String) {
        let total = data!.count
        for y in 0 ..< total {
            let size = data![y]["threads"].count
            for x in 0 ..< size {
                var elem = ["url": "", "com": ""]
                if data![y]["threads"][x]["tim"] != nil {
                    elem["url"] = "https://i.4cdn.org/" + board + "/" + String(data![y]["threads"][x]["tim"]) + "s.jpg"
                }
                if data![y]["threads"][x]["com"] != nil {
                    elem["com"] = data![y]["threads"][x]["com"].string
                }
                self.content.append(elem)
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "contentSegue" {
            let cell = sender as! UICollectionViewCell
            let i: Int = (self.catalogCollectionVw!.indexPathForCell(cell)?.row)!
            let new = segue.destinationViewController as! contentViewController
            new.content = self.content
            new.index = i
        }
    }
}