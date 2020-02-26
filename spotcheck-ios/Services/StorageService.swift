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
        
    func uploadImage(filename: String, imagetype: SupportedImageType, uiimage: UIImage) -> StorageUploadTask {
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
        
        let uploadData = uiimage.jpegData(compressionQuality: 0.0)!
                                        
        let uploadTask = newImageStorageRef.putData(uploadData, metadata: metaData, completion:
        { (metadata, error) in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            print("Successful upload")
            print(metadata)
            return
        })
        
        return uploadTask
    }
}
