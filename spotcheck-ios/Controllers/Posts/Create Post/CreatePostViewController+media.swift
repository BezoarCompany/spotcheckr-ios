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

        if mediaType as! String == kUTTypeImage as String { // Image
            let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            do {
                try viewModel.checkImageRequirements(image: selectedImage!)
                photoImageView.image = selectedImage
                isMediaChanged = true
            } catch { MediaError.exceedsMaxImageSize
                isMediaChanged = false
                imagePickerController.dismiss(animated: true) {
                    self.snackbarMessage.text = "Image size exceeds \(self.viewModel.configuration!.maxImageUploadSize) MB. Select a different image."
                    MDCSnackbarManager.show(self.snackbarMessage)
                }
            }
        } else if mediaType as! String == kUTTypeMovie as String { // Video
            // Saved URL on the controller for later reference in the submit
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL

            do {

                try viewModel.checkVideoRequirements(url: videoURL!)
                self.selectedVideoFileURL = videoURL
                let imageRef = try viewModel.createThumbnail(url: videoURL!)
                photoImageView.image = UIImage(cgImage: imageRef)
                isMediaChanged = true
            } catch { MediaError.exceedsMaxVideoSize

                isMediaChanged = false
                imagePickerController.dismiss(animated: true) {
                    self.snackbarMessage.text = "Video size exceeds \(self.viewModel.configuration!.maxVideoUploadSize) MB. Please select a smaller video."
                    MDCSnackbarManager.show(self.snackbarMessage)
                }

            } catch { MediaError.errorThumbnailCreation

                isMediaChanged = false
                imagePickerController.dismiss(animated: true) {
                    self.snackbarMessage.text = "Error creating thumbnail. Please select another video."
                    MDCSnackbarManager.show(self.snackbarMessage)
                }
            }
        }

        isMediaChanged = true
    }

    private func imageHandler() {

    }
}
