

//
//  ViewController.swift
//  RemoveBackgroundMLApp
//
//  Created by Артем Хребтов on 28.07.2021.
//

import UIKit
import Vision
import CoreML



class ViewController: UIViewController {
    @IBOutlet weak var inputImage: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var outputImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeButton.layer.cornerRadius = 22
        removeButton.layer.borderColor = UIColor.lightGray.cgColor
        removeButton.layer.borderWidth = 1.5
        removeButton.layer.shadowColor = UIColor.white.cgColor
        removeButton.layer.shadowOpacity = 0.8
        removeButton.layer.shadowRadius = 5
        removeButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        //outputImage.isHidden = true
        //outputImage.image = UIImage(systemName: "photo")
        //inputImage.image = UIImage(systemName: "camera")
        
        
        
        outputImage.image = UIImage(named: "test")
        inputImage.image = UIImage(named: "test")
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didImageTapped))
        gesture.numberOfTapsRequired = 1
        inputImage.isUserInteractionEnabled = true
        inputImage.addGestureRecognizer(gesture)
        
        
        
    }
    
    @objc func didImageTapped(){
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.chooseImagePicker(sourse: .camera)
        }
        let photo = UIAlertAction(title: "Photo", style: .default) { _ in
            self.chooseImagePicker(sourse: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        alertController.addAction(camera)
        alertController.addAction(photo)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    func runVisionRequest() {
            
            guard let model = try? VNCoreMLModel(for: DeepLabV3(configuration: .init()).model)
            else { return }
            
            let request = VNCoreMLRequest(model: model, completionHandler: visionRequestDidComplete)
            request.imageCropAndScaleOption = .scaleFill
            
        let inputCG = inputImage.image?.cgImage
        
        let handler = VNImageRequestHandler(cgImage: inputCG!, options: [:])
                
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            //}
        }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
                
                    if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                        let segmentationmap = observations.first?.featureValue.multiArrayValue {
                        
                        let segmentationMask = segmentationmap.image(min: 0, max: 1)
                        
                        outputImage.image = segmentationMask?.resizedImage(for: inputImage.image!.size)
                        //self.outputImage = segmentationMask!.resizedImage(for: self.inputImage.size)!

                        maskInputImage()
                    }
                
        }
    
    func maskInputImage(){
        
//        let points = [GradientPoint(location: 0, color: #colorLiteral(red: 0.6486759186, green: 0.2260715365, blue: 0.2819285393, alpha: 1)), GradientPoint(location: 0.2, color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 0.5028884243)), GradientPoint(location: 0.4, color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 0.3388534331)),
//                  GradientPoint(location: 0.6, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.3458681778)), GradientPoint(location: 0.8, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.3388534331))]
//
//        let bgImage = UIImage(size: inputImage.image!.size, gradientPoints: points, scale: inputImage.image!.scale)!
        
        let bgImage = UIImage.imageFromColor(color: .clear, size: inputImage.image!.size, scale: inputImage.image!.scale)

        let beginImage = CIImage(cgImage: inputImage.image!.cgImage!)
        let background = CIImage(cgImage: (bgImage?.cgImage!)!)
        let mask = CIImage(cgImage: outputImage.image!.cgImage!)
            
            if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
                                            kCIInputImageKey: beginImage,
                                            kCIInputBackgroundImageKey:background,
                                            kCIInputMaskImageKey:mask])?.outputImage
            {
                
                let ciContext = CIContext(options: nil)
                let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent)
                
                outputImage.image = UIImage(cgImage: filteredImageRef!)
            }
        }
    
    @IBAction func buttonTapped(_ sender: Any) {
        runVisionRequest()
    }
    
    
}


