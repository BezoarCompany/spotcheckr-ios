import UIKit
import iOSDropDown //https://github.com/jriosdev/iOSDropDown
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos

extension CreatePostViewController {
    func initDropDown() {
        workoutTypeDropDown.selectedRowColor = .magenta
        
        //TODO load from Firebase
        workoutTypeDropDown.optionArray = ["Bench TEST", "Cardio TEST", "Games Test"]
        
        workoutTypeDropDown.didSelect{
            (selectedText, index, id) in
            print("\(selectedText) @ index: \(index)")
        }
    }
    
    func initTextViewPlaceholders() {
        subjectTextView.delegate = self
        postBodyTextView.delegate = self
        
        subjectTextView.text = CreatePostViewController.SUBJECT_TEXT_PLACEHOLDER
        subjectTextView.textColor = UIColor.lightGray
        
        postBodyTextView.text = CreatePostViewController.POST_BODY_TEXT_PLACEHOLDER
        postBodyTextView.textColor = UIColor.lightGray
    }
    
    func addKeyboardMenuAccessory() {
        postBodyTextView.inputAccessoryView = keyboardMenuAccessory
        
        keyboardMenuAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
        keyboardMenuAccessory.translatesAutoresizingMaskIntoConstraints = false
        openKeyboardBtn.translatesAutoresizingMaskIntoConstraints = false
        openPhotoGalleryBtn.translatesAutoresizingMaskIntoConstraints = false
        openCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        
        keyboardMenuAccessory.addSubview(openKeyboardBtn)
        keyboardMenuAccessory.addSubview(openPhotoGalleryBtn)
        keyboardMenuAccessory.addSubview(openCameraBtn)
        
        NSLayoutConstraint.activate([
            openKeyboardBtn.leadingAnchor.constraint(equalTo: keyboardMenuAccessory.leadingAnchor, constant: 20),
            openKeyboardBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor),
            openPhotoGalleryBtn.leadingAnchor.constraint(equalTo: openKeyboardBtn.trailingAnchor, constant: 20),
            openPhotoGalleryBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor),
            openCameraBtn.leadingAnchor.constraint(equalTo: openPhotoGalleryBtn.trailingAnchor, constant: 20),
            openCameraBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor)
        ])
    }
    
    @objc func keyboardBtnTapped() {
        print("keyboard")
    }
    
    @objc func openCamera() {
        print("openCamera")
    }
    
    @objc func openPhotoGallery() {
        print("openPhotoGallery")
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            checkPhotoPermissionsAndShowLib()
        }
        
    }
    
    
    func showPhotoLibraryPicker() {
       imagePickerController = UIImagePickerController()
       
       imagePickerController.delegate = self
       imagePickerController.sourceType = .savedPhotosAlbum
       imagePickerController.allowsEditing = false
       
       present(imagePickerController, animated: true, completion: nil)
    }
    
    func checkPhotoPermissionsAndShowLib() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
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
    
    func validatePost() -> Bool {
        
        let alert = UIAlertController(title: "Invalid post", message: "You can always access your content by signing back in", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            //Cancel Action
        }))
        
        if(CreatePostViewController.SUBJECT_TEXT_PLACEHOLDER == subjectTextView.text
            || subjectTextView.text.count < CreatePostViewController.MIN_SUBJECT_LENGTH
            ) {
            alert.message = "Please fill out a valid subject header"
            self.present(alert, animated: true, completion: nil)
            return false
        } else if (CreatePostViewController.POST_BODY_TEXT_PLACEHOLDER == postBodyTextView.text
            || postBodyTextView.text.count < CreatePostViewController.MIN_POSTBODY_LENGTH) {
            alert.message = "Please fill out a valid post body"
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    // TODO: put in PostService
    func createPost() {
        let db = Firestore.firestore()
        let newDocRef = db.collection(K.Firestore.posts).document()
        var postDocument = [
            "created-by" : Auth.auth().currentUser?.uid,
            "created-date" : FieldValue.serverTimestamp(),
            "title" : subjectTextView.text!,
            "description" : postBodyTextView.text!,
            "id" : newDocRef.documentID,
            "modified-date" : FieldValue.serverTimestamp()
            ] as [String : Any]
        
        
        
        if (isImageChanged) {
            print("photo: changed")
            
            // Create reference for the new file on Firebase storage under images/
            let firebaseImagesStorageRef = Storage.storage().reference().child(K.Firestore.Storage.IMAGES_ROOT_DIR)
            let newImageName = "\(NSUUID().uuidString)" + ".png"
            let newImageStorageRef = firebaseImagesStorageRef.child(newImageName)
            
            postDocument.add(["image-path" : newImageName ])
            
            // TODO some checks on image size, loading screen, and promisify....
            if let uploadData = photoImageView.image?.pngData() {
                let uploadTask = newImageStorageRef.putData(uploadData, metadata: nil, completion:
                    { (metadata, error) in
                        if error != nil {
                            print(error.debugDescription)
                            return
                        }
                        print("Successful upload")
                        print(metadata)
                    })
            }
        } else {
            print("photo: NOTs changed")
        }
        
        print(postDocument)
        newDocRef.setData(postDocument)
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
