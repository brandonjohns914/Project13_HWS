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
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        
        
    }//viewDidLoad

    @objc func importPicture()
    {
        let picker = UIImagePickerController()
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }//importPicture
    
    
    
    
    @IBAction func changeFilter(_ sender: UIButton)
    {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController
        {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
            present(ac, animated: true)
        
    }//changeFilter
    
    func setFilter(action: UIAlertAction)
    {
        guard currentImage != nil else {return}
        
        guard let actionTile = action.title else {return}
        
        currentFilter = CIFilter(name: actionTile)
        
        let beginImage = CIImage(image: currentImage)
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @IBAction func save(_ sender: Any)
    {
        guard let image = imageView.image else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        
        
    }//save
    
    @IBAction func intensityChanged(_ sender: Any)
    {
        applyProcessing()
    }// intensityChanged
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let image = info[.editedImage] as? UIImage else {return}
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }//imagePickerController
    
    func applyProcessing()
    {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey)
        {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }// contains
        
        if inputKeys.contains(kCIInputRadiusKey)
        {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
            
        } // input radius
        
        if inputKeys.contains(kCIInputScaleKey)
        {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }//scale
        
        if inputKeys.contains(kCIInputCenterKey)
        {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey:   kCIInputCenterKey)
        }//center
        
        guard let image = currentFilter.outputImage else { return }

            if let cgimg = context.createCGImage(image, from: image.extent)
        {
                let processedImage = UIImage(cgImage: cgimg)
                imageView.image = processedImage
            }// cgimg
        
    }// applyProcessing
    
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let error = error
        {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        }//error
        
        else
        {
            let message = "Your altered image has been saved to your photos."
            let ac = UIAlertController(title: "Saved!", message: message , preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        } //end else
        
        
    }// image
    
    
}//viewController

