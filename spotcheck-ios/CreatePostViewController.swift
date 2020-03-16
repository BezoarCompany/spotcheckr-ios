import UIKit
import DropDown
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos
import PromiseKit
import MaterialComponents
import SwiftValidator
import SwiftSVG

enum DiffType {
    case add
    case edit
    case delete
}

class CreatePostViewController: UIViewController {
    let MAX_SUBJECT_LENGTH = 300
    
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBAction func submitPost(_ sender: Any) {
        self.postButton.customView = self.activityIndicator
        self.activityIndicator.startAnimating()
        self.validator.validate(self)
    }
            
    var photoImageView: UIImageView = {
        let piv = UIImageView()
        piv.image = UIImage(systemName: "photo")
        piv.translatesAutoresizingMaskIntoConstraints = false //You need to call this property so the image is added to your view
        return piv
    }()
        
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
        cameraImg = cameraImg?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(cameraImg, for: .normal)
        button.addTarget(self, action:
        #selector(keyboardBtnTapped), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        button.tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        return button
    }()
    
    
    let openPhotoGalleryBtn: UIButton! = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.red, for: .normal)
        var cameraImg = UIImage(systemName: "photo.on.rectangle")
        cameraImg = cameraImg?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(cameraImg, for: .normal)
        button.addTarget(self, action:
        #selector(openPhotoGallery), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        button.tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        return button
    }()
    
    let openCameraBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.red, for: .normal)
        var cameraImg = UIImage(systemName: "camera")
        cameraImg = cameraImg?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(cameraImg, for: .normal)
        button.addTarget(self, action:
        #selector(openCamera), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        button.tintColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        return button
    }()
    
    let exerciseDropdown: DropDown = {
        let dropdown = DropDown()
        return dropdown
    }()
    
    let exerciseTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Select Exercise"
        field.cursorColor = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let exerciseTextFieldController: MDCTextInputControllerFilled
    
    let subjectTextField: MDCTextField = {
        let field = MDCTextField()
        field.placeholder = "Title"
        field.keyboardType = .alphabet
        field.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let subjectTextFieldController: MDCTextInputControllerFilled
    
    let bodyTextField: MDCMultilineTextField = {
        let field = MDCMultilineTextField()
        field.placeholder = "Description"
        field.clearButtonMode = .never
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let bodyTextFieldController: MDCTextInputControllerOutlinedTextArea
    
    let snackbarMessage: MDCSnackbarMessage = {
       let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
        return message
    }()
    let cancelAlertController = MDCAlertController(title: "Cancel?", message: "You will lose all entered data.")
    
    let validator: Validator
    
    var activityIndicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.sizeToFit()
        indicator.indicatorMode = .indeterminate
        indicator.cycleColors = [ApplicationScheme.instance.containerScheme.colorScheme.secondaryColor]
        return indicator
    }()
    
    var imagePickerController = UIImagePickerController()
    var isImageChanged = false
    
    var updatePostMode: DiffType = .add
    var exercisePost: ExercisePost?
    var currentUser: User?
    var exercises = [Exercise]()
    var selectedExercise: Exercise?
        
    typealias CreatedPostDetailClosureType = ((_ post:ExercisePost) -> Void)
    typealias DiffedPostsDataUpdateClosureType = ((_ diffType: DiffType, _ post: ExercisePost) -> Void) //takes diff type, and post to be modified
    
    var createdPostDetailClosure: CreatedPostDetailClosureType? //From the Snackbar Action in FeedView, enter the Post Detail page with newly created Post (b/c Snackbar action created in CreatePost page)...Think React data flowing DOWN Stream
    
    var diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? //To dynamically update UITableView with the new post
    var updatePostDetailClosure: CreatedPostDetailClosureType? //To refresh Post Detail page
    
    static func create(updatePostMode: DiffType = .add, post: ExercisePost? = nil,
                       createdPostDetailClosure: CreatedPostDetailClosureType? = nil,
                       diffedPostsDataClosure: DiffedPostsDataUpdateClosureType? = nil,
                       updatePostDetailClosure: CreatedPostDetailClosureType? = nil) -> CreatePostViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createPostViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreatePostViewControllerId) as! CreatePostViewController
        
        createPostViewController.updatePostMode = updatePostMode
        createPostViewController.exercisePost = post
        createPostViewController.createdPostDetailClosure = createdPostDetailClosure
        createPostViewController.diffedPostsDataClosure = diffedPostsDataClosure
        createPostViewController.updatePostDetailClosure = updatePostDetailClosure
        
        return createPostViewController
    }

    required init?(coder aDecoder: NSCoder) {
        self.subjectTextFieldController = MDCTextInputControllerFilled(textInput: subjectTextField)
        self.subjectTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.subjectTextFieldController.characterCountViewMode = .always
        self.subjectTextFieldController.characterCountMax = UInt(MAX_SUBJECT_LENGTH)
        self.subjectTextFieldController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.subjectTextFieldController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.subjectTextFieldController.trailingUnderlineLabelTextColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        
        self.bodyTextFieldController = MDCTextInputControllerOutlinedTextArea(textInput: bodyTextField)
         MDCTextFieldTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme, to: self.bodyTextFieldController)
        self.bodyTextFieldController.errorColor = ApplicationScheme.instance.containerScheme.colorScheme.errorColor
        self.bodyTextFieldController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.bodyTextFieldController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.bodyTextFieldController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.bodyTextFieldController.inlinePlaceholderColor = ApplicationScheme.instance.containerScheme.colorScheme.primaryColorVariant
        
        self.exerciseTextFieldController = MDCTextInputControllerFilled(textInput: exerciseTextField)
        self.exerciseTextFieldController.applyTheme(withScheme: ApplicationScheme.instance.containerScheme)
        self.exerciseTextFieldController.isFloatingEnabled = false
        
        self.validator = Validator()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            self.currentUser = user
        }
        
        initDropDowns()
        initTextViewPlaceholders()
        
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPhotoGallery)))
        self.view.addSubview(photoImageView)
        
        applyConstraints()
        initButtonBarItems()
        addKeyboardMenuAccessory()
        setupValidation()
        
        if (updatePostMode == .edit) {
            subjectTextField.text = self.exercisePost?.title
            bodyTextField.text = self.exercisePost?.description
            navbar.title  = "Edit Question"
            postButton.title = "Save"
            
            if let img = exercisePost?.imagePath {
                print("image exists!")
                
                // Set default image for placeholder
                let placeholderImage = UIImage(named:"squat1")!
                
                // Get a reference to the storage service using the default Firebase App
                let storage = Storage.storage()
                let pathname = K.Firestore.Storage.IMAGES_ROOT_DIR + "/" + (exercisePost?.imagePath ?? "")
                
                // Create a reference with an initial file path and name
                let storagePathReference = storage.reference(withPath: pathname)
                
                // Load the image using SDWebImage
                
                photoImageView.sd_setImage(with: storagePathReference, placeholderImage: placeholderImage)
            }
        }
    }    
}

