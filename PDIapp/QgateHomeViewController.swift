//
//  QgateHomeViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 4/30/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class QgateHomeViewController: UIViewController, UITextFieldDelegate
{

    var machineId = ""
    var user = ""
    var Port = port()
    var currentImage = UIImage()
    var currentMessage = ""
    var menuToggle = 0
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let docDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    var currentImageSize = 0
    var currentImageData: Data!
    
    @IBOutlet weak var backToHomeButton: UIButton!
    @IBOutlet weak var changeUserButton: UIButton!
    @IBOutlet weak var changeMachineButton: UIButton!
    @IBOutlet weak var imagesButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var imageDisplayer: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var messageDisplayer: UILabel!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var machineTag: UILabel!
    @IBOutlet weak var userTag: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        closeMenu()
        
        messageField.delegate = self
        getUser()
        getMachine()
        machineTag.text = machineId
        userTag.text = user
        
        if(!Port.connectionSuccesful)
        {
            print("Could not connect.")
            //couldNotConnect()
        }
    }
    @IBAction func backToHomePressed(_ sender: Any)
    {
        self.performSegue(withIdentifier: "qgateToHome", sender: (Any).self)
    }
    /*
     * FUNCTION: toggleMenu
     * PURPOSE: Opens and closes menu options
     */
    @IBAction func toggleMenu(_ sender: Any)
    {
        view.bringSubview(toFront: editButton)
        view.bringSubview(toFront: imagesButton)
        view.bringSubview(toFront: changeUserButton)
        view.bringSubview(toFront: changeMachineButton)
        if(menuToggle == 0)
        {
            openMenu()
        }
        else
        {
            closeMenu()
        }
    }
    /*
     * FUNCTION: closeMenu
     * PURPOSE: Hides all menu options
     */
    func closeMenu()
    {
        editButton.isHidden = true
        imagesButton.isHidden = true
        changeMachineButton.isHidden = true
        changeUserButton.isHidden = true
        backToHomeButton.isHidden = true
        menuToggle = 0
    }
    /*
     * FUNCTION: openMenu
     * PURPOSE: Unhides all menu options
     */
    func openMenu()
    {
        editButton.isHidden = false
        imagesButton.isHidden = false
        changeMachineButton.isHidden = false
        changeUserButton.isHidden = false
        backToHomeButton.isHidden = false
        menuToggle = 1
    }
    /*
     * FUNCTION: getUser
     * PURPOSE: Retrieves users name from saved file or prompts for entry if saved file is not found
     */
    func getUser()
    {
        do
        {
            let fileURL = docDirURL.appendingPathComponent("storedUserName").appendingPathExtension("txt")
            let userName = try String(contentsOf: fileURL)
            if(userName == "" || userName == "\n")
            {
                print("USER NAME IS EMPTY")
                getNamePopUp()
            }
            else
            {
                user = userName
                userTag.text = user
            }
        }
        catch
        {
            print(error)
            getNamePopUp()
        }
    }
    /*
     * FUNCTION: setUser
     * PURPOSE: Saves a new name to file
     */
    func setUser(_ nameIn: String)
    {
        do
        {
            user = nameIn
            let fileURL = docDirURL.appendingPathComponent("storedUserName").appendingPathExtension("txt")
            try user.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            let readText = try String(contentsOf: fileURL)
            print("Name set to: ", readText)
            print("NAME SAVED SUCCESFULLY")
            userTag.text = user
        }
        catch
        {
            print("NAME COULD NOT SAVE")
            print(error)
        }
    }
    /*
     * FUNCTION: getMachine
     * PURPOSE: Retrieves current machine id from saved file or prompts for entry if saved file is not found
     */
    func getMachine()
    {
        do
        {
            let fileURL = docDirURL.appendingPathComponent("storedMachine").appendingPathExtension("txt")
            let macName = try String(contentsOf: fileURL)
            if(macName == "" || macName == "\n")
            {
                print("USER NAME IS EMPTY")
                getMachinePopUp()
            }
            else
            {
                machineId = macName
                machineTag.text = machineId
                Port.setMachine(machineIn: Machine(name: machineId))
            }
        }
        catch
        {
            print(error)
            getMachinePopUp()
        }
    }
    /*
     * FUNCTION: setMachine
     * PURPOSE: Saves a new machine id to file
     * PARAMS: macNameIn -> id to be set to machine id
     */
    func setMachine(_ macNameIn: String)
    {
        do
        {
            machineId = macNameIn
            let fileURL = docDirURL.appendingPathComponent("storedMachine").appendingPathExtension("txt")
            try machineId.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            let readText = try String(contentsOf: fileURL)
            print("Machine set to: ", readText)
            print("MACHINE SAVED SUCCESFULLY")
            machineTag.text = machineId
            Port.setMachine(machineIn: Machine(name: machineId))
        }
        catch
        {
            print("MACHINE COULD NOT SAVE")
            print(error)
        }
    }
    /*
     * FUNCTION: getNamePopUp
     * PURPOSE: Displays a pop up to get name entry from user
     */
    func getNamePopUp()
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textEntryPopUp") as! TextEntryPopUpViewController
        popOverVC.returnType = 0
        popOverVC.titleIn = "Enter Name:"
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.setUser = setUser
    }
    /*
     * FUNCTION: getMachinePopUp
     * PURPOSE: Displays a pop up to get machine id entry from user
     */
    func getMachinePopUp()
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textEntryPopUp") as! TextEntryPopUpViewController
        popOverVC.returnType = 1
        popOverVC.titleIn = "Enter Machine ID:"
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.setMachine = setMachine
    }
    /*
     * FUNCTION: changeMachine
     * PURPOSE: Initiates getting new input from user to update the current machine
     */
    @IBAction func changeMachine(_ sender: Any)
    {
        closeMenu()
        getMachinePopUp()
    }
    /*
     * FUNCTION: changeUser
     * PURPOSE: Initiates getting new input from user to update the current users name
     */
    @IBAction func changeUser(_ sender: Any)
    {
        closeMenu()
        getNamePopUp()
    }
    
    /*
     * FUNCTION: touchesBegan
     * PURPOSE: Is called when touch begins
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        closeMenu()
        self.view.endEditing(true)
    }
    /*
     * FUNCTION: textFieldShouldReturn
     * PURPOSE: When text field is done editing, resigns responder
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        textField.resignFirstResponder()
        return true
    }
    /*
     * FUNCTION: openImageViewer
     * PURPOSE: Opens the screen that displays currently saved images
     */
    @IBAction func openImagesViewer(_ sender: Any)
    {
        closeMenu()
        startActivity()
        DispatchQueue.global().async
            {
                let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imagesViewer") as! ImagesViewerViewController
                popOverVC.Port = self.Port
                
                DispatchQueue.main.async
                    {
                        self.addChildViewController(popOverVC)
                        self.view.addSubview(popOverVC.view)
                        popOverVC.didMove(toParentViewController: self)
                        self.stopActivity()
                }
        }
    }
    /*
     * FUNCTION: openEditor
     * PURPOSE: Opens a screen with the current image displayed and access to editing tools
     */
    @IBAction func openEditor(_ sender: Any)
    {
        closeMenu()
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageEditor") as! ImageEditorViewController
        popOverVC.currentImage = self.currentImage
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.onEditorClosed = onEditorClosed
    }
    func callOpenEditor()
    {
        closeMenu()
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageEditor") as! ImageEditorViewController
        popOverVC.currentImage = self.currentImage
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.onEditorClosed = onEditorClosed
    }
    /*
     * FUNCTION: onEditorClosed
     * PURPOSE: Callback function called when image editor closed that updates the current image to the edited image
     */
    func onEditorClosed(_ image: UIImage)
    {
        currentImage = image
        currentImageSize = (UIImagePNGRepresentation(currentImage)?.count)!
       // size.text = String(describing: currentImageSize)
        imageDisplayer.image = image
    }
    /*
     * FUNCTION: textFieldDidBeginEditing
     * PURPOSE: If text box editing is started, this function exceutes
     * PARAMS: textField -> UITextField object for senseing edit
     */
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        moveTextField(textField: messageField, moveDistance: -250, up: true)
    }
    /*
     * FUNCTION: textFieldDidEndEditing
     * PURPOSE: If text box editing is ended, this function exceutes
     * PARAMS: textField -> UITextField object for senseing edit
     */
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        moveTextField(textField: messageField, moveDistance: -250, up: false)
    }
    /*
     * FUNCTION: moveTextField
     * PURPOSE: Moves screen up so keyboard doesnt cover textbox at base of screen
     * PARAMS: textField -> textfield to be moved if touched
     *         moveDistance -> distance to move screen
     *         up -> true if screen should go up, false if screen should go down
     */
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool)
    {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    /*
     * FUNCTION: attatchMessage
     * PURPOSE: Adds a message to the preview and adds it to be sent on upload.
     */
    @IBAction func attatchMessage(_ sender: Any)
    {
        currentMessage = messageField.text!
        messageDisplayer.text = messageField.text
        messageField.text = ""
    }
    /*
     * FUNCTION: getPicture
     * PURPOSE: Opens camera and gallery options and temporarily stores selected image
     */
    @IBAction func getPicture(_ sender: Any)
    {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.imageDisplayer.image = image
            self.currentImage = image
            self.imageDisplayer.isHidden = false
            self.callOpenEditor()
        }
    }
    /*
     * FUNCTION: upload
     * PURPOSE: Sends the image and message to the database if an image is selected or calls warning popup if none is selected
     */
    @IBAction func upload(_ sender: Any)
    {
        if(imageDisplayer.image == nil)
        {
            print("No Image to upload")
            missingInfoPopUp(withWarning: "No Image is selected, Add an image to upload")
        }
        else if(machineId == "")
        {
            print("No Machine Specified")
            missingInfoPopUp(withWarning: "No machine is specified")
        }
        else
        {
            print("Uploading image...")
            startActivity()
            DispatchQueue.global().async
                {
                    
                    self.compressImage(image: self.currentImage)
                    self.Port.addImage(/*image: self.currentImage*/imageDat: self.currentImageData, message: self.currentMessage, macId: self.machineId)
                    print("Added Image")
                    
                    DispatchQueue.main.async {
                        self.stopActivity()
                        //self.size.text = String(describing: self.currentImageSize)
                    }
            }
            imageDisplayer.image = nil
            messageDisplayer.text = ""
        }
        //size.text = String(describing: currentImageSize)
    }
    func compressImage(image: UIImage)
    {
        print("Raw Bytes: ", (UIImagePNGRepresentation(image)?.count)!)
        if((UIImagePNGRepresentation(image)?.count)! > 2000000)
        {
            print("2M+ RES IMAGE")
            if let imageData = image.jpeg(.lowest)
            {
                print(imageData.count, "Bytes")
                //size.text = String(describing: imageData.count)
                currentImageSize = imageData.count
                currentImageData = imageData
                currentImage = UIImage(data: imageData)!
                /*if(imageData.count > 125000)
                 {
                 compressImage(image: currentImage)
                 }*/
            }
        }
        else if((UIImagePNGRepresentation(image)?.count)! > 1000000)
        {
            print("1M RES IMAGE")
            if let imageData = image.jpeg(.low)
            {
                print(imageData.count, "Bytes")
                //size.text = String(describing: imageData.count)
                currentImageSize = imageData.count
                currentImageData = imageData
                currentImage = UIImage(data: imageData)!
            }
        }
        else if((UIImagePNGRepresentation(image)?.count)! > 500000)
        {
            print("1M RES IMAGE")
            if let imageData = image.jpeg(.low)
            {
                print(imageData.count, "Bytes")
                //size.text = String(describing: imageData.count)
                currentImageSize = imageData.count
                currentImageData = imageData
                currentImage = UIImage(data: imageData)!
            }
        }
        else if((UIImagePNGRepresentation(image)?.count)! > 125000)
        {
            print("100k RES IMAGE")
            if let imageData = image.jpeg(.low)
            {
                print(imageData.count, "Bytes")
                //size.text = String(describing: imageData.count)
                currentImageSize = imageData.count
                currentImageData = imageData
                currentImage = UIImage(data: imageData)!
            }
        }
        else
        {
            print("LOW RES IMAGE")
            if let imageData = image.jpeg(.low)
            {
                print(imageData.count, "Bytes")
                /*size.text = String(describing: imageData.count)*/
                currentImageSize = imageData.count
                currentImageData = imageData
                currentImage = UIImage(data: imageData)!
            }
        }
    }
    /*
     * FUNCTION: noImagePopUp
     * PURPOSE: Displays a warning pop up
     */
    func missingInfoPopUp(withWarning: String)
    {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textButtonPopUp") as! TextPopUpViewController
        popOverVC.message = withWarning
        self.addChildViewController(popOverVC)
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    /*
     * FUNCTION: startActivity
     * PURPOSE: Shows the activity indicator and stops recording user touches.
     */
    func startActivity()
    {
        print("Activity Started")
        self.view.alpha = 0.5
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
        self.view.alpha = 1
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    /*
     * FUNCTION: showLoadingScreen
     * PURPOSE: Displays the loading view
     */
    func showLoadingScreen()
    {
        /*loadingView.isHidden = false
         loadingView.bounds.size.width = view.bounds.width
         loadingView.bounds.size.height = view.bounds.height
         loadingView.center = view.center
         loadingView.alpha = 1
         self.view.bringSubview(toFront: loadingView)
         self.view = loadingView
         print("Loading screen succeeded")*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FCtoBattery" {
            if let vc = segue.destination as? ImageEditorViewController {
                //vc.currentImage = self.currentImage
                //vc.imageDisplayer.image = self.imageDisplayer.image
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

