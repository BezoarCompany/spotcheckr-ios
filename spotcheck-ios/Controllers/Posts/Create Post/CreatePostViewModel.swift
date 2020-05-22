import UIKit
import AVFoundation

class CreatePostViewModel {
    var configuration: Configuration?

    init() {

    }

    func checkImageRequirements(image: UIImage) throws {
        if Int(try image.getSizeIn(.megabyte)) > configuration!.maxImageUploadSize {
            throw MediaError.exceedsMaxImageSize
        }
    }

    func checkVideoRequirements(url: URL) throws {
        let resources = try url.resourceValues(forKeys: [.fileSizeKey])
        let fileSizeBytes = resources.fileSize!
        let fileSizeMB = fileSizeBytes / 1024 / 1024

        if fileSizeMB > configuration!.maxVideoUploadSize {
            throw MediaError.exceedsMaxVideoSize
        }
    }

    func createThumbnail(url: URL) throws -> CGImage {
        //Create thumbnail from the video
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true //set to right side up, no image rotation 90 deg clockwise
        var time = asset.duration
        time.value = max(time.value/2, 1)

        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return imageRef
        } catch {
            throw MediaError.errorThumbnailCreation
        }
    }
}

enum MediaError: Error {
    case exceedsMaxImageSize
    case exceedsMaxVideoSize
    case errorThumbnailCreation
}
