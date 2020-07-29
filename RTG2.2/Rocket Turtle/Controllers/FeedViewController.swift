//
//  FeedViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/19/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit

struct VideoModel {
    let caption: String
    let userName: String
    let videoFileName: String
    let videoFileFormat: String
}

class FeedViewController: UIViewController {


    //we use a collection View to navigate through bounties / feed events
    var collectionView: UICollectionView?
    var data = [VideoModel]() //aray of data strings used to initialize the content of the cells

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tabBarController?.tabBar.backgroundImage = UII
//        tabBarController?
        navigationController?.isNavigationBarHidden = true
        //create an array of videoModels used to populate the collection view cells
        for _ in 0 ..< 10 {
            let model = VideoModel(caption: "testCaption", userName: "testUserName", videoFileName: "Video1", videoFileFormat: "MOV")
            data.append(model)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height )
//        - (tabBarController?.tabBar.frame.size.height)!
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
//            (tabBarController?.tabBar.frame.size.height)!
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(FeedViewCollectionViewCell.self, forCellWithReuseIdentifier: FeedViewCollectionViewCell.cellIdentifier)
        collectionView?.isPagingEnabled = true //snaps the collection view to the next page
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.delegate=self
        collectionView?.dataSource = self
        
        view.addSubview(collectionView!)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //make the tabbar transparent
        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.barTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        tabBarController?.tabBar.shadowImage = UIImage(named: "invisibleImage")
        tabBarController?.tabBar.backgroundImage = UIImage(named: "invisibleImage")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.04577282071, green: 0.3740736246, blue: 0.5337628722, alpha: 1)
        tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0.2412029505, green: 0.5847942829, blue: 0.7717464566, alpha: 1)
        
//        tabBarController?.tabBar.backgroundImage = UIImage(named: "invisibleImage")
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
}

extension FeedViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedViewCollectionViewCell
            .cellIdentifier, for: indexPath) as! FeedViewCollectionViewCell
        cell.configure(with: model)
        return cell
    }


}

//toggle playing/pausing by tapping screen
extension FeedViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FeedViewCollectionViewCell{
            //touch screen to toggle between play and pause
            if cell.player?.rate != 0{
                cell.pauseContent()
            }else{
                cell.playContent()
            }
            
        }
    }
    
    //play video content when the cell is displayed
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let formCell = cell as? FeedViewCollectionViewCell
        if formCell != nil{
            formCell?.playContent()
        }
    }
    //pause the video content when the cell is hidden
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let formCell = cell as? FeedViewCollectionViewCell
        if formCell != nil{
            formCell?.pauseContent()
        }

    }
}

