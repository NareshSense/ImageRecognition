
Pod::Spec.new do |spec|
  spec.name         = "ImageRecognition"
  spec.version      = "4.0.0"
  spec.summary      = "A framework to recognise images."
  spec.description  = <<-DESC
                    ImageRecognition is a small and test  framework that allows to monitor and recognise images!
                   DESC
  spec.homepage     = "https://appcoda.com"
  spec.license      = "MIT"
  spec.author       = { "NARESH" => "####" }
  spec.ios.deployment_target = "13.1"
  spec.source       = { :git => "https://github.com/NareshSense/ImageRecognition.git", :tag => "#{spec.version}" }
  spec.source_files = "ImageRecognition/*"
  spec.swift_version = "5.0"
end 
