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
