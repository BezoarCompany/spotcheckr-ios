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
    typealias CreateAnswerClosureType = ((_ post:Answer) -> Void)
    
    var createAnswerClosure: CreateAnswerClosureType?
    
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
    let appBarViewController = UIElementFactory.getAppBar()
    var currentUser: User?
    var post: ExercisePost?
    
    @objc func cancelAnswer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func submitAction(_ sender: Any) {
        firstly {
            createAnswer()
        }.done { ans in
            self.dismiss(animated: true) {
                if let createAnswerClosure = self.createAnswerClosure {
                    createAnswerClosure(ans)
                }
                self.snackbarMessage.text = "Answer Posted!"
                MDCSnackbarManager.show(self.snackbarMessage)
            }
        }.catch { error in
            self.snackbarMessage.text = "Error creating answer"
            MDCSnackbarManager.show(self.snackbarMessage)
        }
    }
    
    static func create(post: ExercisePost?, createAnswerClosure: CreateAnswerClosureType? = nil) -> CreateAnswerViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createAnswerViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreateAnswerViewControllerId) as! CreateAnswerViewController
                    
        createAnswerViewController.post = post
        createAnswerViewController.createAnswerClosure = createAnswerClosure
        return createAnswerViewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        answerTextInputController = MDCTextInputControllerOutlinedTextArea()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)        
        self.addChild(appBarViewController)
    }
    
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
        initAppBar()
        applyConstraints()
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
    }
    
    func multilineTextField(_ multilineTextField: MDCMultilineTextInput, didChangeContentSize size: CGSize) {
        appBarViewController.navigationBar.rightBarButtonItem?.isEnabled = multilineTextField.text?.count ?? 0 > 0
    }
    
    func createAnswer() -> Promise<Answer> {
        let answer = Answer(createdBy: self.currentUser,
                            dateCreated: Date(),
                            dateModified: Date(),
                            exercisePostId: self.post!.id,
                            text: self.answerTextField.text!
                            )
        
        return Promise { promise in
            firstly {
                Services.exercisePostService.createAnswer(answer: answer)
            }.done {
                return promise.fulfill(answer)
            }
            .catch { error in
                return promise.reject(error)
            }
        }
    }
    
    func initAppBar() {
        appBarViewController.didMove(toParent: self)
        appBarViewController.inferTopSafeAreaInsetFromViewController = true
        appBarViewController.navigationBar.title = "Add Answer"
        appBarViewController.navigationBar.leftBarButtonItem = UIBarButtonItem(image: Images.close, style: .done, target: self, action: #selector(self.cancelAnswer(_:)))
        appBarViewController.navigationBar.rightBarButtonItem = UIBarButtonItem(image: Images.plus, style: .done, target: self, action: #selector(self.submitAction(_:)))
        appBarViewController.navigationBar.rightBarButtonItem?.isEnabled = false
        view.addSubview(appBarViewController.view)
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            answerTextField.topAnchor.constraint(equalTo: appBarViewController.navigationBar.bottomAnchor, constant: 16),
            answerTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            answerTextField.bottomAnchor.constraint(equalTo: answerTextField.inputAccessoryView?.topAnchor ?? self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: answerTextField.trailingAnchor, constant: 10),
        ])
    }
}
