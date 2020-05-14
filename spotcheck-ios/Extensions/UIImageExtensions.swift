import UIKit

extension UIImage {
    func getSizeIn(_ unit: DigitalStorageUnit) throws -> Double {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else { throw String("Unable to retrieve image data") }

        var size = Double(imageData.count)
        switch unit {
        case .byte:
            break
        case .kilobyte:
            size /= 1024
        case .megabyte:
            size = size / 1024 / 1024
        case .gigabyte:
            size = size / 1024 / 1024 / 1024
        }

        return size
    }
}
