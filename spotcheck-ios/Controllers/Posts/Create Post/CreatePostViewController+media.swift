import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos
import PromiseKit
import MaterialComponents
import DropDown
import MobileCoreServices
import AVFoundation

extension CreatePostViewController {
    func showPhotoLibraryPicker() {
        imagePickerController = UIImagePickerController()

        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = [ kUTTypeImage as String, kUTTypeMovie as String ] // Explicitly added movie option for selecting video files

        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - objc functions
    @objc func openMediaOptions() {
        let mediaActionSheet = UIElementFactory.getActionSheet()
        mediaActionSheet.title = "Choose Media Source"
        
        let mediaGalleryAction = MDCActionSheetAction(title: "Photo and Video Gallery", image: UIImage(systemName: "photo.on.rectangle"), handler: { (_) in
            self.openMediaGallery()
        })
        
        mediaActionSheet.addAction(mediaGalleryAction)
        
        self.present(mediaActionSheet, animated: true, completion: nil)
        
    }
    
    @objc func openCamera() {
        print("openCamera")
    }
    
    @objc func openMediaGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            checkPhotoPermissionsAndShowLib()
        }
    }
    
    @objc func checkPhotoPermissionsAndShowLib() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        //TODO: Handle the cases where the status is .restricted, .denied, .default
        switch photoAuthorizationStatus {
        case .authorized:
            showPhotoLibraryPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ newStatus in
                print("status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {
                    print("success")
                    self.showPhotoLibraryPicker()
                }
            })
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            print("User has denied the permission.")
        @unknown default:
            print("User has unknown authorization to view library")
        }
    }
}

extension CreatePostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        handleMediaSelectedForInfo(info: info)

        imagePickerController.dismiss(animated: true, completion: nil)
    }

    private func handleMediaSelectedForInfo(info: [UIImagePickerController.InfoKey: Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject

        var chosenImage = UIImage()

        if mediaType as! String == kUTTypeImage as String { // Image
            chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            photoImageView.image = chosenImage
        } else if mediaType as! String == kUTTypeMovie as String { // Video
            // Saved URL on the controller for later reference in the submit
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            self.selectedVideoFileURL = videoURL

            //Create thumbnail from the video
            let asset = AVAsset(url: videoURL!)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true //set to right side up, no image rotation 90 deg clockwise

            var time = asset.duration
            time.value = min(time.value, 2)

            do {
                let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                photoImageView.image = UIImage(cgImage: imageRef)
            } catch {
                //TODO: Show error message when this happens?
                print("Error creating video thumbnail")
            }
        }

        isMediaChanged = true

    }
}
