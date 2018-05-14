//
//  Image.swift
//  PDIapp
//
//  Created by Lauren Shultz on 4/30/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation
import UIKit

class Image
{
    var picture: UIImage!
    var imageId: String!
    var message: String!
    var uId: String!
    init(pictureIn: UIImage, messageIn: String, uIdIn: String)
    {
        picture = pictureIn
        message = messageIn
        uId = uIdIn
    }
}
