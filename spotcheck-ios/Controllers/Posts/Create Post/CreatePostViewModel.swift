import UIKit

class CreatePostViewModel {
    var configuration: Configuration? = nil
    
    init() {
        
    }
    
    func checkImageRequirements(image: UIImage) throws {
        if Int(try image.getSizeIn(.megabyte)) > configuration!.maxImageUploadSize {
            throw MediaError.exceedsMaxImageSize
        }
    }
}

enum MediaError: Error {
    case exceedsMaxImageSize
}
