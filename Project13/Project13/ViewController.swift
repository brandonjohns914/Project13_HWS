//
//  ViewController.swift
//  Project13
//
//  Created by Brandon Johns on 5/2/23.
//

import UIKit
import CoreImage
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var intensity: UISlider!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var changeFilter: UIButton!                                                                       
    
    var currentImage: UIImage!                                                                                  // import image
    
    
    var context: CIContext!                                                                                     // coreImage that handles rendering
    var currentFilter: CIFilter!                                                                                // stores users filter
    {
        didSet
        {
            let filter_name = currentFilter.name.replacingOccurrences(of: "CI", with: "")
            changeFilter.setTitle(filter_name, for: .normal )
        }//didSet
    }//currentFilter
                                                                                                                //      gets various inputs before an output
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Picture Filter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
                                                                                                                // add picture button
    
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")                                                           //default filter
        
        
    }//viewDidLoad

    @objc func importPicture()
    {
        let picker = UIImagePickerController()                                                                  // required for UIImagePickerController
                                                                                                                //           UIImagePickerControllerDelegate and UINavigationControllerDelegate
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }//importPicture
    
    
    
    
    @IBAction func changeFilter(_ sender: UIButton)                                                                                         //sender is called from UIButton
    {
        let alert_controller = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)                        // choose filter
                                                                                                                                            // .actionSheet on Ipads require
                                                                                                                                            //       popoverPresentationController
        alert_controller.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        alert_controller.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        alert_controller.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        alert_controller.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        alert_controller.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        alert_controller.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        alert_controller.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        alert_controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert_controller.popoverPresentationController                                                           // for ipad
        {
            popoverController.sourceView = sender                                                                                           // sender is the button being pressed to send the source
            popoverController.sourceRect = sender.bounds                                                                                    // width and height of the button
        }
            present(alert_controller, animated: true)
        
    }//changeFilter
    
    func setFilter(action: UIAlertAction)
    {
        guard currentImage != nil else {return}                                                                                             // currentImage must exist
                                                                                                                                            // from user importing
        
        guard let actionTile = action.title else {return}                                                                                   // actionTitle = filter selected from  alert_controller
        
        currentFilter = CIFilter(name: actionTile)                                                                                          // selecting the CIFilter from the actionTitle
        
        let beginImage = CIImage(image: currentImage)                                                                                       // setting the user selected image to beginImage
                                                                                                                                            // beginImage is set to CIImage
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)                                                                        // set the filer to the beginImage
        
        applyProcessing()                                                                                                                   // start processing the image
    }
    
    @IBAction func save(_ sender: UIButton)
    {
        guard let image = imageView.image else {
            let alert_controller = UIAlertController(title: "No Image", message: "No Image was selected" , preferredStyle: .alert)
            alert_controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_controller, animated: true)
            
            return
        }                                                       // make sure image exists

        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                                                                                                                // image = what image to save
                                                                                                                // self = who to tell when finished
                                                                                                                // #selector what to run to save the image
        
            
        
                                                                                                                
        
        
        
    }//save
    
    @IBAction func intensityChanged(_ sender: Any)
    {
        applyProcessing()
    }// intensityChanged
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let image = info[.editedImage] as? UIImage else {return}                                              // find the picture to edit
        dismiss(animated: true)
        currentImage = image                                                                                        // modify the current picture
        
        let beginImage = CIImage(image: currentImage)                                                               // CoreImage of UIImage
                                                                                                                    // how image should be transformed
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)                                                //setting the coreImage to UIImage
        
        applyProcessing()                                                                                           //sets the filter
        
    }//imagePickerController
    
    func applyProcessing()                                                                                         //when first imported and slider is moved
    {
        let inputKeys = currentFilter.inputKeys                                                                     //reads out all filters
                                                                                                                   // not all filters have intensity filters
        
        if inputKeys.contains(kCIInputIntensityKey)                                                                 // if filter has an intensity user slider
        {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)                                 //reads in value of slider for the intensity
        }// intenisty
        
        if inputKeys.contains(kCIInputRadiusKey)                                                                    // if filter requires a radius use slider
        {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)                                // slider goes from 0-1 multiple by 200 now its 0-200
            
        } // input radius
        
        if inputKeys.contains(kCIInputScaleKey)                                                                     // filter has scale use slider
        {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)                                  // slider goes from 0-1 multiple by 10 now its 0-10
        }//scale
        
        if inputKeys.contains(kCIInputCenterKey)                                                                    // filter center on image
        {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey:   kCIInputCenterKey)
                                                                                                                    // .5 height and width
        }//center
        
        
        guard let image = currentFilter.outputImage else { return }                                     // cannot convert UIImage to CIIimage directly
                                                                                                        // coreImage -> CGImage -> UIImage

            if let cgimg = context.createCGImage(image, from: image.extent)                             // creates CGImage nothing can be processed before the CG image is created
        {
                let processedImage = UIImage(cgImage: cgimg)                                            //converts cgImage to UIImage
                imageView.image = processedImage
            }// cgimg
        
    }// applyProcessing
    
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {                                                                                                   // when image has been saved
        if let error = error                                                                            // tells the user why there is an error
        {
            let alert_controller = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            alert_controller.addAction(UIAlertAction(title: "OK", style: .default))
        }//error
        
        else
        {
            let message = "The custom image has been saved to your photos."
            let alert_controller = UIAlertController(title: "Saved!", message: message , preferredStyle: .alert)
            alert_controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_controller, animated: true)
            
        } //end else
        
        
    }// image
    
    
}//viewController

