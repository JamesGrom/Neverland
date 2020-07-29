//
//  FeedViewCollectionViewCell.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/19/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import AVFoundation //used to have the video play

protocol FeedViewCollectionViewCellDelegate : AnyObject {
    func didTapProfileButton(with model: VideoModel)
    func didTapChallengeButton(with model: VideoModel)
    func didTapLikeButton(with model: VideoModel)
    func didTapCommentButton(with model: VideoModel)
    func didTapShareButton(with model: VideoModel)
}

class FeedViewCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "FeedViewCollectionViewCell"
    
    //Labels
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.2412029505, green: 0.5847942829, blue: 0.7717464566, alpha: 1)
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.2412029505, green: 0.5847942829, blue: 0.7717464566, alpha: 1)
        return label
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.2412029505, green: 0.5847942829, blue: 0.7717464566, alpha: 1)
        return label
    }()
    //Buttons
    let profileButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
        return button
    }()
    let challengeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Swords"), for: .normal)
        return button
    }()
    let likeButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
        return button
    }()
    let commentButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "text.bubble.fill"), for: .normal)
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "arrowshape.turn.up.right.fill"), for: .normal)
        return button
    }()
    
    
    private let videoContainer = UIView()
    //Delegate used to detect if user has touched any of these buttons
    weak var delegate : FeedViewCollectionViewCellDelegate?

    //Subviews
    var player: AVPlayer?
    var model: VideoModel?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = #colorLiteral(red: 0.4864877296, green: 0.8543439192, blue: 1, alpha: 1)
        contentView.clipsToBounds = true
        addSubviews()
    }
    func addSubviews(){
        contentView.addSubview(videoContainer)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(scoreLabel)
        
        contentView.addSubview(profileButton)
        contentView.addSubview(challengeButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(shareButton)
        
        //add actions
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        challengeButton.addTarget(self, action: #selector(didTapChallengeButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        videoContainer.clipsToBounds = true
        contentView.sendSubviewToBack(videoContainer)
    }
    
    @objc private func didTapProfileButton(){
        guard let model = model else {return}
        delegate?.didTapProfileButton(with: model)
    }
    @objc private func didTapChallengeButton(){
        guard let model = model else {return}
        delegate?.didTapChallengeButton(with: model)
    }
    @objc private func didTapLikeButton(){
        guard let model = model else {return}
        delegate?.didTapLikeButton(with: model)
    }
    
    @objc private func didTapCommentButton(){
        guard let model = model else {return}
        delegate?.didTapCommentButton(with: model)
    }
    @objc private func didTapShareButton(){
        guard let model = model else {return}
        delegate?.didTapShareButton(with: model)
    }
    
    //determine where everything goes
    override func layoutSubviews() {
        super.layoutSubviews()
        videoContainer.frame = contentView.bounds
        
        //reused size perameter for all the buttons
        let size = contentView.frame.size.width/9
        let viewWidth = contentView.frame.size.width
        let viewHeight = contentView.frame.size.height
//        let tabBarHeight = (tabBarController?.tabBar.frame.size.height)!
        
        profileButton.frame = CGRect(x: viewWidth-size - 10, y: viewHeight - size*5 - 140, width: size, height: size - 5 )
        challengeButton.frame = CGRect(x: viewWidth-size - 7 , y: viewHeight - size*2 - 80, width: size - 7, height: size - 7  )
        likeButton.frame = CGRect(x: viewWidth-size - 10, y: viewHeight - size*4 - 120, width: size, height: size - 10 )
        commentButton.frame = CGRect(x: viewWidth-size - 10 , y: viewHeight - size*3 - 100, width: size, height: size - 10)
        shareButton.frame = CGRect(x: viewWidth-size - 10 , y: viewHeight - size - 60, width: size, height: size - 15 )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        captionLabel.text = nil
        usernameLabel.text = nil
        scoreLabel.text = nil
//        player?.pause()
    }
    public func configure(with model: VideoModel){
        self.model = model
        configureVideo()
        
        //configure the labels
        captionLabel.text = model.caption
        usernameLabel.text = model.userName
        scoreLabel.text = "100"
        
    }
    public func playContent(){
        player?.play()
    }
    public func pauseContent(){
        player?.pause()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func configureVideo(){
        print("enters configure Video")
        guard let model = model else{
            return
        }
        guard let path = Bundle.main.path(forResource: model.videoFileName, ofType: model.videoFileFormat) else{
            print("error retrieving video")
            return
        }
        player = AVPlayer( url: URL(fileURLWithPath: path) )
        let playerView = AVPlayerLayer()
        playerView.player = player
        playerView.frame = contentView.bounds
        playerView.videoGravity = .resizeAspectFill
        videoContainer.layer.addSublayer(playerView)
//        player?.play()
    }
}


