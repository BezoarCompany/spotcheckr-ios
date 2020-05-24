import MaterialComponents
import PromiseKit

class CreateAnswerViewModel {
    init() { }
    // MARK: - Properties
    var currentUser: User?
    var post: ExercisePost?
    
    // MARK: - UI Elements
    let answerTextField: MDCMultilineTextField = {
        let field = MDCMultilineTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var answerTextInputController: MDCTextInputControllerOutlinedTextArea?
    let snackbarMessage: MDCSnackbarMessage = {
        let message = MDCSnackbarMessage()
        MDCSnackbarTypographyThemer.applyTypographyScheme(ApplicationScheme.instance.containerScheme.typographyScheme)
        return message
    }()
    let appBarViewController = UIElementFactory.getAppBar()
    
    // MARK: - Functions
    func createAnswer() -> Promise<Answer> {
        let answer = Answer(createdBy: currentUser,
                            dateCreated: Date(),
                            dateModified: Date(),
                            exercisePostId: post!.id,
                            text: answerTextField.text!.trim()
        )
        
        return Promise { promise in
            firstly {
                Services.exercisePostService.createAnswer(answer: answer)
            }.done {
                return promise.fulfill(answer)
            }
            .catch { error in
                LogManager.error("Error creating answer", error)
                return promise.reject(error)
            }
        }
    }
}
