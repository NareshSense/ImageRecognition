//
//  NMImageRecognizer.swift
//  ImageRecognition
//
//  Created by Naresh on 24/06/20.
//  Copyright © 2020 Naresh. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision

@available(iOS 13.0, *)
public class NMImageRecognizer {
    
    let model = NMIndianGroceryVersion3()
    var textRecognitionRequest = VNRecognizeTextRequest()
    var recognizedText = ""
    
    public init() {
    }
    
    func setUpTextRequest() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    self.recognizedText = ""
                    for observation in requestResults {
                        guard let candidiate = observation.topCandidates(1).first else { return }
                        self.recognizedText += candidiate.string
                        self.recognizedText += "\n"
                    }
                }
            }
        })
    }
    
    public func classifyImage(_ image : UIImage) -> String {
        var classifiedText = ""
        let size = CGSize(width: 224, height: 224)
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(0.0))
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let scaledImage = scaledImage,
            let buffer = scaledImage.buffer(),
            let output = try? model.prediction(image: buffer) {
            let objectName: String = output.label
            if(objectName.caseInsensitiveCompare("PACKET") == .orderedSame) {
                classifiedText = recognizeText(image)
            }
            else {
                classifiedText = objectName
            }
        }
        else {
            classifiedText = "Sorry, Could not find anything!"
        }
        return classifiedText
    }
    
    func recognizeText(_ image : UIImage) -> String {
        setUpTextRequest()
        guard let cgImg = image.cgImage else {
            fatalError("Missing image to scan")
        }
        let handler = VNImageRequestHandler(cgImage:cgImg, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
        return self.recognizedText
    }
    
}




