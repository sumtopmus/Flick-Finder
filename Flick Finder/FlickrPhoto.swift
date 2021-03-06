//
//  FlickrPhoto.swift
//  Flick Finder
//
//  Created by Oleksandr Iaroshenko on 09.06.15.
//  Copyright (c) 2015 Oleksandr Iaroshenko. All rights reserved.
//

import Foundation

class FlickrPhoto {

    var title: String
    var url: NSURL!

    init(title: String, urlString: String) {
        self.title = title
        self.url = NSURL(string: urlString)
    }
}