import UIKit

class RecentTableViewCell: UITableViewCell {
    
// MARK: - IBOutlets
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    @IBOutlet weak var unreadView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadView.layer.cornerRadius = unreadView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(recent: RecentChat) {
        
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        messageLabel.text = recent.lastMessage
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.numberOfLines = 2
        messageLabel.minimumScaleFactor = 0.9

        if recent.unreadCounter != 0 {
            self.unreadLabel.text = "\(recent.unreadCounter)"
            self.unreadView.isHidden = false
        } else {
            self.unreadView.isHidden = true
        }
        
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatar) in
                self.avatarImage.image = avatar?.circleMasked
            }
        } else {
            self.avatarImage.image = UIImage(named: "avatar")
        }
    }
}
