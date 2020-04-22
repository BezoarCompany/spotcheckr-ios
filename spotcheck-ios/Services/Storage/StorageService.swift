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

enum SupportedVideoType {
    case mov
    case mp4
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
    
    #if DEVEL
    func getVideoDownloadURL(filename: String) -> Promise<URL> {
        print("stubbed DEVEL")
        return Promise { promise in
            let urlPath = Bundle.main.path(forResource: "bulletTrain", ofType: "mp4")!
            let url = URL(fileURLWithPath: urlPath)
            return promise.fulfill(url)
        }
    }
    
    #else
    
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
    
    #endif
    
    
    func uploadVideo(filename: String, videotype: SupportedVideoType, url: URL) -> Promise<Void> {
        return Promise { promise in
            let firebaseVideoStorageRef = Storage.storage().reference().child(K.Firestore.Storage.VIDEOS_ROOT_DIR)
            let newStorageRef = firebaseVideoStorageRef.child(filename)
            let metaData = StorageMetadata()

            switch videotype {
            case .mov:
                metaData.contentType = "video/quicktime"
            case .mp4:
                metaData.contentType = "video/mp4"
            }
                                                        
            //convert from URL to Data. putFile(from: url) function doesn't seem to work b/c of limited access to file system?
            //https://stackoverflow.com/a/39693142/9882015
            let data = url.dataRepresentation
            
            let uploadTask = newStorageRef.putData(data, metadata: metaData) { metadata, error in
                if let error = error {
                    return promise.reject(error)
                } else {
                    return promise.fulfill_()
                }
            }
        }
    }
    //func deleteVideo(filename: String) -> Promise<Void>
}
