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
        self.workoutTypeTextField.delegate = self
        self.workoutTypeTextField.trailingView = Images.chevronUp
        //self.workoutTypeTextField.trailingViewMode = .always
        self.workoutTypeTextField.trailingView?.isUserInteractionEnabled = true
        self.workoutTypeTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.workoutTypeTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.view.addSubview(self.workoutTypeTextField)
        //self.workoutTypeTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(workoutTypeIconOnClick(sender:))))
        self.workoutTypeTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.workoutTypeIconOnClick(textField:dropdown:))))
        self.workoutTypeTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 75).isActive = true
        self.workoutTypeTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.workoutTypeTextField.trailingAnchor, constant: 15).isActive = true
        
        
        self.workoutTypeDropDown.anchorView = self.workoutTypeTextField
        self.workoutTypeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            //self.toggleWorkoutTypeIcon()
            self.workoutTypeTextField.text = item
            self.toggleWorkoutTypeIcon(field: self.workoutTypeTextField, dropdown: self.workoutTypeDropDown)
        }
        self.workoutTypeDropDown.cancelAction = { [unowned self] in
            //self.toggleWorkoutTypeIcon()
            self.toggleWorkoutTypeIcon(field: self.workoutTypeTextField, dropdown: self.workoutTypeDropDown)
        }
        self.workoutTypeDropDown.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.workoutTypeDropDown.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        self.workoutTypeDropDown.selectionBackgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor
        self.workoutTypeDropDown.selectedTextColor = ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor
        self.workoutTypeDropDown.direction = .bottom
        self.workoutTypeDropDown.bottomOffset = CGPoint(x: 0, y:(self.workoutTypeDropDown.anchorView?.plainView.bounds.height)! - 25)
        
///////
        
        self.exercisesTextField.delegate = self
        self.exercisesTextField.trailingView = Images.chevronUp
        //self.exercisesTextField.trailingViewMode = .always //breaks
        self.exercisesTextField.trailingView?.isUserInteractionEnabled = true
        self.exercisesTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.exercisesTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.view.addSubview(self.exercisesTextField)
        /*
        //self.exercisesTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.workoutTypeIconOnClick(textField:dropdown:))))
        
        self.exerciseDropDown.anchorView = self.exercisesTextField
        self.exerciseDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            //self.toggleWorkoutTypeIcon(field: self.exercisesTextField, dropdown: self.exerciseDropDown)
            self.exercisesTextField.text = item
        }
        self.exerciseDropDown.cancelAction = { [unowned self] in
            //self.toggleWorkoutTypeIcon(field: self.exercisesTextField, dropdown: self.exerciseDropDown)
        }

        self.exerciseDropDown.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.exerciseDropDown.backgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.backgroundColor
        self.exerciseDropDown.selectionBackgroundColor = ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor
        self.exerciseDropDown.selectedTextColor = ApplicationScheme.instance.containerScheme.colorScheme.onSecondaryColor
        self.exerciseDropDown.direction = .bottom
        self.exerciseDropDown.bottomOffset = CGPoint(x: 0, y:(self.exerciseDropDown.anchorView?.plainView.bounds.height)! - 25)
 */
        self.exerciseDropDown.dataSource = ["test"]
        
        
        //////////
        firstly {
            Services.exercisePostService.getExerciseTypes()
        }.done { exerciseTypes in
            
            var arr = [String]()
            arr.append("hi")
            for et in exerciseTypes {                
                arr.append(et.value.rawValue)
            }
            self.workoutTypeDropDown.dataSource = arr
        }.catch { err in
            self.workoutTypeDropDown.dataSource = ["Strength", "Endurance", "Balance", "Flexibxility"]
        }
    }
    
    
    @objc func workoutTypeIconOnClick(textField: MDCTextField, dropdown: DropDown) {
        self.toggleWorkoutTypeIcon(field: textField, dropdown: dropdown)
    }
    /*
    @objc func workoutTypeIconOnClick(sender: Any) {
        self.toggleWorkoutTypeIcon()
    }
 --------*/
        
        
    
    func toggleWorkoutTypeIcon(field: MDCTextField, dropdown: DropDown) {
        if field.trailingView == Images.chevronDown {
            field.trailingView = Images.chevronUp
            dropdown.hide()
        }
        else {
            field.trailingView = Images.chevronDown
            dropdown.show()
        }
        field.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(workoutTypeIconOnClick(textField:dropdown:))))
        field.trailingViewMode = .always
        field.trailingView?.isUserInteractionEnabled = true
        field.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        field.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
  
    /*
    func toggleWorkoutTypeIcon() {
        if self.workoutTypeTextField.trailingView == Images.chevronDown {
            self.workoutTypeTextField.trailingView = Images.chevronUp
            self.workoutTypeDropDown.hide()
        }
        else {
            self.workoutTypeTextField.trailingView = Images.chevronDown
            self.workoutTypeDropDown.show()
        }
        //self.workoutTypeTextField.trailingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(workoutTypeIconOnClick(sender:))))
        self.workoutTypeTextField.trailingViewMode = .always
        self.workoutTypeTextField.trailingView?.isUserInteractionEnabled = true
        self.workoutTypeTextField.trailingView?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.workoutTypeTextField.trailingView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
 */
 
    func initTextViewPlaceholders() {
        subjectTextField.delegate = self
        self.view.addSubview(subjectTextField)
       
        bodyTextField.multilineDelegate = self
        self.bodyTextField.cursorColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.bodyTextField.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
               
        self.view.addSubview(bodyTextField)
        
    }
    
    func initActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        self.view.addSubview(activityIndicator)
    }
    
    func applyConstraints() {
        self.workoutTypeTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 75).isActive = true
        self.workoutTypeTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.workoutTypeTextField.trailingAnchor, constant: 15).isActive = true
        
        self.exercisesTextField.topAnchor.constraint(equalTo: self.workoutTypeTextField.bottomAnchor, constant: 15).isActive = true
        self.exercisesTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.exercisesTextField.trailingAnchor, constant: 15).isActive = true
        
        self.subjectTextField.topAnchor.constraint(equalTo: self.exercisesTextField.bottomAnchor, constant: 15).isActive = true
        self.subjectTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: subjectTextField.trailingAnchor, constant: 15).isActive = true
        
        self.bodyTextField.topAnchor.constraint(equalTo: self.subjectTextField.bottomAnchor, constant: 15).isActive = true
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
        keyboardMenuAccessory.addSubview(openCameraBtn)
        
        NSLayoutConstraint.activate([
            openKeyboardBtn.leadingAnchor.constraint(equalTo: keyboardMenuAccessory.leadingAnchor, constant: 20),
            openKeyboardBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor),
            openPhotoGalleryBtn.leadingAnchor.constraint(equalTo: openKeyboardBtn.trailingAnchor, constant: 20),
            openPhotoGalleryBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor),
            openCameraBtn.leadingAnchor.constraint(equalTo: openPhotoGalleryBtn.trailingAnchor, constant: 20),
            openCameraBtn.centerYAnchor.constraint(equalTo: keyboardMenuAccessory.centerYAnchor)
        ])
        bodyTextField.textView?.inputAccessoryView = keyboardMenuAccessory
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
        //TODO: Remove this validation and use validator.
        if(subjectTextField.text?.count ?? 0 <= 0
            ) {
            alert.message = "Please fill out a valid subject header"
            self.present(alert, animated: true, completion: nil)
            return false
        } else if (bodyTextField.text?.count ?? 0 <= 0) {
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
            "title" : subjectTextField.text!,
            "description" : bodyTextField.text!,
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
