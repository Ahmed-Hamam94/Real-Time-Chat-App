//
//  ViewController.swift
//  Chat App
//
//  Created by Ahmed Hamam on 29/01/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AuthViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollection()
        setUpCell()
    }
    
    func setUpCollection(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setUpCell(){
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    func displayError(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
}


extension AuthViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else{ return UICollectionViewCell()}
        if indexPath.row == 0{ // signin cell
            cell.setSignInCell()
            cell.slideButton.addTarget(self, action: #selector(slideToSignUp(_ :)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(pressLogIn(_ :)), for: .touchUpInside)
        }else{ // sign up cell
            cell.setSignUpCell()
            cell.slideButton.addTarget(self, action: #selector(slideToSignIn(_ :)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(pressSignUp(_ :)), for: .touchUpInside)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    @objc func slideToSignUp(_ sender: UIButton){
        let indexPath = IndexPath(row: 1, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    @objc func slideToSignIn(_ sender: UIButton){
        let indexPath = IndexPath(row: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    @objc func pressSignUp(_ sender: UIButton){
        let indexPath = IndexPath(row: 1, section: 0)
        guard let cell = self.collectionView.cellForItem(at: indexPath) as?
                CollectionViewCell, let emailAddress = cell.emailText.text, let password = cell.passwordText.text, let userName = cell.usernameText.text else{return}
        
        if emailAddress.isEmpty == true || password.isEmpty == true || userName.isEmpty == true{
            self.displayError(message: "Please Enter Empty Fields")
        }else{
            Auth.auth().createUser(withEmail: emailAddress, password: password){ [weak self] authResult, error in
                guard let self = self else { return }
                if error == nil{
                    guard let userId = authResult?.user.uid else {return}
                    self.dismiss(animated: true)
                    let user = self.db.collection("users").document(userId)
                    let dataArray:[String:Any] = ["username" : userName]
                    user.setData(dataArray)
                    print(userId)
                }else{
                    print(error ?? "")
                }
            }
        }
        
    }
    
    @objc func pressLogIn(_ sender: UIButton){
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = self.collectionView.cellForItem(at: indexPath) as?
                CollectionViewCell, let emailAddress = cell.emailText.text, let password = cell.passwordText.text else{return}
        if emailAddress != "" && password != ""{
            
            Auth.auth().signIn(withEmail: emailAddress, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if error == nil{
                    self.dismiss(animated: true)
                    print(authResult ?? "")
                }else{
                    self.displayError(message: "Wrong UserName or Password")
                    print(error ?? "")
                }
            }
        }else  if emailAddress == "" || password == ""{
            self.displayError(message: "Please Enter Empty Fields")
        }
    }
}
