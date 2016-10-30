//
//  ViewController.swift
//  ImageUpload
//
//  Created by Felipe Soares on 29/10/16.
//  Copyright © 2016 Felipe Soares. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        myImageUploadRequest()
    }
    
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        myImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func myImageUploadRequest(){
        
        

        
        let myUrl = URL(string: "http://localhost/uploadImage")
        let request = NSMutableURLRequest(url: myUrl!)
        request.httpMethod = "POST"
        
        let param = [
            "firstName" : "Felipe",
            "lastName" : "Soares",
            "userId" : "4"
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(myImageView.image!, 1)
        
        if(imageData == nil) {return}
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary) as Data
        
        myActivityIndicator.startAnimating()
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
            
            if error != nil{
                print("error: \(error)")
                return
            }
            
            print("******* response = \(response)")
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            print("******* response data = \(responseString)")
            
            do{
               let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                print(json)
                
                
                DispatchQueue.main.async {
                    self.myActivityIndicator.stopAnimating()
                    self.myImageView.image = nil
                }
                
            }catch{
                print("error: \(error)")
            }
            
        
        }
        task.resume()
        
            
    }
    
    
    func createBodyWithParameters(parameters: [String : String]?, filePathKey: String?, imageDataKey:Data, boundary:String) -> NSData {
    
        let body = NSMutableData()
        
        if parameters != nil {
            for(key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let fileName = "user-profile.jpg"
        let mimeType = "image/jpg"
        
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(fileName)\"\r\n")
        body.appendString(string: "Content-Type: \(mimeType)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString(string: "\r\n")
        
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String{
        return "Boundary-\(NSUUID().uuidString)"
    }


}


extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

