import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import MaterialComponents
import MaterialComponents.MaterialTextFields_TypographyThemer

class CreateAnswerViewController: UIViewController, MDCMultilineTextInputDelegate, MDCMultilineTextInputLayoutDelegate {
    @IBOutlet weak var postButtonBarItem: UIBarButtonItem!
    let answerTextField: MDCMultilineTextField = {
        let field = MDCMultilineTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var answerTextInputController: MDCTextInputControllerOutlinedTextArea
    
    @IBAction func cancelAnswer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        print("submitAction")
        if(validatePost()) {
            createAnswer()
            dismiss(animated: true, completion: nil)
        }
    }
    
    static let ANSWER_BODY_TEXT_PLACEHOLDER = "Write your answer"
    
    static func create(post: ExercisePost?) -> CreateAnswerViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createAnswerViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreateAnswerViewControllerId) as! CreateAnswerViewController
                    
        createAnswerViewController.post = post
        return createAnswerViewController
    }
    
    var post: ExercisePost?
    
    required init?(coder aDecoder: NSCoder) {
        self.answerTextInputController = MDCTextInputControllerOutlinedTextArea(textInput: self.answerTextField)
        MDCTextFieldTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme, to: self.answerTextInputController)
        self.answerTextInputController.activeColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.answerTextInputController.normalColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.answerTextInputController.floatingPlaceholderNormalColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.answerTextInputController.floatingPlaceholderActiveColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.answerTextInputController.placeholderText = "Answer"
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTextViewPlaceholders()
    }
}

extension CreateAnswerViewController {
    func initTextViewPlaceholders() {
        self.answerTextField.multilineDelegate = self
        self.answerTextField.layoutDelegate = self
        self.answerTextField.clearButtonMode = .never
        self.answerTextField.cursorColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        self.answerTextField.textColor = ApplicationScheme.instance.containerScheme.colorScheme.onBackgroundColor
        //TODO: Adjust height of the multi-line text input so that it goes to the top of the keyboard view at least.
        self.answerTextField.becomeFirstResponder()
        self.view.addSubview(answerTextField)
        self.answerTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 65).isActive = true
        self.answerTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        self.answerTextField.bottomAnchor.constraint(equalTo: self.answerTextField.inputAccessoryView?.topAnchor ?? self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: self.answerTextField.trailingAnchor, constant: 10).isActive = true
        
    }
    
    func multilineTextField(_ multilineTextField: MDCMultilineTextInput, didChangeContentSize size: CGSize) {
        self.postButtonBarItem.isEnabled = multilineTextField.text?.count ?? 0 > 0
    }
    
    func validatePost() -> Bool {
        if (self.answerTextField.text?.count ?? 0 > 0) {
            return false
        }
        
        return true
    }
    
    // TODO: put in PostService
    func createAnswer() {
        
        let db = Firestore.firestore()
        let newDocRef = db.collection(K.Firestore.answers).document()
        
        newDocRef.setData([
            "created-by" : Auth.auth().currentUser?.uid,
            "created-date" : FieldValue.serverTimestamp(),
            "text" : self.answerTextField.text!,
            "exercise-post" : post?.id,
            "modified-date" : FieldValue.serverTimestamp()
        ])
        
    }
}
