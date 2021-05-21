//
//  HelpingClass.swift
//  WebViewDownload
//
//  Created by Matrix Marketers on 04/03/21.
//

import RealmSwift

class HelpingClass {
    static let shared = HelpingClass()
    
    
    
}

class Downloads: Object {
    @objc dynamic var itemName:String?
    @objc dynamic var itemPath:String?
}
