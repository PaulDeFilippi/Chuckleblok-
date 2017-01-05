//
//  Post.swift
//  lets-get-social
//
//  Created by Paul Defilippi on 10/13/16.
//  Copyright © 2016 Paul Defilippi. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    private var _flag : Int!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var flag : Int {
        return _flag
    }
    
    init(caption: String, imageUrl: String, likes: Int,flag : Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._flag = flag
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let flag = postData["flag"] as? Int {
            self._flag = flag
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    
    func adjustFlag(addFlag: Bool) {
        if addFlag {
            _flag = _flag + 1
        } else {
            _flag = _flag - 1
        }
         _postRef.child("flag").setValue(_flag)
    }
}
