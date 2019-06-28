//
//  RegistrationVC.swift
//  Restaurant
//
//  Created by Dilip Bakotiya on 03/05/19.
//  Copyright © 2019 Archirayan. All rights reserved.
//

import UIKit
import GBFloatingTextField
import Foundation
import Alamofire
import Photos

class RegistrationVC: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController()
    
    var imageName:String = "file.jpeg"
    
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var txtRePassword: GBTextField!
    @IBOutlet var txtPassword: GBTextField!
    @IBOutlet var txtAddress: GBTextField!
    @IBOutlet var txtEmailAddress: GBTextField!
    @IBOutlet var txtMobileNo: GBTextField!
    @IBOutlet var txtUserName: GBTextField!
    
    @IBOutlet var mainScrollViee:UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainScrollViee.delegate = self
        mainScrollViee.isScrollEnabled = true
        
       shakeTextField(textField: txtUserName)
       shakeTextField(textField: txtMobileNo)
       shakeTextField(textField: txtEmailAddress)
       shakeTextField(textField: txtAddress)
       shakeTextField(textField: txtPassword)
       shakeTextField(textField: txtRePassword)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITextField Deleget Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    //MARK:- Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    
    // MARK: - Button Action Method
    @IBAction func btnSignUpAction(_ sender: Any) {
        if txtUserName.text == ""{
            Alert.show(vc: self, titleStr: "Alert", messageStr: "All Fields Are Required")
        }else if txtMobileNo.text == ""{
            Alert.show(vc: self, titleStr: "Alert", messageStr: "All Fields Are Required")
        }else if !isValidEmail(testStr: txtEmailAddress.text ?? ""){
            Alert.show(vc: self, titleStr: "Alert", messageStr: "Please Enter Valid Email ID")
        }else if txtAddress.text == ""{
            Alert.show(vc: self, titleStr: "Alert", messageStr: "All Fields Are Required")
        }else if txtPassword.text == "" && txtRePassword.text == ""{
            Alert.show(vc: self, titleStr: "Alert", messageStr: "All Fields Are Required")
        }else if txtPassword.text != txtRePassword.text{
            Alert.show(vc: self, titleStr: "Alert", messageStr: "All Fields Are Required")
        }else{
          RegisterUser()
        }
        //self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func btnLoginAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func btnSelectUserImageAction(_ sender: Any) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- TextField Animation
    func shakeTextField(textField: GBTextField)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.09
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 10, y: textField.center.y))
        textField.layer.add(animation, forKey: "position")
        
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "",
                                                             attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
        
    }
    
    //MARK:- Select user image method
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(picker, animated: true, completion: nil)
        }
        else
        {
            Alert.show(vc: self, titleStr: "Alert", messageStr: "You don't have camera")
        }
    }
    func openGallary()
    {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    //PickerView Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // imageViewPic.contentMode = .scaleToFill
            imgUser.image = pickedImage
            imgUser.layer.cornerRadius = imgUser.layer.frame.size.width / 2
            imgUser.layer.masksToBounds = true
        }
        if let asset = info["UIImagePickerControllerPHAsset"] as? PHAsset{
            if let fileName = asset.value(forKey: "filename") as? String{
                print(fileName)
                imageName = fileName
            }
        }

   
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
        print("picker cancel.")
    }
    
    func RegisterUser(){
        ACProgressHUD.shared.showHUD()
       // http://hire-people.com/host2/restaurants/apis/registration.php?user_login=archirayan30&user_contact=639857410&user_email=archirayan30@gmail.com&user_address=pali&user_pass=archi&user_re_pass=archi&image

        let ApiMethodName = Constant.BASE_URL + "registration.php"
        let params: Parameters = ["user_login": txtUserName.text!,"user_contact": txtMobileNo.text!,"user_email":txtEmailAddress.text!,"user_address":txtAddress.text!,"user_pass":txtPassword.text!,"user_re_pass":txtRePassword.text!]
     
        Alamofire.upload(multipartFormData:
            {
                (multipartFormData) in
                multipartFormData.append(UIImageJPEGRepresentation(self.imgUser.image!, 0.1)!, withName: "image", fileName: self.imageName, mimeType: "image/jpeg")
                for (key, value) in params
                {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
        }, to:ApiMethodName,headers:nil)
        { (result) in
            switch result {
            case .success(let upload,_,_ ):
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                upload.responseJSON
                    { response in
                        //print response.result
                        if response.result.value != nil
                        {
                            let dic = response.result.value as! NSDictionary
                            let status = dic["status"] as! String
                            if status == "true"{
                                let msg = dic["msg"] as? String ?? "Registration Succesfully"
                                let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                                
                                // Create the actions
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    NSLog("OK Pressed")
                                    self.navigationController?.popViewController(animated: true)
                                }
                                // Add the actions
                                alertController.addAction(okAction)
                                
                                
                                // Present the controller
                                self.present(alertController, animated: true, completion: nil)
                                
                            }else{
                                let msg = dic["msg"] as? String ?? "Registration Fail"
                                Alert.show(vc: self, titleStr: "Alert", messageStr: msg)
                            }
                            ACProgressHUD.shared.hideHUD()
                            
                        }
                }
            case .failure(let encodingError):
                ACProgressHUD.shared.hideHUD()
                Alert.show(vc: self, titleStr: "Alert", messageStr: "Something Went Wrong")
                break
            }
        }
    }
    
 

}
