import SwiftValidator
import MaterialComponents
import UIKit

extension CreatePostViewController: ValidationDelegate {
    func validationSuccessful() {
        appBarViewController.navigationBar.rightBarButtonItem?.isEnabled = false

        self.subjectTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)
        self.bodyTextFieldController.setErrorText(nil, errorAccessibilityValue: nil)

        if updatePostMode == .edit {
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
            } else if let field = field as? MDCIntrinsicHeightTextView {
                if field == self.bodyTextField.textView! {
                    self.bodyTextFieldController.setErrorText(error.errorMessage, errorAccessibilityValue: error.errorMessage)
                }
            }
        }

        appBarViewController.navigationBar.rightBarButtonItem?.customView = nil
    }

    func setupValidation() {
        validator.registerField(self.subjectTextField, rules: [RequiredRule(message: "Required")])
        validator.registerField(self.bodyTextField.textView!, rules: [RequiredRule(message: "Required")])
    }
}
