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
    var heightsDictionary:  [Double: String] = [:]
    
    public init() {
    }
    
    func setUpTextRequest() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    self.recognizedText = ""
                    self.heightsDictionary = [:]
                    for observation in requestResults {
                        guard let candidate = observation.topCandidates(1).first else { return }
                        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
                        let filterString =                         candidate.string.filter {okayChars.contains($0) }
                        if (!candidate.string.contains("%")) { self.heightsDictionary.updateValue(filterString, forKey: (Double(observation.boundingBox.size.height)*Double(observation.boundingBox.size.width)*Double(observation.boundingBox.maxY)+Double(observation.confidence)))
                        }
                        self.recognizedText += filterString
                        self.recognizedText += "\n"
                    }
                }
            }
        })
        textRecognitionRequest.customWords = ["Maggi","Nestle","kissan","atta","Nature fresh","parle-g","Britania","Bourbon","Digestiv","Noodles","Fortune","Basmati","Rice","Wheat","Shampoo","Juice","Bread","Cadbury","Chakki atta"]
    }
    
    func filterText(_ fullText : String) -> String {
        
        ////sort
        let sortedKeys = Array(self.heightsDictionary.keys).sorted(by: >)
        
        // let textArray = fullText.components(separatedBy: "\n")
        let title    = (sortedKeys.count > 0 ? self.heightsDictionary[sortedKeys[0]] : "") ?? ""
        let subtitle = sortedKeys.count > 1 ? self.heightsDictionary[sortedKeys[1]] : ""
        // let description = (sortedKeys.count > 2 ? self.heightsDictionary[sortedKeys[2]] : "") ?? ""
        var resultString  = title + " "
        resultString.append(subtitle ?? "")
        return resultString
    }
    
    public func classifyImage(_ image : UIImage) -> String {
        var classifiedText = String()
        let text = recognizeText(image)
        
        if (text != "") {
            classifiedText = filterText(text)
        }
        else {
            let size = CGSize(width: 224, height: 224)
            UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(0.0))
            image.draw(in: CGRect(origin: .zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let scaledImage = scaledImage,
                let buffer = scaledImage.buffer(),
                let output = try? model.prediction(image: buffer) {
                let objectName: String = output.label
                classifiedText = objectName
            }
            else {
                classifiedText = "Sorry, Could not find anything!"
            }
        }
        return classifiedText
    }
    
    func recognizeText(_ image : UIImage) -> String {
        setUpTextRequest()
        let reszedImage = image.resizeImage(targetSize: CGSize(width: 227, height: 227))
        guard let cgImg = reszedImage.cgImage else {
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









