import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    
    Firestore.firestore().collection(collectionReference.rawValue)
}
