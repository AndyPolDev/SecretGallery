import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var centralView: UIView!
    
    var maxImageIndex = 0
    var imageArray = [Image]()
    var currentIndex = 0
    
    let leftImageView = UIImageView()
    let rightImageView = UIImageView()
    let timeInterval = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.registerForKeyboardNotifications()
        
        if let safeImageArray = UserDefaults.standard.value([Image].self, forKey: ImageManager.singleton.key) {
            imageArray = safeImageArray
            updateUI(index: currentIndex)
            
        } else {
            showAlert()
        }
        
        maxImageIndex = imageArray.count - 1
        print(imageArray.count)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainImage.layer.masksToBounds = true
        mainImage.contentMode = .scaleAspectFit
        likeView.layer.zPosition = 1
        imageContainerView.backgroundColor = .lightGray
        imageContainerView.cornerRadius(20)
        imageContainerView.dropShadow(20)
    }
    
    
    @IBAction func backScreenButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set(encodable: imageArray, forKey: ImageManager.singleton.key)
        navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        imageArray[currentIndex].isLike = !imageArray[currentIndex].isLike
        updateLike(index: currentIndex)
        
    }
    
    @IBAction func previousPhotoButtonPressed(_ sender: UIButton) {
        removeRightImageView()
        reduceIndex()
        createLeftImageView(index: currentIndex)
        moveLeftImageView(index: currentIndex)
        
    }
    
    @IBAction func nextPhotoButtonPressed(_ sender: UIButton) {
        removeLeftImageView()
        increaseIndex()
        createRightImageView(index: currentIndex)
        moveRightImageView(index: currentIndex)
        
    }
    
    @IBAction func centralButtonPressed(_ sender: UIButton) {
              
        let firstChangingImageViewFrame = CGRect(x: imageContainerView.frame.origin.x, y: imageContainerView.frame.origin.y + centralView.frame.origin.y , width: imageContainerView.frame.width, height: imageContainerView.frame.height)
        
        let secondChangingImageViewFrame = view.frame
        
        let changingImageView = UIImageView(frame: firstChangingImageViewFrame)
        changingImageView.backgroundColor = .lightGray
        changingImageView.contentMode = .scaleAspectFit
        
        if let imageString = imageArray[currentIndex].image {
            changingImageView.image = ImageManager.singleton.loadSave(fileName: imageString)
        } else {
            print("You don't have an image on array")
        }
        
        self.view.addSubview(changingImageView)
        
        imageContainerView.isHidden = true
        
            UIView.animate(withDuration: timeInterval) {
                changingImageView.frame = secondChangingImageViewFrame
            } completion: { (_) in
       
            }
        
    }
    
    
    
    func createLeftImageView(index: Int) {
        leftImageView.frame = CGRect(x: imageContainerView.frame.origin.x - imageContainerView.frame.width - leftConstraint.constant, y: 0, width: imageContainerView.frame.width, height: imageContainerView.frame.height)
        leftImageView.layer.masksToBounds = true
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.backgroundColor = .lightGray
        leftImageView.cornerRadius(20)
        
        if let imageString = imageArray[index].image {
            leftImageView.image = ImageManager.singleton.loadSave(fileName: imageString)
        } else {
            print("You don't have an image on array")
        }
        imageContainerView.addSubview(leftImageView)
    }
    
    func removeLeftImageView() {
        leftImageView.removeFromSuperview()
    }
    
    func createRightImageView(index: Int) {
        rightImageView.frame = CGRect(x: imageContainerView.frame.origin.x + imageContainerView.frame.width + rightConstraint.constant, y: 0, width: imageContainerView.frame.width, height: imageContainerView.frame.height)
        rightImageView.layer.masksToBounds = true
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.backgroundColor = .lightGray
        rightImageView.cornerRadius(20)
        if let imageString = imageArray[index].image {
            rightImageView.image = ImageManager.singleton.loadSave(fileName: imageString)
        } else {
            print("You don't have an image on array")
        }
        imageContainerView.addSubview(rightImageView)
    }
    
    func removeRightImageView() {
        rightImageView.removeFromSuperview()
    }
    
    func moveLeftImageView(index: Int) {
        likeImageView.isHidden = true
        updateLike(index: index)
        updateComment(index: index)
        UIView.animate(withDuration: timeInterval) {
            self.leftImageView.frame.origin.x = 0
        } completion: { (_) in
            self.updateImage(index: index)
            self.likeImageView.isHidden = false
        }
    }
    
    func moveRightImageView(index: Int) {
        likeImageView.isHidden = true
        updateLike(index: index)
        updateComment(index: index)
        UIView.animate(withDuration: timeInterval) {
            self.rightImageView.frame.origin.x = 0
        } completion: { (_) in
            self.updateImage(index: index)
            self.likeImageView.isHidden = false
        }
    }
    
    func reduceIndex() {
        if currentIndex == 0 {
            currentIndex = imageArray.count - 1
        } else {
            currentIndex -= 1
        }
    }
    
    func increaseIndex() {
        if currentIndex == imageArray.count - 1 {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Oops!", message: "Please select a photo", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SelectionViewController") as? SelectionViewController else {
                fatalError("Something is wrong with the SelectionViewController identification")
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            
            UIView.animate(withDuration: animationDuration) {
                self.view.frame.origin.y = 0
            }
        } else {
            UIView.animate(withDuration: animationDuration) {
                self.view.frame.origin.y = -keyboardScreenEndFrame.height
            }
        }
        //       view.needsUpdateConstraints()
        //        view.layoutIfNeeded()
    }
    
    func updateImage(index: Int) {
        if let imageString = imageArray[index].image {
            mainImage.image = ImageManager.singleton.loadSave(fileName: imageString)
        } else {
            print("You don't have an image on array")
        }
    }
    
    func updateLike(index: Int) {
        if imageArray[index].isLike {
            likeImageView.image = UIImage(named: "trueLike")
        } else {
            likeImageView.image = UIImage(named: "falseLike")
        }
    }
    
    func updateComment(index: Int) {
        textField.text = imageArray[index].comment
    }
    
    func updateUI(index: Int) {
        updateImage(index: index)
        updateLike(index: index)
        updateComment(index: index)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
}

extension ImageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let safeText = textField.text {
            imageArray[currentIndex].comment = safeText
        }
        
        return true
    }
}
