import UIKit
class CallCenterViewCell: UITableViewCell {
    @IBOutlet weak var ImagenOperadora: UIImageView!
    @IBOutlet weak var NumeroTelefono: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
