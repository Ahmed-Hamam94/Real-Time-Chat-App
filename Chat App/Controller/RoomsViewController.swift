//
//  HomeViewController.swift
//  Chat App
//
//  Created by Ahmed Hamam on 31/01/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
class RoomsViewController: UIViewController {
    
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var roomsTableView: UITableView!
    let db = Firestore.firestore()
    var rooms = [Room]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        observeRooms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            displayLogin()
        }
    }
    
    func setUpTable(){
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
    }
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        displayLogin()
    }
    
    
    @IBAction func createRoomButton(_ sender: UIButton) {
        guard let newRoom = roomTextField.text, !newRoom.isEmpty else {return}
        let date = Timestamp(date: Date())
        db.collection("rooms").addDocument(data: [
            "newRoom": newRoom,
            "date" : date
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.roomTextField.text = ""
            }
        }
      }
 
      
    func observeRooms(){
        db.collection("rooms").order(by: "date").addSnapshotListener { snapshot, _ in
            guard let dataArray = snapshot?.documentChanges else{return}
            print("datasnap = \(dataArray)")
            for document in dataArray{
                let roomName = document.document.data()
                                    print("data:\(roomName)")
                                let idroom = document.document.documentID
                                    if let newRoom = roomName["newRoom"] as? String{
                                        let room = Room(roomId:idroom ,newRoom: newRoom)
                                        self.rooms.append(room)
                                        print("name =\(newRoom)")
                                    }
                                           }
            DispatchQueue.main.async {
                self.roomsTableView.reloadData()
            }
        }        
    }
    
    func displayLogin(){
        let SignInOut = self.storyboard?.instantiateViewController(withIdentifier: "SignInOutViewController") as! AuthViewController
        self.present(SignInOut, animated: true)
    }
    
}

extension RoomsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = rooms[indexPath.row].newRoom
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRoom = rooms[indexPath.row]
        guard let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else{return}
        chatVC.room = selectedRoom
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
