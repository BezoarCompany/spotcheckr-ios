import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import MaterialComponents
import PromiseKit

class CreateAnswerViewController: UIViewController {
    let viewModel = CreateAnswerViewModel()
    
    static func create(post: ExercisePost?) -> CreateAnswerViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        // swiftlint:disable force_cast line_length
        let createAnswerViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreateAnswerViewControllerId) as! CreateAnswerViewController

        createAnswerViewController.viewModel.post = post
        return createAnswerViewController
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        viewModel.answerTextInputController = MDCTextInputControllerOutlinedTextArea()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChild(viewModel.appBarViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel.answerTextInputController = MDCTextInputControllerOutlinedTextArea(textInput: viewModel.answerTextField)
        let colorScheme = ApplicationScheme.instance.containerScheme.colorScheme
        MDCTextFieldTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme,
                                                           to: viewModel.answerTextInputController!)
        viewModel.answerTextInputController?.activeColor = colorScheme.onBackgroundColor
        viewModel.answerTextInputController?.normalColor = colorScheme.onBackgroundColor
        viewModel.answerTextInputController?.floatingPlaceholderNormalColor = colorScheme.onBackgroundColor
        viewModel.answerTextInputController?.floatingPlaceholderActiveColor = colorScheme.onBackgroundColor
        viewModel.answerTextInputController?.inlinePlaceholderColor = colorScheme.primaryColorVariant
        viewModel.answerTextInputController?.placeholderText = "Answer"
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initTextViewPlaceholders()
        initAppBar()
        applyConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        firstly {
            Services.userService.getCurrentUser()
        }.done { user in
            self.viewModel.currentUser = user
        }.catch { _ in
            self.dismiss(animated: true) {
                self.viewModel.snackbarMessage.text = "Unable to retrieve current user information."
                MDCSnackbarManager.show(self.viewModel.snackbarMessage)
            }
        }
    }
    
    @objc func cancelAnswer(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func submitAction(_ sender: Any) {
        firstly {
            viewModel.createAnswer()
        }.done { _ in
            self.dismiss(animated: true) {
                self.viewModel.snackbarMessage.text = "Answer posted!"
                MDCSnackbarManager.show(self.viewModel.snackbarMessage)
            }
        }.catch { _ in
            self.viewModel.snackbarMessage.text = "Error creating answer"
            MDCSnackbarManager.show(self.viewModel.snackbarMessage)
        }
    }
}

extension CreateAnswerViewController: MDCMultilineTextInputDelegate, MDCMultilineTextInputLayoutDelegate {
    func multilineTextField(_ multilineTextField: MDCMultilineTextInput, didChangeContentSize size: CGSize) {
        //swiftlint:disable line_length
        viewModel.appBarViewController.navigationBar.rightBarButtonItem?.isEnabled = multilineTextField.text?.trim().count ?? 0 > 0
    }
}

extension CreateAnswerViewController {
    func initTextViewPlaceholders() {
        let containerScheme = ApplicationScheme.instance.containerScheme
        
        viewModel.answerTextField.multilineDelegate = self
        viewModel.answerTextField.layoutDelegate = self
        viewModel.answerTextField.clearButtonMode = .never
        viewModel.answerTextField.cursorColor = containerScheme.colorScheme.onBackgroundColor
        viewModel.answerTextField.textColor = containerScheme.colorScheme.onBackgroundColor
        //TODO: Adjust height of the multi-line text input so that it goes to the top of the keyboard view at least.
        viewModel.answerTextField.becomeFirstResponder()
        view.addSubview(viewModel.answerTextField)
    }

    func initAppBar() {
        viewModel.appBarViewController.didMove(toParent: self)
        viewModel.appBarViewController.inferTopSafeAreaInsetFromViewController = true
        viewModel.appBarViewController.navigationBar.title = "Add Answer"
        viewModel.appBarViewController.navigationBar.leftBarButtonItem = UIBarButtonItem(image: Images.close,
                                                                               style: .done,
                                                                               target: self,
                                                                               action: #selector(self.cancelAnswer(_:)))
        viewModel.appBarViewController.navigationBar.rightBarButtonItem = UIBarButtonItem(image: Images.plus,
                                                                                style: .done,
                                                                                target: self,
                                                                                action: #selector(self.submitAction(_:)))
        viewModel.appBarViewController.navigationBar.rightBarButtonItem?.isEnabled = false
        view.addSubview(viewModel.appBarViewController.view)
    }

    func applyConstraints() {
        NSLayoutConstraint.activate([
            viewModel.answerTextField.topAnchor.constraint(equalTo: viewModel.appBarViewController.navigationBar.bottomAnchor,
                                                 constant: 16),
            viewModel.answerTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            viewModel.answerTextField.bottomAnchor.constraint(equalTo: viewModel.answerTextField.inputAccessoryView?.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: viewModel.answerTextField.trailingAnchor, constant: 10)
        ])
    }
}
