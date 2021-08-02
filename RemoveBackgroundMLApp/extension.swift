//
//  extension.swift
//  RemoveBackgroundMLApp
//
//  Created by Артем Хребтов on 28.07.2021.
//

import Foundation
import UIKit

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    func chooseImagePicker (sourse: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourse) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourse
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        inputImage.image = image
        inputImage.contentMode = .scaleAspectFit
        inputImage.clipsToBounds = true
        
        
        outputImage.isHidden = false
        outputImage.image = image
        outputImage.contentMode = .scaleAspectFit
        outputImage.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }

  
}

extension UIImage {
    class func imageFromColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1), scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizedImage(for size: CGSize) -> UIImage? {
            let image = self.cgImage
            print(size)
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: image!.bitsPerComponent,
                                    bytesPerRow: Int(size.width),
                                    space: image?.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: image!.bitmapInfo.rawValue)
            context?.interpolationQuality = .high
            context?.draw(image!, in: CGRect(origin: .zero, size: size))

            guard let scaledImage = context?.makeImage() else { return nil }

            return UIImage(cgImage: scaledImage)
    }
    
    convenience init?(size: CGSize, gradientPoints: [GradientPoint], scale : CGFloat) {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }       // If the size is zero, the context will be nil.
        guard let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: gradientPoints.compactMap { $0.color.cgColor.components }.flatMap { $0 }, locations: gradientPoints.map { $0.location }, count: gradientPoints.count) else {
            return nil
        }

        context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions())
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        self.init(cgImage: image)
        defer { UIGraphicsEndImageContext() }
    }

}



extension UIImage {
  func withAlphaComponent(_ alpha: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    defer { UIGraphicsEndImageContext() }

    draw(at: .zero, blendMode: .normal, alpha: alpha)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}

struct GradientPoint {
   var location: CGFloat
   var color: UIColor
}


