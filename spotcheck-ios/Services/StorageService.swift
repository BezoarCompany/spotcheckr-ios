import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit

enum SupportedImageType {
    case jpeg
    case png
    case jpg
}

class StorageService: StorageProtocol {
    //
    // MARK: - Type Alias
    //
    typealias JSONDictionary = [String: Any]
    
    func uploadImage(filename: String, imagetype: SupportedImageType, data: Data?) -> Promise<Void> {
        return Promise { promise in
            let firebaseImagesStorageRef = Storage.storage().reference().child(K.Firestore.Storage.IMAGES_ROOT_DIR)
            let newImageStorageRef = firebaseImagesStorageRef.child(filename)
            let metaData = StorageMetadata()

            switch imagetype {
            case .jpeg:
                metaData.contentType = "image/jpeg"
            case .jpg:
                metaData.contentType = "image/jpg"
            case .png:
                metaData.contentType = "image/png"
            }                        
                                            
            let uploadTask = newImageStorageRef.putData(data!, metadata: metaData) { metadata, error in
                if let error = error {
                    return promise.reject(error)
                } else {
                    return promise.fulfill_()
                }
            }
        }
    }
    
    func deleteImage(filename: String) -> Promise<Void> {
        return Promise { promise in
            let firebaseImagesStorageRef = Storage.storage().reference().child(K.Firestore.Storage.IMAGES_ROOT_DIR)
            let imageStorageRef = firebaseImagesStorageRef.child(filename)

            imageStorageRef.delete { err in
                if let error = err {
                    return promise.reject(error)
                } else {
                    return promise.fulfill_()
                }
                
            }
        }
    }
    
}
