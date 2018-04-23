//
//  Text2ButtonPopUpViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/14/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class Text2ButtonPopUpViewController: UIViewController
{
    // Variable to hold the message passed from parent function to be displayed on pop up screen
    var messageIn = "No Content"
    var leftTextIn = "Confirm"
    var rightTextIn = "Change"
    // **********************************Trash?????
    var left = false
    // Callback function used to return which button is pressed to the parent function
    var onPopOptionPressed: ((_ selected: Int) -> ())?
    
    // UILabel that displays given message
    @IBOutlet weak var message: UILabel!
    // Button on the left side of the pop up
    @IBOutlet weak var leftButton: UIButton!
    // Button on the right side of the pop up
    @IBOutlet weak var rightButton: UIButton!
    
    /*
     * FUNCTION: viewDidLoad
     * PURPOSE: When the view loads, the text to display is set in the message label
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()

        message.text = messageIn
        leftButton.setTitle(leftTextIn, for: .normal)
        rightButton.setTitle(rightTextIn, for: .normal)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    /*
     * FUNCTION: leftButtonPressed
     * PURPOSE: Returns 0 to parent function if the left button is pressed
     */
    @IBAction func leftButtonPressed(_ sender: Any)
    {
        onPopOptionPressed?(0)
        self.view.removeFromSuperview()
    }
    /*
     * FUNCTION: rightButtonPressed
     * PURPOSE: Returns 1 to parent function if the right button is pressed
     */
    @IBAction func rightButtonPressed(_ sender: Any)
    {
        onPopOptionPressed?(1)
        self.view.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
