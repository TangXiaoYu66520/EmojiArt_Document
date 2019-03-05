//
//  Document.swift
//  EmojiArt_Document
//
//  Created by 唐小雨 on 2019/3/5.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

