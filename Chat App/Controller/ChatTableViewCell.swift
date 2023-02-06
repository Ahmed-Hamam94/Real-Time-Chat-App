//
//  ChatTableViewCell.swift
//  Chat App
//
//  Created by Ahmed Hamam on 02/02/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatStackView: UIStackView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var chatTextView: UITextView!
    
    @IBOutlet weak var chatTextContainer: UIView!{
        didSet{
            chatTextContainer.layer.cornerRadius = 6
        }
    }
    enum bubleType{
        case incoming
        case outgoing
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setMessageData(message: Message){
        userNameLabel.text = message.senderName
        chatTextView.text = message.messageText
        
    }
    func setBubleType(type: bubleType){
        switch type{
        case .incoming:
            chatStackView.alignment = .leading
            chatTextContainer.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            chatTextView.textColor = .black
        case .outgoing:
            chatStackView.alignment = .trailing
            chatTextContainer.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            chatTextView.textColor = .black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
