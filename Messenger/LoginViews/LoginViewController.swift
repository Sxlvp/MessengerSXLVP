import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

// MARK: - IBOutlets
    
    // Labels
    
    @IBOutlet weak var statusLable: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    // TextFields
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    // Buttons
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var resendEmailOutlet: UIButton!
    @IBOutlet weak var forgotPasswordOutlet: UIButton!
    
    // View
    
    @IBOutlet weak var lineViewRepeatPassword: UIView!
    
// MARK: - Vars
    
    var isLogin = true
    
// MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUIFor(login: isLogin)
        setupTextFieldDelegates()
        setupBackgroundTap()
    }

// MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            isLogin ? loginUser() : registerUser()
        } else {
            ProgressHUD.showFailed("All Fields are required")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        
        if isDataInputedFor(type: "password") {
            resetPassword()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: UIButton) {
        
        if isDataInputedFor(type: "password") {
            resendVerificationEmail()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
// MARK: - Setup
    
    private func setupTextFieldDelegates() {
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        view.endEditing(false)
    }
    
// MARK: - Animations
    
    private func updatePlaceholderLabels(textField: UITextField) {
        
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "Repeat password" : ""
        }
    }
    
    private func updateUIFor(login: Bool) {
        
        loginButtonOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signUpOutlet.setTitle(login ? "Sign up!" : "Login", for: .normal)
        signUpLabel.text = login ? "No account?" : "Have an account?"
        statusLable.text = login ? "Login" : "Register"
        
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.lineViewRepeatPassword.isHidden = login
            self.forgotPasswordOutlet.isHidden = !login
        }
    }
    
// MARK: - Helpers
    
    private func registerUser() {
        if passwordTextField.text == repeatPasswordTextField.text {
            
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            FirebaseUserListener.shared.registerUserWith(email: email, password: password) { error in
                if error == nil {
                    ProgressHUD.showSucceed("Verification email sent")
                    self.resendEmailOutlet.isHidden = false
                } else {
                    ProgressHUD.showFailed(error!.localizedDescription)
                }
            }
        } else {
            ProgressHUD.showFailed("The password don't match")
        }
    }
    
    private func loginUser() {
        
        FirebaseUserListener.shared.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { error, isEmailVerified in
            
            if error == nil {
                if isEmailVerified {
                    self.goToApp()
                } else {
                    ProgressHUD.showFailed("Please verify email")
                    self.resendEmailOutlet.isHidden = false
                }
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { error in
            
            if error == nil {
                ProgressHUD.showSucceed("Reset link sent to email")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { error in
            
            if error == nil {
                ProgressHUD.showSucceed("New verification email sent")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func isDataInputedFor(type: String) -> Bool {
        
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
// MARK: - Navigation
    
    private func goToApp() {
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        present(mainView, animated: true)
    }
}