extension CreatePostViewController: MDCMultilineTextInputDelegate {
    //the description text view requires a delegate
}

extension CreatePostViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){

       let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
       
       isImageChanged = true
       photoImageView.image = chosenImage
       
       imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension CreatePostViewController: ValidationDelegate {
    func validationSuccessful() {
        self.postButton.isEnabled = false
        
        self.subjectTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        self.bodyTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        
        if(updatePostMode == .edit) {
            updatePostWorkflow(post: self.exercisePost)
        } else {
            submitPostWorkflow()
        }
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? MDCTextField {
                if field == self.subjectTextField {
                    self.subjectTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
            }
            else if let field = field as? MDCIntrinsicHeightTextView {
                if field == self.bodyTextField.textView! {
                    self.bodyTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
            }
        }

        self.postButton.customView = nil
    }
    
    private func setupValidation() {
        validator.registerField(self.subjectTextField, rules: [RequiredRule(message: "Required")])
        validator.registerField(self.bodyTextField.textView!, rules: [RequiredRule(message: "Required")])
    }
}

extension CreatePostViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField as? MDCTextField == self.exerciseTextField {
            if self.exerciseDropdown.isHidden {
                self.exerciseDropdown.show()
            } else {
                self.exerciseDropdown.hide()
            }
            self.toggleDropdownIcon()
            return false
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField as? MDCTextField == self.subjectTextField && self.subjectTextFieldController.errorText != nil {
            self.subjectTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField) { error in
            if textField as? MDCTextField == self.subjectTextField {
                self.bodyTextField.becomeFirstResponder()
                self.subjectTextFieldController.setErrorText(error?.errorMessage, errorAccessibilityValue: error?.errorMessage)
            }
        }
        
        return true
    }
}
