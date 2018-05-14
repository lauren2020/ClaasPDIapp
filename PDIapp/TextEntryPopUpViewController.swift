//
//  TextEntryPopUpViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/12/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class TextEntryPopUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var messageField: UITextField!
    var message = ""
    var titleIn = "Please enter you name: "
    // Callback function
    var returnType = 3
    var setUser: ((_ nameIn: String) -> ())?
    var setMachine: ((_ macNameIn: String) -> ())?
    var onNameSet: ((_ name: String) -> ())?
    
    /*
     * FUNCTION: viewDidLoad
     * PURPOSE: When view is loaded, messageField text field is set as its own delegate
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        messageField.delegate = self
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

    /*
     * FUNCTION: okPressed
     * PURPOSE: When ok is pressed, the name entered by the user is sent back to the parent function through the callback function onNameSet
     */
    @IBAction func okPressed(_ sender: Any)
    {
        message = messageField.text!
        if(message != "")
        {
            if(returnType == 0)
            {
                setUser!(message)
            }
            else if(returnType == 1)
            {
                setMachine!(message)
            }
            else
            {
                onNameSet?(message)
            }
            self.view.removeFromSuperview()
        }
        else
        {
            messageField.text = ""
            messageField.placeholder = "Please Enter A Valid Name"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
