import UIKit
import SocketIO
class PerfilController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    var userperfil : CCliente!
    var NuevoTelefonoText: String = ""
    var NuevoEmailText: String = ""
    var ClaveActual: String = ""
    var NuevaClaveText: String = ""
    var ConfirmeClaveText: String = ""
    var login = [String]()
    var perfil2 : UITextField!
    @IBOutlet weak var NombreApellidoText: UILabel!
    @IBOutlet weak var PerfilTable: UITableView!
    @IBOutlet weak var ActualizarBtn: UIButton!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
            var readString = ""
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            do {
                readString = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            } catch {
            }
            self.login = String(readString).components(separatedBy: ",")
            self.ClaveActual = login[2]
        self.NombreApellidoText.text = myvariables.cliente.nombreApellidos
        myvariables.socket.on("UpdateUser"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Perfil Actualizado", message: "Su perfil se actualizo con ÉXITO. Los cambios se verán reflejados una vez que vuelva ingresar a la aplicación.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                    self.navigationController?.show(vc, sender: nil)
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }else{
                    let alertaDos = UIAlertController (title: "Error de Perfil", message: "Se produjo un ERROR al actualizar su perfil. Sus datos continuan sin cambios.", preferredStyle: UIAlertController.Style.alert)
                    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    }))
                    self.present(alertaDos, animated: true, completion: nil)
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.status.active{
                myvariables.socket.emit("data",datos)
            }
            else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
               //     exit(0)
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            self.ErrorConexion()
        }
    }
    func ErrorConexion(){
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
         //   exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
    }
    func EnviarActualizacion() {
        if self.NuevoTelefonoText == "" && self.NuevoEmailText == "" && self.NuevaClaveText == "" && self.ConfirmeClaveText == ""{
            let alertaDos = UIAlertController (title: "Mensaje Error", message: "Está tratando en enviar un formulario vacío. Por favor introduzca los valores que desea actualizar.", preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            }))
            self.present(alertaDos, animated: true, completion: nil)
        }else{
        let datos = "#UpdateUser,\(myvariables.cliente.idUsuario),\(myvariables.cliente.user),\(self.NuevoTelefonoText), \(myvariables.cliente.email),\(self.NuevoEmailText),\(self.ClaveActual),\(self.NuevaClaveText),# \n"
        EnviarSocket(datos)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            cell = Bundle.main.loadNibNamed("PerfilViewCell", owner: self, options: nil)?.first as! PerfilViewCell
            (cell as! PerfilViewCell).ValorActual.text = myvariables.cliente.user
            (cell as! PerfilViewCell).NuevoValor.delegate = self
        case 1:
            cell = Bundle.main.loadNibNamed("Perfil2ViewCell", owner: self, options: nil)?.first as! Perfil2ViewCell
            (cell as! Perfil2ViewCell).ValorActual.text = myvariables.cliente.email
            (cell as! Perfil2ViewCell).NuevoValor.delegate = self
        case 2:
            cell = Bundle.main.loadNibNamed("Perfil3ViewCell", owner: self, options: nil)?.first as! Perfil3ViewCell
            (cell as! Perfil3ViewCell).ClaveActualText.text = self.ClaveActual
            (cell as! Perfil3ViewCell).NuevaClaveText.delegate = self
            (cell as! Perfil3ViewCell).ConfirmeClaveText.delegate = self
        default:
            cell = Bundle.main.loadNibNamed("PerfilViewCell", owner: self, options: nil)?.first as! PerfilViewCell
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            (tableView.cellForRow(at: indexPath) as! PerfilViewCell).ValorActual.isHidden = !(tableView.cellForRow(at: indexPath) as! PerfilViewCell).ValorActual.isHidden
            (tableView.cellForRow(at: indexPath) as! PerfilViewCell).NuevoValor.isHidden = !(tableView.cellForRow(at: indexPath) as! PerfilViewCell).NuevoValor.isHidden
            tableView.cellForRow(at: indexPath)?.isSelected = false
        case 1:
            (tableView.cellForRow(at: indexPath) as! Perfil2ViewCell).ValorActual.isHidden = !(tableView.cellForRow(at: indexPath) as! Perfil2ViewCell).ValorActual.isHidden
            (tableView.cellForRow(at: indexPath) as! Perfil2ViewCell).NuevoValor.isHidden = !(tableView.cellForRow(at: indexPath) as! Perfil2ViewCell).NuevoValor.isHidden
            tableView.cellForRow(at: indexPath)?.isSelected = false
        case 2:
            (tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).ClaveActualText.isHidden = !(tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).ClaveActualText.isHidden
            (tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).NuevaClaveText.isHidden = !(tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).NuevaClaveText.isHidden
            (tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).ConfirmeClaveText.isHidden = !(tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).ConfirmeClaveText.isHidden
            (tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).NuevaClaveText.text?.removeAll()
            (tableView.cellForRow(at: indexPath) as! Perfil3ViewCell).ConfirmeClaveText.text?.removeAll()
            tableView.cellForRow(at: indexPath)?.isSelected = false
        default:
            (tableView.cellForRow(at: indexPath) as! PerfilViewCell).ValorActual.isHidden = true
            (tableView.cellForRow(at: indexPath) as! PerfilViewCell).NuevoValor.isHidden = false
            tableView.cellForRow(at: indexPath)?.isSelected = false
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2{
            return 140
        }else{
            return 85
        }
    }
    @IBAction func ActualizarPerfil(_ sender: Any) {
       if self.ConfirmeClaveText != "Las Claves Nuevas no coinciden"{
       self.view.endEditing(true)
       self.EnviarActualizacion()
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.restorationIdentifier != "NuevoTelefono" && textField.restorationIdentifier != "NuevoCorreo"{
        animateViewMoving(true, moveValue: 180, view: self.view)
        textField.textColor = UIColor.black
        textField.text?.removeAll()
        }
    }
    func textFieldDidEndEditing(_ textfield: UITextField) {
        if !(textfield.text?.isEmpty)!{
            switch textfield.restorationIdentifier! {
            case "NuevoTelefono":
                self.NuevoTelefonoText = textfield.text!
            case "NuevoCorreo":
                self.NuevoEmailText = textfield.text!
            case "ClaveActual":
                self.ClaveActual = textfield.text!
            case "NuevaClave":
                self.NuevaClaveText = textfield.text!
            case "ConfirmeClave":
                if self.NuevaClaveText != textfield.text{
                    textfield.textColor = UIColor.red
                    textfield.text = "Las Claves Nuevas no coinciden"
                    self.ConfirmeClaveText = "Las Claves Nuevas no coinciden"
                    textfield.isSecureTextEntry = false
                }else{
                textfield.isSecureTextEntry = true
                self.ConfirmeClaveText = textfield.text!
                }
            default:
                self.ConfirmeClaveText = textfield.text!
            }
        }
        textfield.resignFirstResponder()
        if textfield.restorationIdentifier != "NuevoTelefono" && textfield.restorationIdentifier != "NuevoCorreo"{
            animateViewMoving(false, moveValue: 180, view: self.view)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField.restorationIdentifier == "ConfirmeClave"{
            if self.ConfirmeClaveText != "Las Claves Nuevas no coinciden"{
            self.EnviarActualizacion()
            }
        }
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
    func keyboardNotification(notification: NSNotification){
        if let userInfo = notification.userInfo{
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                animateViewMoving(false, moveValue: 180, view: self.view)
            } else {
                animateViewMoving(true, moveValue: 180, view: self.view)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
