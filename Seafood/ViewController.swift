//
//  ViewController.swift
//  Seafood
//
//  Created by Stephen Learmonth on 29/04/2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
//        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Could not convert UIImage into CIImage.")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func detect(image: CIImage) {
        let config = MLModelConfiguration()
        guard let coreMLModel = try? MobileNetV2(configuration: config),
              let model = try? VNCoreMLModel(for: coreMLModel.model) else {
            fatalError("Loading CoreML Model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Could not generate observation results.")
            }
            
            if let firstResult = results.first {
                self.title = firstResult.identifier
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
}

