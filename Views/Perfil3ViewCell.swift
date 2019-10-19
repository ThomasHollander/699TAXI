import UIKit
class Perfil3ViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var NombreCampo: UILabel!
    @IBOutlet weak var ClaveActualText: UITextField!
    @IBOutlet weak var NuevaClaveText: UITextField!
    @IBOutlet weak var ConfirmeClaveText: UITextField!
    var vista = PerfilController()
    override func awakeFromNib() {
        super.awakeFromNib()
        NuevaClaveText.delegate = self
        ConfirmeClaveText.delegate = self
        self.ClaveActualText.delegate = self
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text?.removeAll()
        if textField.isEqual(self.ConfirmeClaveText) || textField.isEqual(self.NuevaClaveText) || textField.isEqual(self.ClaveActualText){
            textField.isSecureTextEntry = true
        }
    }
    func textFieldDidEndEditing(_ textfield: UITextField) {
        textfield.resignFirstResponder()
        if textfield.isEqual(self.ConfirmeClaveText){
            if self.NuevaClaveText != self.ConfirmeClaveText{
                textfield.textColor = UIColor.red
                textfield.text = "Las Claves Nuevas no coinciden"
                textfield.isSecureTextEntry = false
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
}
