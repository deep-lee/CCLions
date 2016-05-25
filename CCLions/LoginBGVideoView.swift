//
//  LoginBGVideoView.swift
//  CCLions
//
//  Created by 李冬 on 5/10/16.
//  Copyright © 2016 李冬. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class LoginBGVideoView: UIView {

	var player: MPMoviePlayerController?
	var isLoop: Bool? // 控制是否循环

	/*
	 // Only override drawRect: if you perform custom drawing.
	 // An empty implementation adversely affects performance during animation.
	 override func drawRect(rect: CGRect) {
	 // Drawing code
	 }
	 */
	override init(frame: CGRect) {
		super.init(frame: frame)

		if VideoFunctions.getUrlInfo() != nil {
			self.isLoop = VideoFunctions.getLoopMode()
			self.preparePlayBack()
		}
	}

	func preparePlayBack() -> Void {
		if self.player == nil {
			print(VideoFunctions.getVideoUrl())
			print(VideoFunctions.getVideoType())
			let path = NSBundle.mainBundle().pathForResource(VideoFunctions.getVideoUrl(), ofType: VideoFunctions.getVideoType())

			if path == nil {
				print("为空")
			}

			let url = NSURL(fileURLWithPath: path!)
			self.player = MPMoviePlayerController(contentURL: url)
			self.player?.controlStyle = MPMovieControlStyle.None
			self.player?.prepareToPlay()
			self.player?.view.frame = self.frame
			self.addSubview((self.player?.view)!)
			self.sendSubviewToBack((self.player?.view)!)
			self.player?.scalingMode = MPMovieScalingMode.AspectFill
            self.player?.repeatMode = MPMovieRepeatMode.One
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
