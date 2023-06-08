import UIKit

class SettingsTableViewController: UITableViewController {
    
// MARK: - IBOutlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
// MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showUserInfo()
    }
    
// MARK: - TableViewDelegates
        
        override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            
            let headerView = UIView()
            headerView.backgroundColor = UIColor(named: "tableViewBackgroundColor")
            
            return headerView
        }
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            
            section == 0 ? 0.0 : 10.0
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            if indexPath.section == 0 && indexPath.row == 0 {
                performSegue(withIdentifier: "settingsToEditProfileSegue", sender: self)
            }
        }
    
// MARK: - IBActions
    
    @IBAction func tellFriend(_ sender: UIButton) {
        print("Tell a friend")
    }
    
    @IBAction func TermsAndConditions(_ sender: UIButton) {
        print("Terms and conditions")
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        
        FirebaseUserListener.shared.logOutCurrentUser { error in
            
            if error == nil {
                
                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true)
                }
            }
        }
    }
    
// MARK: - UpdateUI
    
    private func showUserInfo() {
        
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            appVersion.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            if user.avatarLink != "" {
                
                FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                    self.avatarImage.image = avatarImage?.circleMasked
                }
            }
        }
    }
}
