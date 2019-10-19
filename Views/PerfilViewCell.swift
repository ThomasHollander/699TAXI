import UIKit
class PerfilViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var NombreCampo: UILabel!
    @IBOutlet weak var ValorActual: UILabel!
    @IBOutlet weak var NuevoValor: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.NuevoValor.delegate = self
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
