//
//  FeedVC.swift
//  lets-get-social
//
//  Created by Paul Defilippi on 10/11/16.
//  Copyright © 2016 Paul Defilippi. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImageTapped: CIrcleView!
    @IBOutlet weak var captionField: FancyField!
    
    
    
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                        
                    }
                }
            }
            self.tableView.reloadData()
        })
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                
            } else {
                cell.configureCell(post: post)
                
            }
            return cell
            
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImageTapped.image = image
            imageSelected = true
            
        } else {
            print("PAUL: A valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: AnyObject) {
        guard let caption = captionField.text, caption != "" else {
            print("PAUL: Caption must be entered")
            return
        }
        
        guard let img = addImageTapped.image, imageSelected == true else {
            print("PAUL: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                if error != nil {
                    print("PAUL: Unable to upload image to Firebase storage")
                } else {
                    print("PAUL: Successfully uploaded image to Firebase storage")
                    let downloadURL = metaData?.downloadURL()?.absoluteString
                    
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
                
            }
        }
        
        
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = [
            "caption": captionField.text! as String,
            "imageUrl": imgUrl as String,
            "likes": 0 as Int
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        addImageTapped.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }
    

    @IBAction func signOutTapped(_ sender: AnyObject) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("PAUL: ID removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
