import UIKit
import PromiseKit
import FirebaseStorage

protocol StorageProtocol {
    func uploadImage(filename: String, imagetype: SupportedImageType, data: Data?) -> Promise<Void>
    func deleteImage(filename: String) -> Promise<Void>
    func download(path: String, maxSize: Int64) -> Promise<UIImage>
    
    func getVideoDownloadURL(filename: String) -> Promise<URL>
    func uploadVideo(filename: String, videotype: SupportedVideoType, url: URL) -> Promise<Void>
//    func deleteVideo(filename: String) -> Promise<Void>
    
}

