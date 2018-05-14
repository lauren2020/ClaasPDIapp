//
//  ImageEditorViewController.swift
//  PDIapp
//
//  Created by Lauren Shultz on 4/27/18.
//  Copyright © 2018 Lauren Shultz. All rights reserved.
//

import UIKit

class ImageEditorViewController: UIViewController {

    
    // Holds unedited image
    var currentImage = UIImage()
    // Holds image with marks
    var editedImage = UIImage()
    // Indicates whether touches should create drawing or not
    var freeDrawEnabled = false
    // Holds the last point of touch on the screen
    var lastPoint: CGPoint!
    // Holds the currently selcted object
    var selectedObject = UIImageView()
    // Callback fucntion to send back edited image
    var onEditorClosed: ((_ image: UIImage) -> ())?
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var freeButton: UIButton!
    @IBOutlet weak var imageDisplayer: UIImageView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        closeButton.isHidden = true
        editedImage = currentImage
        imageDisplayer.image = currentImage
    }
    
    /*
     * FUNCTION: done
     * PURPOSE: Returns to main screen
     */
    @IBAction func done(_ sender: Any)
    {
        screenShot()
        onEditorClosed!(editedImage)
        self.view.removeFromSuperview()
    }
    
    /*
     * FUNCTION: screenShot
     * PURPOSE: Captures the users edits and saves it as the edited image
     */
    func screenShot()
    {
        //Create the UIImage
        UIGraphicsBeginImageContext(imageDisplayer.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        editedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    /*
     * FUNCTION: addCircle
     * PURPOSE: Adds a new circle to the canvas
     */
    @IBAction func addCircle(_ sender: Any)
    {
        imageCircle()
    }
    /*
     * FUNCTION: imageCircle
     * PURPOSE: Creates a new circle object and displays it on the canvas
     */
    func imageCircle()
    {
        print("imageCircle()")
        //Add circle image
        let circleView = UIImageView()
        circleView.image = #imageLiteral(resourceName: "highResCirc8")
        circleView.frame = CGRect(x: imageDisplayer.center.x, y: imageDisplayer.center.y, width: 100, height: 100)
        imageDisplayer.addSubview(circleView)
        imageDisplayer.bringSubview(toFront: circleView)
        
        addGestures(object: circleView)
    }
    /*
     * FUNCTION: addArrow
     * PURPOSE: Adds a new arrow to the canvas
     */
    @IBAction func addArrow(_ sender: Any)
    {
        imageArrow()
    }
    /*
     * FUNCTION: imageArrow
     * PURPOSE: Creates a new arrow object and displays it on the canvas
     */
    func imageArrow()
    {
        print("imageArrow()")
        let arrowView = UIImageView()
        arrowView.image = #imageLiteral(resourceName: "arrow2")
        arrowView.center = imageDisplayer.center
        arrowView.isUserInteractionEnabled = true
        arrowView.frame = CGRect(x: imageDisplayer.center.x, y: imageDisplayer.center.y, width: 100, height: 100)
        self.view.addSubview(arrowView)
        imageDisplayer.bringSubview(toFront: arrowView)
        
        addGestures(object: arrowView)
    }
    /*
     * FUNCTION: freeDraw
     * PURPOSE: Enables and disables free draw function
     */
    @IBAction func freeDraw(_ sender: Any)
    {
        if(freeDrawEnabled)
        {
            freeButton.setBackgroundImage(#imageLiteral(resourceName: "EmptyButton"), for: .normal)
            freeDrawEnabled = false
        }
        else
        {
            freeButton.setBackgroundImage(#imageLiteral(resourceName: "selectedButton2"), for: .normal)
            freeDrawEnabled = true
        }
    }
    /*
     * FUNCTION: touchesMoved
     * PURPOSE: Starts when user moves finger, if free draw is enabled a line is created to thast registered touch point
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches moved...")
        if(freeDrawEnabled)
        {
            let touch = touches.first
            let point = touch!.location(in: imageDisplayer)
            if(point.x > imageDisplayer.frame.minX && point.y > imageDisplayer.frame.minY && point.x < imageDisplayer.frame.maxX && point.y < imageDisplayer.frame.maxY)
            {
                
                
                let linePath = UIBezierPath()
                linePath.move(to: point)
                linePath.addLine(to: lastPoint/*CGPoint(x: point.x + 1, y: point.y + 1)*/)
                
                linePath.close()
                
                let line = CAShapeLayer()
                
                line.path = linePath.cgPath
                line.strokeColor = UIColor.red.cgColor
                line.lineWidth = 5
                
                self.view.layer.addSublayer(line)
                lastPoint = point
            }
        }
    }
    /*
     * FUNCTION: touchesBegan
     * PURPOSE: Is called when touch begins, creates a dot at location of touch
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print("touches began...")
        if(freeDrawEnabled)
        {
            let touch = touches.first
            let point = touch!.location(in: imageDisplayer)
            lastPoint = point
            let linePath = UIBezierPath()
            linePath.move(to: point)
            linePath.addLine(to: CGPoint(x: point.x + 1, y: point.y + 1))
            
            linePath.close()
            
            let line = CAShapeLayer()
            
            line.path = linePath.cgPath
            line.strokeColor = UIColor.red.cgColor
            line.lineWidth = 5
            
            self.view.layer.addSublayer(line)
        }
    }
    /*
     * FUNCTION: addGestures
     * PURPOSE: Adds gesture recognizers to newly created shapes
     * PARAMS: object -> Shape to assign gestures to
     */
    func addGestures(object: UIImageView)
    {
        let panGetter = UIPanGestureRecognizer(target: self, action: #selector(pan))
        object.addGestureRecognizer(panGetter)
        
        let tapGetter = UITapGestureRecognizer(target: self, action: #selector(tap))
        object.addGestureRecognizer(tapGetter)
        
        let pinchGetter = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        object.addGestureRecognizer(pinchGetter)
        
        let rotateGetter = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
        object.addGestureRecognizer(rotateGetter)
        
        panGetter.maximumNumberOfTouches = 1
        //panGetter.require(toFail: pinchGetter)
        //panGetter.require(toFail: rotateGetter)
        pinchGetter.require(toFail: tapGetter)
        pinchGetter.require(toFail: rotateGetter)
        tapGetter.require(toFail: pinchGetter)
        tapGetter.require(toFail: rotateGetter)
        rotateGetter.require(toFail: tapGetter)
        //rotateGetter.require(toFail: pinchGetter)
        
        object.isUserInteractionEnabled = true
    }
    /*
     * FUNCTION: closeCurrentImage
     * PURPOSE: Removes the selected shape from the canvas
     */
    @IBAction func closeCurrentImage(_ sender: Any)
    {
        print("Closeing view...")
        selectedObject.removeFromSuperview()
        closeButton.isHidden = true
    }
    /*
     * FUNCTION: tap
     * PURPOSE: Is called when a shape is tapped, opens a close button for that object
     */
    @objc func tap(sender: UITapGestureRecognizer)
    {
        print("Tapped...");
        selectedObject = sender.view as! UIImageView
        closeButton.center = CGPoint(x: (sender.view?.center.x)! + (sender.view?.frame.width)!/2, y: (sender.view?.center.y)! - (sender.view?.frame.height)!/2)
        if(closeButton.isHidden)
        {
            closeButton.isHidden = false
        }
        else
        {
            closeButton.isHidden = true
        }
    }
    /*
     * FUNCTION: pan
     * PURPOSE: Is called when a shape is dragged, moves the shape with the user finger
     */
    @objc func pan(sender: UIPanGestureRecognizer)
    {
        print("Panning...");
        
        closeButton.isHidden = true
        if(sender.state == .began || sender.state == .changed)
        {
            let translation = sender.translation(in: sender.view?.superview)
            let changeX = (sender.view?.center.x)! + translation.x
            let changeY = (sender.view?.center.y)! + translation.y
            
            sender.view?.center = CGPoint(x: changeX, y: changeY)
            sender.setTranslation(CGPoint.zero, in: sender.view)
        }
    }
    /*
     * FUNCTION: pinch
     * PURPOSE: Is called when 2 finger widening or closening motion is performed, resizes the shape
     */
    @objc func pinch(sender: UIPinchGestureRecognizer)
    {
        print("Pinching...")
        closeButton.isHidden = true
        if let sendView = sender.view
        {
            sendView.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
            sender.scale = 1
        }
    }
    /*
     * FUNCTION: rotate
     * PURPOSE: Is called when 2 fingers make a spinning motion, rotates the shape in the direction of the spinning motion
     */
    @objc func rotate(sender: UIRotationGestureRecognizer)
    {
        print("Rotateing...")
        closeButton.isHidden = true
        if let sendView = sender.view
        {
            sendView.transform = sendView.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
    /*
     * FUNCTION: gestureRecognizer
     * PURPOSE: Sets gesture recognition to true
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == "FCtoBattery" {
         if let vc = segue.destination as? ViewController {
         //vc.imageDisplayer.image = self.imageDisplayer.image
         }
         }*/
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
