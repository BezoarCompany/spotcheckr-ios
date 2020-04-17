import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import PromiseKit
import AVFoundation

enum SupportedImageType {
    case jpeg
    case png
    case jpg
}

enum MaxImageSizes: Int {
    case profilePicture = 2000000
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
    
    func download(path: String, maxSize: Int64) -> Promise<UIImage> {
        return Promise { promise in
            let imageRef = Storage.storage().reference().child(path)
            imageRef.getData(maxSize: maxSize) { (data, error) in
                if let error = error {
                    return promise.reject(error)
                }
                return promise.fulfill(UIImage(data: data!)!)
            }
        }
    }
    
    //convert Firebase Storage reference into https: url
    func getVideoDownloadURL(filename: String) -> Promise<URL> {
        return Promise { promise in
            let firebaseVideoStorageRef = Storage.storage().reference().child(K.Firestore.Storage.VIDEOS_ROOT_DIR)
            let vidStorageRef = firebaseVideoStorageRef.child(filename)

            vidStorageRef.downloadURL { url, err in
                if let error = err {
                    return promise.reject(error)
                } else {
                    return promise.fulfill(url!)
                }
            }
        }
    }
}
