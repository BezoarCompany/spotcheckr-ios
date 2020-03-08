import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import MaterialComponents
import MaterialComponents.MaterialTextFields_TypographyThemer
import MaterialComponents.MaterialSnackbar
import MaterialComponents.MaterialSnackbar_TypographyThemer
import PromiseKit

class CreateAnswerViewController: UIViewController, MDCMultilineTextInputDelegate, MDCMultilineTextInputLayoutDelegate {
    @IBOutlet weak var postButtonBarItem: UIBarButtonItem!
    let answerTextField: MDCMultilineTextField = {
        let field = MDCMultilineTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var answerTextInputController: MDCTextInputControllerOutlinedTextArea
    let snackbarMessage: MDCSnackbarMessage = {
       let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
       return message
    }()
    
    var currentUser: User?
    
    @IBAction func cancelAnswer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        firstly {
            createAnswer()
        }.done {
            self.dismiss(animated: true) {
                self.snackbarMessage.text = "Answer Posted!"
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.catch { error in
            self.snackbarMessage.text = "Error creating answer"
            MDCSnackbarManager.show(self.snackbarMessage)
        }
    }
    
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
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            self.currentUser = user
        }.catch { error in
            self.dismiss(animated: true) {
                self.snackbarMessage.text = "Unable to retrieve current user information."
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }
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
    
    func createAnswer() -> Promise<Void> {
        var answer = Answer(createdBy: self.currentUser,
                            dateCreated: Date(),
                            dateModified: Date(),
                            exercisePost: ExercisePost(id: self.post!.id),
                            text: self.answerTextField.text!
                            )
        
        return Promise { promise in
            firstly {
                Services.exercisePostService.writeAnswer(answer: answer)
            }.done {
                return promise.fulfill_()
            }
            .catch { error in
                return promise.reject(error)
            }
        }
    }
}
