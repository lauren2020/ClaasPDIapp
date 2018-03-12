//
//  TextEntryPopUpViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 3/12/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class TextEntryPopUpViewController: UIViewController {

    @IBOutlet weak var messageField: UITextField!
    var message = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageField.text = message
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }

    @IBAction func okPressed(_ sender: Any)
    {
        self.view.removeFromSuperview()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
