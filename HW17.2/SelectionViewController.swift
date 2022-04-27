import UIKit

class SelectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    
    var imageArray = [Image]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        if let safeImageArray = UserDefaults.standard.value([Image].self, forKey: ImageManager.singleton.key) {
            imageArray = safeImageArray
        } else {
            print("imageArray is nil")
        }
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        performImagePicker()
        
    }
    
    @IBAction func nextScreenButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else {
            fatalError("Something is wrong with the ImageViewController identification")
        }
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    private func performImagePicker() {
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
}


//MARK: - extensions
extension UserDefaults {
    
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}

extension SelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var chosenImage = UIImage()
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            chosenImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chosenImage = image
        }
        
        let imageString = ImageManager.singleton.saveImage(image: chosenImage)
        let image = Image(image: imageString, isLike: false, comment: "")
        imageArray.append(image)
        collectionView.reloadData()
        
        UserDefaults.standard.set(encodable: imageArray, forKey: ImageManager.singleton.key)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension SelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageArray.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let imageString = imageArray[indexPath.item].image {
            cell.configure(with: imageString)
        } else {
            print("You don't have an image on array")
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else {
            fatalError("Something is wrong with the ImageViewController identification")
        }
        controller.currentIndex = indexPath.item
        
        navigationController?.pushViewController(controller, animated: true)
        
        
    }
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.frame.size.width / 2 - 5
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

