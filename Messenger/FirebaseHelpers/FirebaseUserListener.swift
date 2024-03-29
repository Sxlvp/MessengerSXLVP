import Foundation
import FirebaseAuth

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init () {}
    
// MARK: - Login
    
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            
            if error == nil && authDataResult!.user.isEmailVerified {
                
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                
                completion(error, true)
            } else {
                print("email is not verified ")
                completion(error, false)
            }
        }
    }
    
// MARK: - Register
    
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
     
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            
            completion(error)
            
            if error == nil {
    
                // Send verification email
                
                authDataResult!.user.sendEmailVerification { error in
                    if let error {
                        print("auth email sent with error: ", error.localizedDescription)
                    }
                }
                
                // Create user and save it
                
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, status: "Online")
                    
                    saveUserLocally(user)
                    self.saveUserToFirestore(user)
                }
            }
        }
    }
    
// MARK: - Resend link methods
    
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { error in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                
                completion(error)
            })
        })
    }
    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
// MARK: - Save users
    
    func saveUserToFirestore(_ user: User) {
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, " adding user")
        }
    }
    
// MARK: - Download user from Firebase
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        
        FirebaseReference(.User).document(userId).getDocument { querySnapshot, error in
            
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("Documnet does not exist")
                }
            case .failure(let error):
                print("Error decoding user ", error)
            }
        }
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void ) {
        
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            
            guard let document = querySnapshot?.documents else {
                print("no documents in all users")
                return
            }
            
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            completion(users)
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIds {
            
            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                
                guard let document = querySnapshot else {
                    print("no document for user")
                    return
                }
                
                let user = try? document.data(as: User.self)

                usersArray.append(user!)
                count += 1
                
                
                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }
    
    //MARK: - Update
    
    func updateUserInFirebase(_ user: User) {
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "updating user...")
        }
    }
}
