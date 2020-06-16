//
//  ViewController.swift
//  SeeFood
//
//  Created by Tan Nguyen on 16/6/20.
//  Copyright © 2020 Tan Nguyen. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    //Possible Error:
    //source type 1 error/
    //crash due to privacy from user permission (camera/photo library)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //allow user to take image using camera //
        imagePicker.allowsEditing = false //allow editing,user crop image
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        //take photo or pick photo
        present(imagePicker, animated: true, completion: nil)//we dont want anything happen after that
        
        //send image to machine learning
    }
    
    func detect(image : CIImage) {
        //1.load model using inceptionv3 model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading CoreML Model Failed")
        }
        //2.request ask model to classify whatever data we pass
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image")
            }
            print(results) //call back trigger from number 4.below
            if let firstResult = results.first{ //first result is the most confidence
                if firstResult.identifier.contains("hotdog"){
                    self.navigationItem.title = "Hotdog!"
                }else{
                    //self.navigationItem.title = "Not Hotdog!"
                    self.navigationItem.title = "\(firstResult.identifier) \(firstResult.confidence.binade * 100)%)"
                    
                }
            }
            
        }
        //3.pass data to model using hander
        let hander = VNImageRequestHandler(ciImage: image)
        do{
            try hander.perform([request])
            //4.use handler to perform request
            //-> output is request or error
        }catch{
            print(error)
        }
       
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //hold image user selected
        if let userPickImage = info[UIImagePickerController.InfoKey.originalImage]  as? UIImage {//not UIImagePickerCOntrollerOriginalImage?
        
            imageView.image = userPickImage
            
            //convert to ci image using for CoreML
            guard let ciImage = CIImage(image: userPickImage) else{
                fatalError("Could not convert to CI Image ")//in case fail
            }
            detect(image: ciImage)
            
        }
        
        //dismiss image and go back to view controller
        imagePicker.dismiss(animated: true, completion: nil)
    }

}

