import UIKit
import iOSDropDown //https://github.com/jriosdev/iOSDropDown
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos

class CreatePostViewController: UIViewController {
    
    static let SUBJECT_TEXT_PLACEHOLDER = "Subject"
    static let POST_BODY_TEXT_PLACEHOLDER = "Write your question"
    static let MIN_SUBJECT_LENGTH = 10
    static let MIN_POSTBODY_LENGTH = 2

    @IBOutlet weak var workoutTypeDropDown: DropDown!
    @IBOutlet weak var subjectTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postBodyTextView: UITextView!
    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submitPost(_ sender: Any) {
        print("submitted")
        
        if(validatePost()) {
            createPost()
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    let keyboardMenuAccessory: UIView = {
        let accessoryView = UIView(frame: .zero)
        accessoryView.backgroundColor = .lightGray
        accessoryView.alpha = 0.6
        return accessoryView
    }()
    
    let openKeyboardBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.red, for: .normal)
        var cameraImg = UIImage(systemName: "keyboard")
        cameraImg = cameraImg?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        button.setImage(cameraImg, for: .normal)
        button.addTarget(self, action:
        #selector(keyboardBtnTapped), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    
    let openPhotoGalleryBtn: UIButton! = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.red, for: .normal)
        var cameraImg = UIImage(systemName: "photo.on.rectangle")
        cameraImg = cameraImg?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        button.setImage(cameraImg, for: .normal)
        button.addTarget(self, action:
        #selector(openPhotoGallery), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    let openCameraBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.red, for: .normal)
        var cameraImg = UIImage(systemName: "camera")
        cameraImg = cameraImg?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        button.setImage(cameraImg, for: .normal)
        button.addTarget(self, action:
        #selector(openCamera), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    var imagePickerController = UIImagePickerController()
    var isImageChanged = false
    
    static func create() -> CreatePostViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createPostViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreatePostViewControllerId) as! CreatePostViewController
                    
        return createPostViewController

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CreatePostViewController")
        
        initDropDown()
        initTextViewPlaceholders()
        photoImageView.isHidden = true //photo appears and to adjusted height once uploaded
        photoHeightConstraint.constant = 0
        addKeyboardMenuAccessory()
    }    
}

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

//Resetting textview's text to gray and placeholder value if empty,
//or back to black if non-empty (key press event triggered)
extension CreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == subjectTextView {
                textView.text = CreatePostViewController.SUBJECT_TEXT_PLACEHOLDER
            } else {
                textView.text = CreatePostViewController.POST_BODY_TEXT_PLACEHOLDER
            }
            textView.textColor = UIColor.lightGray
        }
    }
}

extension CreatePostViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
       
       print("info:")
       print(info)
               
       let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
       
       isImageChanged = true
       photoImageView.isHidden = false //photo appears and to adjusted height once uploaded
       photoHeightConstraint.constant = 200
       photoImageView.image = chosenImage
       
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}
