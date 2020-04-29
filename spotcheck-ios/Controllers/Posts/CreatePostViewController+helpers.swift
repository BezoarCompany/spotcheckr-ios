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
        self.exerciseDropdown.bottomOffset = CGPoint(x: 0, y: (self.exerciseDropdown.anchorView?.plainView.bounds.height)! - 25)
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
        } else {
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
        let yesAction = MDCAlertAction(title: "Yes", emphasis: .high) { (_) in
            self.dismiss(animated: true)
        }
        let noAction = MDCAlertAction(title: "No", emphasis: .high)

        self.cancelAlertController.addAction(yesAction)
        self.cancelAlertController.addAction(noAction)
        self.cancelAlertController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        appBarViewController.navigationBar.leftBarButtonItem?.action = #selector(cancelButtonOnClick(sender:))
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

    func applyConstraints() {
        self.exerciseTextField.topAnchor.constraint(equalTo: self.appBarViewController.navigationBar.bottomAnchor, constant: 16).isActive = true
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

    @objc func keyboardBtnTapped() {
         self.bodyTextField.textView!.resignFirstResponder()
    }

    //for modifying an existing post
    func updatePostWorkflow(post: ExercisePost?) {
        guard let post = post
            else {
            print("@updatePostWorkflow -> invalid post args")
            return
        }
        self.activityIndicator.startAnimating()

        let copyPost = post
        copyPost.dateModified = Date()
        copyPost.title = subjectTextField.text!
        copyPost.description = bodyTextField.text!

        //queue up parallel execution of storage delete old image, storage-upload-new image, and firestore-update post
        var voidPromises = [Promise<Void>]()

        if isMediaChanged {
            let newImageName = "\(NSUUID().uuidString)" + ".jpeg"
            copyPost.imagePath = newImageName
            let jpegData = photoImageView.image!.jpegData(compressionQuality: 1.0)

            voidPromises.append(Services.storageService.uploadImage(filename: newImageName, imagetype: .jpeg, data: jpegData))

            //post had previous image, so create promise to delete that
            if let imagefilename = post.imagePath {
                voidPromises.append(Services.storageService.deleteImage(filename: imagefilename))
            }
        }

        //queue up firestore write call
        voidPromises.append(Services.exercisePostService.updatePost(post: copyPost))

        firstly {
            //execute all promises in parallel!
            when(fulfilled: voidPromises )
        }.done { _ in
            print("success updating Post")

            let postMap: [String: ExercisePost] = ["post": copyPost]
            //will update the Feed View's UI via Notification center
            NotificationCenter.default.post(name: K.Notifications.ExercisePostEdits, object: nil, userInfo: postMap )

            //refresh Post Details UI
            if let updatePostDetailView = self.updatePostDetailClosure {
                updatePostDetailView(copyPost)
            }
            self.dismiss(animated: true) {
                print("updatePostWorkflow: inside dismssed")
                self.snackbarMessage.text = "Post Updated."
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.catch { err in
            print("## error executing updatePostWorflow promises!")
            print(err)
            //TODO: Error updating post from no image to new image
        }.finally {
            self.activityIndicator.stopAnimating()
        }
    }

    func submitPostWorkflow() {
        //queue up parallel execution of storage delete old image, storage-upload-new image, and firestore-update post
        var exercises = [Exercise]()
        if self.selectedExercise != nil {
            // TODO: till we have tagging system
            print("selected-exercise: \(self.selectedExercise)")
//            exercises.append(self.selectedExercise!)
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

        var uploadVideoPromise: Promise<Void> =  Promise<Void> {promise in
            return promise.fulfill_()
        }

        if isMediaChanged {
            let baseName = NSUUID().uuidString
            let newImageName = "\(baseName)" + ".jpeg"
            exercisePost.imagePath = newImageName

            let jpegData = photoImageView.image!.jpegData(compressionQuality: 1.0)
            uploadImagePromise = Services.storageService.uploadImage(filename: newImageName, imagetype: .jpeg, data: jpegData)

            if let  selectedVideoFileURL = selectedVideoFileURL {
                let newVideoName = "\(baseName)" + ".mov"
                exercisePost.videoPath = newVideoName
                uploadVideoPromise = Services.storageService.uploadVideo(filename: newVideoName, videotype: .mov, url: selectedVideoFileURL)
            }
        }

        firstly {
            when(fulfilled: uploadImagePromise, Services.exercisePostService.createPost(post: exercisePost), uploadVideoPromise)

        }.done { _, newPost, _ in

            print("success creating post")
            if let updateTableView = self.diffedPostsDataClosure {
                updateTableView(.add, newPost)
            }
            self.dismiss(animated: true) {
                self.snackbarMessage.text = "Post created."
                let action = MDCSnackbarMessageAction()
                action.handler = {() in
                    self.createdPostDetailClosure!(newPost)
                }
                action.title = "View Post"
                self.snackbarMessage.action = action
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.catch { err in
            //TODO: Show snackbar error message.
            print(err)
        }.finally {
            self.activityIndicator.stopAnimating()
        }
    }
}
