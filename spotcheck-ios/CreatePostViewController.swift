import UIKit

class CreatePostViewController: UIViewController {

    static func create() -> CreatePostViewController  {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let createPostViewController = storyboard.instantiateViewController(withIdentifier: K.Storyboard.CreatePostViewControllerId) as! CreatePostViewController
                    
        return createPostViewController

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CreatePostViewController")
        
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension CreatePostViewController {
    
}
