import UIKit

class CustomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var nameAndDateLabel: UILabel!
    

}
