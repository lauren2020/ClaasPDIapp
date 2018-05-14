//
//  HomeScreenViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 4/25/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController
{
    // Connection point to database
    var Port = port()
    // Creates activity indicator object
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Outlets v
    @IBOutlet var LoadingView: UIView!
    @IBOutlet weak var thisActivity: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        activityIndicator = thisActivity
        // Do any additional setup after loading the view.
    }
    /*
     * FUNCTION: pdiPressed
     * PURPOSE: Routes user to main pdi screen
     */
    @IBAction func pdiPressed(_ sender: Any)
    {
        showLoadingScreen()
        startActivity()
        DispatchQueue.global().async {
            
            self.Port.fillMachines(type: 0)
            
            DispatchQueue.main.async
            {
                self.stopActivity()
                self.performSegue(withIdentifier: "homeToPdi", sender: (Any).self)
            }
        }
    }
    /*
     * FUNCTION: storagePressed
     * PURPOSE: *TO BE DETERMINED*
     */
    @IBAction func storagePressed(_ sender: Any)
    {
    }
    /*
     * FUNCTION: qgatePressed
     * PURPOSE: opens qgate home screen
     */
    @IBAction func qgatePressed(_ sender: Any)
    {
        showLoadingScreen()
        startActivity()
        DispatchQueue.global().async
       {
        
        self.Port.fillMachines(type: 0)
            
            DispatchQueue.main.async
                {
                    self.stopActivity()
                    self.performSegue(withIdentifier: "homeToQgate", sender: (Any).self)
            }
        }
    }
    
    /*
     * FUNCTION: startActivity
     * PURPOSE: Shows the activity indicator and stops recording user touches.
     */
    func startActivity()
    {
        print("Activity Started")
        //self.view.alpha = 0.5
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    /*
     * FUNCTION: stopActivity
     * PURPOSE: Hides the activity indicator and resumes responding to user touches
     */
    func stopActivity()
    {
        print("Activity Stoped")
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    /*
     * FUNCTION: showLoadingScreen
     * PURPOSE: Displays the loading view
     */
    func showLoadingScreen()
    {
        LoadingView.isHidden = false
        LoadingView.bounds.size.width = view.bounds.width
        LoadingView.bounds.size.height = view.bounds.height
        LoadingView.center = view.center
        LoadingView.alpha = 1
        self.view.bringSubview(toFront: LoadingView)
        self.view = LoadingView
        print("Loading screen succeeded")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToPdi"
        {
            if let vc = segue.destination as? ViewController
            {
                vc.Port = self.Port
                vc.notInitial = false
            }
        }
        if segue.identifier == "homeToQgate"
        {
            if let vc = segue.destination as? ViewController
            {
                vc.Port = self.Port
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
