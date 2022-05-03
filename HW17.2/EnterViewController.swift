import UIKit

class EnterViewController: UIViewController {
    
    //MARK: - outlets
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var firstPointsLine: UIStackView!
    @IBOutlet weak var secondPointsLine: UIStackView!
    
    @IBOutlet weak var firstPointFirstLine: UIView!
    @IBOutlet weak var secondPointFirstLine: UIView!
    @IBOutlet weak var thirdPointFirstLine: UIView!
    @IBOutlet weak var fourthPointFirstLine: UIView!
    
    @IBOutlet weak var firstPointSecondLine: UIView!
    @IBOutlet weak var secondPointSecondLine: UIView!
    @IBOutlet weak var thirdPointSecondLine: UIView!
    @IBOutlet weak var fourthPointSecondLine: UIView!
    
    //MARK: - let
    
    let passwordKey = "50CBBFAD"
    
    //MARK: - var
    
    var firstPassword = ""
    var secondPassword = ""
    var isPasswordEntryAllowed = true
    
    var firstLinePointsArray = [UIView]()
    var secondLinePointsArray = [UIView]()
    
    var password: Int = 0
    
    //MARK: - lifecycle funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstLinePointsArray = [firstPointFirstLine, secondPointFirstLine, thirdPointFirstLine, fourthPointFirstLine]
        secondLinePointsArray = [firstPointSecondLine, secondPointSecondLine, thirdPointSecondLine, fourthPointSecondLine]
        
        //Test key
        //let key = "df"
        
        if let receivedData = KeyChain.load(key: passwordKey) {
            firstPointsLine.isHidden = false
            secondPointsLine.isHidden = true
            password = receivedData.to(type: Int.self)
            print("password: ", password)
        } else {
            firstPointsLine.isHidden = false
            secondPointsLine.isHidden = false
            label.text = "Please enter new password"
            print("There is no data with the current key")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let radius = firstPointFirstLine.frame.width / 2
        
        firstLinePointsArray.forEach({$0.cornerRadius(radius)})
        firstLinePointsArray.forEach({$0.dropShadow(radius)})
        firstLinePointsArray.forEach({$0.backgroundColor = .white})
        
        if !secondPointsLine.isHidden {
            
            secondLinePointsArray.forEach({$0.cornerRadius(radius)})
            secondLinePointsArray.forEach({$0.dropShadow(radius)})
            secondLinePointsArray.forEach({$0.backgroundColor = .white})
            
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if isPasswordEntryAllowed {
            if secondPointsLine.isHidden == false {
                if firstPassword.count == 4 {
                    if secondPassword.count < 4  {
                        secondPassword = createPassword(sender: sender, pointsArray: secondLinePointsArray, password: secondPassword)
                    }
                } else {
                    firstPassword = createPassword(sender: sender, pointsArray: firstLinePointsArray, password: firstPassword)
                }
                
                if firstPassword.count == 4, secondPassword.count == 4 {
                    isPasswordEntryAllowed = false
                    print("firstPassword is: ", firstPassword)
                    print("secondPassword is: ", secondPassword)
                    if firstPassword == secondPassword {
                        
                        if let password: Int = Int(firstPassword) {
                            let data = Data(from: password)
                            let status = KeyChain.save(key: passwordKey, data: data)
                            print("status: ", status)
                            print("key: ", passwordKey)
                        } else {
                            fatalError("You have a problem with firstPassword!")
                        }
                        
                        firstLinePointsArray.forEach({$0.backgroundColor = .white})
                        secondLinePointsArray.forEach({$0.backgroundColor = .white})
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                            self.animatePoint(pointArray: self.firstLinePointsArray, color: .green)
                            self.animatePoint(pointArray: self.secondLinePointsArray, color: .green)
                        }
                        print("Great!")
                        moveToNextController()
                        
                    } else {
                        firstPassword = ""
                        secondPassword = ""
                        animatePoint(pointArray: firstLinePointsArray, color: .red)
                        animatePoint(pointArray: secondLinePointsArray, color: .red)
                        
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                            self.firstLinePointsArray.forEach({$0.backgroundColor = .white})
                            self.secondLinePointsArray.forEach({$0.backgroundColor = .white})
                            self.isPasswordEntryAllowed = true
                        }
                    }
                }
            } else if secondPointsLine.isHidden == true {
                firstPassword = createPassword(sender: sender, pointsArray: firstLinePointsArray, password: firstPassword)
                let stringPassword = String(password)
                if firstPassword.count == 4, stringPassword.count == 4 {
                    isPasswordEntryAllowed = false
                    if firstPassword == stringPassword {
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
                            self.firstLinePointsArray.forEach({$0.backgroundColor = .white})
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                                self.animatePoint(pointArray: self.firstLinePointsArray, color: .green)
                            }
                            self.moveToNextController()
                        }
                    } else {
                        firstPassword = ""
                        animatePoint(pointArray: firstLinePointsArray, color: .red)
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                            self.firstLinePointsArray.forEach({$0.backgroundColor = .white})
                            self.isPasswordEntryAllowed = true
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - flow funcs
    
    func moveToNextController() {
        
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SelectionViewController") as? SelectionViewController else {
                fatalError("Something is wrong with the SelectionViewController identification")
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func animatePoint(pointArray: [UIView], color: UIColor) {
        var pointIndex = 0.0
        
        for point in pointArray {
            Timer.scheduledTimer(withTimeInterval: 0.05 * pointIndex, repeats: false) { (timer) in
                point.backgroundColor = color
            }
            pointIndex += 1
        }
    }
    
    
    func createPassword(sender: UIButton, pointsArray: [UIView], password: String) -> String {
        var count = Int()
        if password.count == 0 {
            count = 0
        } else {
            count = password.count
        }
        
        let currentPassword = password
        guard let numValue = sender.currentTitle else {
            fatalError("You have a problem with buttonTitle")
        }
        
        if password.count < 4 {
            pointsArray[count].backgroundColor = .green
            return currentPassword + numValue
        } else {
            return password
        }
    }
}

//MARK: - extensions

extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}

extension UIView {
    
    func cornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func dropShadow(_ radius: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 3
        let shadowPath = CGMutablePath()
        shadowPath.addRoundedRect(in: bounds, cornerWidth: radius, cornerHeight: radius, transform: .identity)
        layer.shadowPath = shadowPath
        layer.shouldRasterize = true
        
    }
}
