//
//  PopUpViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 2/26/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController
{

    var passedURL = "https://smhttp-ssl-50970.nexcesscdn.net/media/catalog/product/cache/1/image/9df78eab33525d08d6e5fb8d27136e95/placeholder/default/no_image_available_3.jpg"
    var info = "INFORMATION DID NOT LOAD CORRECTLY"
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoLabel.text = info
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let url = NSURL (string: passedURL)
        let request = NSURLRequest(url: url! as URL)
        webView.loadRequest(request as URLRequest)
        
    }
    @IBAction func closePressed(_ sender: Any)
    {
        self.view.removeFromSuperview()
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
