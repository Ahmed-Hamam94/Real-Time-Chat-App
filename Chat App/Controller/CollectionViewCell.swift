//
//  CollectionViewCell.swift
//  Chat App
//
//  Created by Ahmed Hamam on 31/01/2023.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var usernameContainer: UIView!
    
    @IBOutlet weak var usernameText: UITextField!
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var actionButton: UIButton!{
        didSet{
            actionButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var slideButton: UIButton!{
        didSet{
            slideButton.layer.cornerRadius = 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setSignInCell(){
      usernameContainer.isHidden = true
      actionButton.setTitle("Login", for: .normal)
       slideButton.setTitle("Sign Up", for: .normal)
    }
    func setSignUpCell(){
       usernameContainer.isHidden = false
       actionButton.setTitle("Sign Up", for: .normal)
       slideButton.setTitle("Sign In", for: .normal)
    }
  
}
