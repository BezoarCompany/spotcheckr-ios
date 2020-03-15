import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos
import PromiseKit
import MaterialComponents
import DropDown

extension CreatePostViewController {    
    func initDropDowns() {
        self.exerciseTextField.delegate = self
        self.exerciseTextField.trailingView = Images.chevronUp
        self.exerciseTextField.trailingViewMode = .always
        self.exerciseTextField.trailingView?.isUserInteractionEnabled = true
        self.exerciseTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.exerciseTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.view.addSubview(self.exerciseTextField)
        self.exerciseTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dropdownIconOnClick(sender:))))
        
        self.exerciseDropdown.anchorView = self.exerciseTextField
        self.exerciseDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.toggleDropdownIcon()
            self.exerciseTextField.text = item
            self.selectedExercise = self.exercises[index]
        }
        self.exerciseDropdown.cancelAction = { [unowned self] in
            self.toggleDropdownIcon()
        }
        self.exerciseDropdown.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.exerciseDropdown.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        self.exerciseDropdown.selectionBackgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor
        self.exerciseDropdown.selectedTextColor = ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor
        self.exerciseDropdown.direction = .bottom
        self.exerciseDropdown.bottomOffset = CGPoint(x: 0, y:(self.exerciseDropdown.anchorView?.plainView.bounds.height)! - 25)
        self.exerciseDropdown.dataSource = []
        firstly {
            Services.exercisePostService.getExercises()
        }.done { exercises in
            
            var arr = [String]()
            for exercise in exercises {
                self.exercises.append(exercise.value)
                arr.append(exercise.value.name)
            }
            arr = arr.sorted()
            
            self.exerciseDropdown.dataSource = arr
        }
    }
    
    @objc func dropdownIconOnClick(sender: Any) {
        self.toggleDropdownIcon()
    }
    
    func toggleDropdownIcon() {
        if self.exerciseTextField.trailingView == Images.chevronDown {
            self.exerciseTextField.trailingView = Images.chevronUp
            self.exerciseDropdown.hide()
        }
        else {
            self.exerciseTextField.trailingView = Images.chevronDown
            self.exerciseDropdown.show()
        }
        self.exerciseTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dropdownIconOnClick(sender:))))
        self.exerciseTextField.trailingViewMode = .always
        self.exerciseTextField.trailingView?.isUserInteractionEnabled = true
        self.exerciseTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.exerciseTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }

 
    func initTextViewPlaceholders() {
        subjectTextField.delegate = self
        self.view.addSubview(subjectTextField)
       
        bodyTextField.multilineDelegate = self
        self.bodyTextField.cursorColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.bodyTextField.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.view.addSubview(bodyTextField)
        
    }
    
    func initButtonBarItems() {
        let yesAction = MDCAlertAction(title: "Yes", emphasis: .high) { (action) in
            self.dismiss(animated: true)
        }
        let noAction = MDCAlertAction(title:"No", emphasis: .high)
        
        self.cancelAlertController.addAction(yesAction)
        self.cancelAlertController.addAction(noAction)
        self.cancelAlertController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.cancelButton.action = #selector(cancelButtonOnClick(sender:))
    }
    
    @objc func cancelButtonOnClick(sender: Any) {
        let formIsDirty = {() -> Bool in
            return self.selectedExercise != nil ||
            (self.title != nil && self.title!.trim().count > 0) ||
            (self.bodyTextField.text != nil && self.bodyTextField.text!.trim().count > 0)
        }
       
        if formIsDirty() {
            present(self.cancelAlertController, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    func initActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge        
        self.view.addSubview(activityIndicator)
    }
    
    func applyConstraints() {
        self.exerciseTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 75).isActive = true
        self.exerciseTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.exerciseTextField.trailingAnchor, constant: 15).isActive = true
        
        self.subjectTextField.topAnchor.constraint(equalTo: self.exerciseTextField.bottomAnchor, constant: 15).isActive = true
        self.subjectTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: subjectTextField.trailingAnchor, constant: 15).isActive = true
                
        self.photoImageView.topAnchor.constraint(equalTo: self.subjectTextField.bottomAnchor, constant: 15).isActive = true
        self.photoImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 15).isActive = true
        self.photoImageView.heightAnchor.constraint(equalToConstant: CGFloat(200)).isActive = true
        self.photoImageView.contentMode = .scaleAspectFit
        self.photoImageView.clipsToBounds = true
        
        self.bodyTextField.topAnchor.constraint(equalTo: self.photoImageView.bottomAnchor, constant: 15).isActive = true
        self.bodyTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: bodyTextField.trailingAnchor, constant: 15).isActive = true
        
    }
    
    func addKeyboardMenuAccessory() {
        keyboardMenuAccessory.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
        keyboardMenuAccessory.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        keyboardMenuAccessory.translatesAutoresizingMaskIntoConstraints = false
        openKeyboardBtn.translatesAutoresizingMaskIntoConstraints = false
        openPhotoGalleryBtn.translatesAutoresizingMaskIntoConstraints = false
        openCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        
        keyboardMenuAccessory.addSubview(openKeyboardBtn)
        keyboardMenuAccessory.addSubview(openPhotoGalleryBtn)
        //TODO: Enable in the future.
        //keyboardMenuAccessory.addSubview(openCameraBtn)
        
        NSLayoutConstraint.activate([
            openKeyboardBtn.leadingAnchor.constraint(equalTo: keyboardMenuAccessory.leadingAnchor, constant: 20),
            openKeyboardBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor),
            openPhotoGalleryBtn.leadingAnchor.constraint(equalTo: openKeyboardBtn.trailingAnchor, constant: 20),
            openPhotoGalleryBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor),
//            openCameraBtn.leadingAnchor.constraint(equalTo: openPhotoGalleryBtn.trailingAnchor, constant: 20),
//            openCameraBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor)
        ])
        bodyTextField.textView?.inputAccessoryView = keyboardMenuAccessory
    }
    
    @objc func keyboardBtnTapped() {
         self.bodyTextField.textView!.resignFirstResponder()
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
    
    //for modifying an existing post
    func updatePostWorkflow(post: ExercisePost?) {
        guard let id = post?.id else {
            print ("@updatePostWorkflow -> invalid post args")
            return
        }
        self.activityIndicator.startAnimating()
        
        var postDocument = [
            "modified-date" : FieldValue.serverTimestamp(),
            "title" : subjectTextField.text!,
            "description" : bodyTextField.text!
        ] as [String : Any]
        
        //queue up parallel execution of storage delete old image, storage-upload-new image, and firestore-update post
        var voidPromises = [Promise<Void>]()

        if (isImageChanged) {
            let newImageName = "\(NSUUID().uuidString)" + ".jpeg"
            postDocument.add(["image-path" : newImageName ])
            let jpegData = photoImageView.image!.jpegData(compressionQuality: 1.0)
            
            voidPromises.append(Services.storageService.uploadImage(filename: newImageName, imagetype: .jpeg, data: jpegData))
            
            //post had previous image, so create promise to delete that
            if let imagefilename = post?.imagePath {
                voidPromises.append(Services.storageService.deleteImage(filename: imagefilename))
            }
        }
                   
        //queue up firestore write call
        voidPromises.append(Services.exercisePostService.updatePost(withId: id, dict: postDocument))
        
        firstly {
            //execute all promises in parallel!
            when(fulfilled: voidPromises)
        }.done { _ in
            print("success updating Post")
            self.dismiss(animated: true, completion: nil)
        }.catch { err in
            print("error executing updatePostWorflow promises!")
            print(err)
        }.finally {
            self.activityIndicator.stopAnimating()
        }        
    }
    
    func submitPostWorkflow() {
        self.activityIndicator.startAnimating()
        
        //queue up parallel execution of storage delete old image, storage-upload-new image, and firestore-update post
        var voidPromises = [Promise<Void>]()
        
        var exercises = [Exercise]()
        if (self.selectedExercise != nil ) {
            exercises.append(self.selectedExercise!)
        }
        var exercisePost = ExercisePost(title: subjectTextField.text!,
                                       description: bodyTextField.text!,
                                       createdBy: self.currentUser,
                                       dateCreated: Date(),
                                       dateModified: Date(),
                                       exercises: exercises)
        var uploadImagePromise: Promise<Void> =  Promise<Void> {promise in
            return promise.fulfill_()
        }
        
        if (isImageChanged) {
            let newImageName = "\(NSUUID().uuidString)" + ".jpeg"
            exercisePost.imagePath = newImageName
            
            let jpegData = photoImageView.image!.jpegData(compressionQuality: 1.0)
            uploadImagePromise = Services.storageService.uploadImage(filename: newImageName, imagetype: .jpeg, data: jpegData)
        }
        
        firstly {
            when(fulfilled: uploadImagePromise, Services.exercisePostService.createPost(post: exercisePost))
        }.done { voidResult, newPost in
            self.dismiss(animated: true) {
                self.snackbarMessage.text = "Post created."
                let action = MDCSnackbarMessageAction()
                action.handler = {() in
                    self.createdPostHandler!(newPost)
                }
                action.title = "View Post"
                self.snackbarMessage.action = action
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.catch { err in
            //TODO: Show snackbar error message.
            print("error executing updatePostWorflow promises!")
            print(err)
        }.finally {
            self.activityIndicator.stopAnimating()
        }
    }
}
