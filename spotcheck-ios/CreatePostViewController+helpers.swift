import UIKit
import iOSDropDown //https://github.com/jriosdev/iOSDropDown
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos
import PromiseKit

extension CreatePostViewController {
    func initDropDown() {
        workoutTypeDropDown.selectedRowColor = .magenta
        workoutTypeDropDown.textColor = .blue
        firstly {
            Services.exercisePostService.getExerciseTypes()
        }.done { exerciseTypes in
            
            var arr = [String]()
            for et in exerciseTypes {                
                arr.append(et.value.rawValue)
            }
            self.workoutTypeDropDown.optionArray = arr
        }.catch { err in
            print(err)
            self.workoutTypeDropDown.optionArray = ["Strength", "Endurance", "Balance", "Flexibility"]
        }
                
        
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
    
    func initActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        self.view.addSubview(activityIndicator)
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
    
    func submitPostWorkflow() {
        self.activityIndicator.startAnimating()
        
        var postDocument = [
            "created-by" : Auth.auth().currentUser?.uid,
            "created-date" : FieldValue.serverTimestamp(),
            "title" : subjectTextView.text!,
            "description" : postBodyTextView.text!,
            "modified-date" : FieldValue.serverTimestamp()
            ] as [String : Any]
        
        if (isImageChanged) { //store image first, then write Post (text) to firebase (with image name), finally close activityIndicators
            let newImageName = "\(NSUUID().uuidString)" + ".jpeg"
                            
            postDocument.add(["image-path" : newImageName ])
                            
            let jpegData = photoImageView.image!.jpegData(compressionQuality: 1.0)
            
            firstly {
                Services.storageService.uploadImage(filename: newImageName, imagetype: .jpeg, data: jpegData)
            }.done {
                Services.exercisePostService.writePost(dict: postDocument)
                self.dismiss(animated: true, completion: nil)
            }.catch { error in
                print(error)
            }.finally {
                self.activityIndicator.stopAnimating()
            }
        } else {//only write Post (text) to firebase
            firstly {
                Services.exercisePostService.writePost(dict: postDocument)
            }.done {
                self.dismiss(animated: true, completion: nil)
            }.catch { error in
                print(error)
            }.finally {
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
}
