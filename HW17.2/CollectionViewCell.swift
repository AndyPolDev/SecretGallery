import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with imageString: String) {
        imageView.image = ImageManager.singleton.loadSave(fileName: imageString)
    }
}
