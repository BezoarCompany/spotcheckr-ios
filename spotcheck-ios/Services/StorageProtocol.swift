import PromiseKit
import FirebaseStorage

protocol StorageProtocol {
    func uploadImage(filename: String, imagetype: SupportedImageType, data: Data?) -> Promise<Void>
    func deleteImage(filename: String) -> Promise<Void>
}

