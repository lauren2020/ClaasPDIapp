//
//  SkippedVariant.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/23/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

class SkippedVariant
{
    var variant: Variant
    var position: Int!
    var response = 0
    init(variantIn: Variant, positionIn: Int)
    {
        variant = variantIn
        position = positionIn
    }
}
