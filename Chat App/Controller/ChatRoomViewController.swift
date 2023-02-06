//
//  ChatRoomViewController.swift
//  Chat App
//
//  Created by Ahmed Hamam on 02/02/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
class ChatRoomViewController: UIViewController {
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var chatTextField: UITextField!
    let indicator = UIActivityIndicatorView(style: .large)
    let db = Firestore.firestore()
    var room : Room?
    var chatMessages = [Message]()
    var messageModel : Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = room?.newRoom
        setUpIndicator()
        setUpTable()
        setUpCell()
        observeMessages()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicator.stopAnimating()

    }
    func setUpIndicator(){
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.chatMessages.count-1, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func displayLastMsg(){
        let indexPath = IndexPath(row: self.chatMessages.count-1, section: 0)
        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    func setUpTable(){
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        chatTableView.allowsSelection = false
    }
    
    func setUpCell(){
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
    }
    
    func observeMessages(){
        guard let roomId = self.room?.roomId else{return}
        let msg = db.collection("rooms").document(roomId).collection("messages")
        msg.order(by: "date").addSnapshotListener { snapshott, _ in
            print(snapshott?.documents ?? "no snap")
            guard let messages = snapshott?.documentChanges else {return}
            for document in messages{
                let message = document.document.data()
                let messageKey = document.document.documentID
                guard let senderName = message["senderName"] as? String , let messageText = message["text"] as? String , let senderId = message["senderId"] as? String else{return}
                let msgModel = Message(senderName: senderName,messageKey: messageKey, messageText: messageText, userId: senderId)
                
                self.chatMessages.append(msgModel)
                print("data:\(message) key: \(messageKey)")
                DispatchQueue.main.async {
                        self.chatTableView.reloadData()
                        self.displayLastMsg()
                        self.indicator.stopAnimating()
                }
            }
        }
    }
    
    func getNameWithId(id:String, completionHandler: @escaping (_ userName: String?)->()){
        let user = db.collection("users").document(id)
        user.addSnapshotListener {[weak self] snapshot, error in
            // guard let self = self else {return}
            if error == nil{
                guard let userNamee = snapshot?.data() else{return}
                if let userName = userNamee["username"] as? String{
                    completionHandler(userName)
                }
            }else{
                completionHandler(nil)
            }
        }
    }
    
    func sendMessage(text: String,completionHandler: @escaping (_ isSuccess:Bool)->Void){
        guard let userId = Auth.auth().currentUser?.uid else{return}
        getNameWithId(id: userId) { userName in
            guard let userName = userName else{return}
            let date = Timestamp(date: Date())
            if let roomId = self.room?.roomId, let userId = Auth.auth().currentUser?.uid{
                let dataArray : [String:Any] = ["senderName":userName , "text": text, "senderId": userId, "date" : date]
                let room = self.db.collection("rooms").document(roomId)
                room.collection("messages").addDocument(data: dataArray) { err in
                    if let err = err {
                        completionHandler(false)
                        print("Error adding document: \(err)")
                    } else {
                        completionHandler(true)
                        
                    }
                }
                
            }
        }
        
    }
    
    @IBAction func sendButton(_ sender: Any) {
        guard let chatText = chatTextField.text, !chatText.isEmpty else{return}
        sendMessage(text: chatText) { isSuccess in
            if isSuccess {
                self.chatTextField.text = ""
                print("message sent")
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                    self.scrollToBottom()
                }
                
            }
        }
        
    }
}
extension ChatRoomViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = chatTableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell") as? ChatTableViewCell else{return UITableViewCell()}
        
        let message = chatMessages[indexPath.row]
        cell.setMessageData(message: message)
        if let userId = Auth.auth().currentUser?.uid{
            if message.userId == userId{
                cell.setBubleType(type: .outgoing)
            }else{
                cell.setBubleType(type: .incoming)
            }
            
        }
        
        return cell
    }
    
    
}
