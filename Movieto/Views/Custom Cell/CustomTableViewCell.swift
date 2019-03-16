import UIKit

class CustomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var overViewLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
}
