//
//  SkippedCheckpoint.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/23/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import Foundation

class SkippedCheckpoint
{
    var checkpoint: Checkpoint!
    var position: Int!
    var response = 0
    init(checkpointIn: Checkpoint, positionIn: Int)
    {
        checkpoint = checkpointIn
        position = positionIn
    }
}
