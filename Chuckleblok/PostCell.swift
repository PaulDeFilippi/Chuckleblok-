//
//  PostCell.swift
//  lets-get-social
//
//  Created by Paul Defilippi on 10/13/16.
//  Copyright © 2016 Paul Defilippi. All rights reserved.
//

import UIKit
import Firebase

protocol AlertDelegate {
    func presentAlertWithTitle(title: String, message : String)
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    @IBOutlet weak var flagImg: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    
    var flagRef : FIRDatabaseReference!
    
    var delegateAlert: AlertDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
        let tapFlag = UITapGestureRecognizer(target: self, action: #selector(flagTapped))
        tapFlag.numberOfTapsRequired = 1
        flagImg.addGestureRecognizer(tapFlag)
        flagImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        flagRef = DataService.ds.REF_USER_CURRENT.child("flag").child(post.postKey)
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        // cacheing image
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("PAUL: Unable to download image from Firebase storage")
                } else {
                    print("PAUL: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
            
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
        
        flagRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.flagImg.image = UIImage(named: "empty-flag")
            } else {
                self.flagImg.image = UIImage(named: "filled-flag")
            }
        })
        
    }
    
    func likeTapped() {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    func flagTapped() {
        flagRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.flagImg.image = UIImage(named: "filled-flag")
                self.post.adjustFlag(addFlag: true)
                self.flagRef.setValue(true)
                self.delegateAlert?.presentAlertWithTitle(title: "Alert", message: "Thank you for reporting this activity. We will review it and take action ASAP.")
            } else {
                self.flagImg.image = UIImage(named: "empty-flag")
                self.post.adjustFlag(addFlag: false)
                self.flagRef.removeValue()
            }
        })
    }

}
