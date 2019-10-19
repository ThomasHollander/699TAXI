import UIKit
import SocketIO
class LoginController: UIViewController, UITextFieldDelegate{
    var login = [String]()
    var solitudespdtes = [CSolicitud]()
    var EnviosCount = 0
    var emitTimer = Timer()
    let manager = SocketManager(socketURL: URL(string: "http://173.249.14.230:6016")!, config: [.log(true), .forcePolling(true)])
    @IBOutlet weak var Usuario: UITextField!
    @IBOutlet weak var Clave: UITextField!
    @IBOutlet weak var AutenticandoView: UIView!
    @IBOutlet weak var ClaveRecover: UIView!
    @IBOutlet weak var movilClaveRecover: UITextField!
    @IBOutlet weak var RecuperarClaveBtn: UIButton!
    @IBOutlet weak var RegistroView: UIView!
    @IBOutlet weak var nombreApText: UITextField!
    @IBOutlet weak var nombreError: UILabel!
    @IBOutlet weak var claveText: UITextField!
    @IBOutlet weak var claveError: UILabel!
    @IBOutlet weak var confirmarClavText: UITextField!
    @IBOutlet weak var confirmarError: UILabel!
    @IBOutlet weak var correoText: UITextField!
    @IBOutlet weak var telefonoText: UITextField!
    @IBOutlet weak var telefonoError: UILabel!
    @IBOutlet weak var RegistroBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Usuario.delegate = self
        telefonoText.delegate = self
        claveText.delegate = self
        correoText.delegate = self
        self.movilClaveRecover.delegate = self
        confirmarClavText.delegate = self
        Clave.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
        self.RegistroView.addGestureRecognizer(tapGesture)
        self.ClaveRecover.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(tapGesture)
        if CConexionInternet.isConnectedToNetwork() == true{
            myvariables.socket = self.manager.defaultSocket
            myvariables.socket.connect()
            self.SocketEventos()
        }else{
            ErrorConexion()
        }
    }
    func SocketEventos(){
        myvariables.socket.on("connect"){data, ack in
            var read = "Vacio"
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            do {
                read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
            }catch {
            }
            if read != "Vacio"
            {
                self.AutenticandoView.isHidden = false
                self.Login()
            }
            else{
                self.AutenticandoView.isHidden = true
            }
        }
        myvariables.socket.on("LoginPassword"){data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            switch temporal[1]{
            case "loginok":
                myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email: temporal[3], empresa: temporal[temporal.count - 2])
                if temporal[6] != "0"{
                    self.ListSolicitudPendiente(temporal)
                }
                let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                self.navigationController?.setNavigationBarHidden(false, animated: false)
             //   DispatchQueue.main.sync {
                self.navigationController?.show(vc, sender: nil)
            //    }
            case "loginerror":
                let fileManager = FileManager()
                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
                do {
                    try fileManager.removeItem(atPath: filePath)
                }catch{
                }
                let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.AutenticandoView.isHidden = true
                }))
                self.present(alertaDos, animated: true, completion: nil)
            default: print("Problemas de conexion")
            }
        }
        myvariables.socket.on("Registro") {data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "registrook"{
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Registro Realizado con éxito, puede loguearse en la aplicación, ¿Desea ingresar a la Aplicación?", preferredStyle: .alert)
                alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                  //  exit(0)
                }))
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.RegistroView.isHidden = true
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
            else{
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Error al registrar el usuario: \(temporal[2])", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.AutenticandoView.isHidden = true
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
        myvariables.socket.on("Recuperarclave"){data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Recuperación de clave", message: "Su clave ha sido recuperada satisfactoriamente, en este momento ha recibido un correo electronico a la dirección: " + temporal[2], preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
    }
    func ListSolicitudPendiente(_ listado : [String]){
        var lattaxi = String()
        var longtaxi = String()
        var i = 7
        while i <= listado.count-10 {
            let solicitudpdte = CSolicitud()
            if listado[i+4] == "null"{
                lattaxi = "0"
                longtaxi = "0"
            }else{
                lattaxi = listado[i + 4]
                longtaxi = listado[i + 5]
            }
            solicitudpdte.idSolicitud = listado[i]
            solicitudpdte.DatosCliente(cliente: myvariables.cliente)
            solicitudpdte.DatosSolicitud(dirorigen: "", referenciaorigen: "", dirdestino: "", latorigen: listado[i + 6], lngorigen: listado[i + 7], latdestino: listado[i + 8], lngdestino: listado[i + 9],FechaHora: listado[i + 3])
            solicitudpdte.DatosTaxiConductor(idtaxi: listado[i + 1], matricula: "", codigovehiculo: listado[i + 2], marcaVehiculo: "", colorVehiculo: "", lattaxi: lattaxi, lngtaxi: longtaxi, idconductor: "", nombreapellidosconductor: "", movilconductor: listado[i + 10], foto: "")
            myvariables.solpendientes.append(solicitudpdte)
            if solicitudpdte.idTaxi != ""{
                myvariables.solicitudesproceso = true
            }
            i += 11
        }
    }
    func Login(){
        self.AutenticandoView.isHidden = false
        var readString = ""
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        do {
            readString = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
        }
        self.login = String(readString).components(separatedBy: ",")
        EnviarTimer(estado: 1, datos: readString)
    }
    func EnviarTimer(estado: Int, datos: String){
        if estado == 1{
            if !self.emitTimer.isValid{
                self.emitTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(EnviarSocket1(_:)), userInfo: ["datos": datos], repeats: true)
            }
        }else{
            self.emitTimer.invalidate()
            self.EnviosCount = 0
        }
    }
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.status.active{
                myvariables.socket.emit("data",datos)
                self.EnviarTimer(estado: 1, datos: datos)
            }
            else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                 //   exit(0)
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            self.ErrorConexion()
        }
    }
    @objc func EnviarSocket1(_ timer: Timer){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.status.active && self.EnviosCount <= 3 {
                self.EnviosCount += 1
                let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
                var datos: String = (userInfo["datos"] as! String)
                myvariables.socket.emit("data",datos)
            }else{
                let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                //    exit(0)
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }else{
            ErrorConexion()
        }
    }
    func ErrorConexion(){
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          //  exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
    }
    @IBAction func Autenticar(_ sender: AnyObject) {
        let writeString = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# \n"
        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
        do {
            _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
        }
        self.Login()
    }
    @IBAction func OlvideClave(_ sender: AnyObject) {
        ClaveRecover.isHidden = false
        self.Usuario.resignFirstResponder()
        self.Clave.resignFirstResponder()
    }
    @IBAction func RecuperarClave(_ sender: AnyObject) {
        let datos = "#Recuperarclave," + movilClaveRecover.text! + ",# \n"
        EnviarSocket(datos)
        ClaveRecover.isHidden = true
        movilClaveRecover.endEditing(true)
        movilClaveRecover.text?.removeAll()
    }
    @IBAction func CancelRecuperarclave(_ sender: AnyObject) {
        ClaveRecover.isHidden = true
        self.movilClaveRecover.endEditing(true)
        self.movilClaveRecover.text?.removeAll()
    }
    @IBAction func RegistrarCliente(_ sender: AnyObject) {
        self.Usuario.resignFirstResponder()
        self.Clave.resignFirstResponder()
        RegistroView.isHidden = false
    }
    @IBAction func EnviarRegistro(_ sender: AnyObject) {
        if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty || (confirmarClavText.text?.isEmpty)!) {
            let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Los campos subrayados en rojo en el formulario son requeridos. Debe llenarlos", preferredStyle: UIAlertController.Style.alert)
            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            }))
            self.present(alertaDos, animated: true, completion: nil)
        }
        else{
            if claveText.text == confirmarClavText.text{
                var temporal1 = "Sin correo" + ",# \n"
                if correoText.text != ""{
                    temporal1 = "\(correoText.text!),# \n"
                }
                let datos = "#Registro,\(nombreApText.text!),\(telefonoText.text!),\(telefonoText.text!),\(claveText.text!),\(temporal1)"
                myvariables.socket.emit("data", datos)
                RegistroView.isHidden = true
                claveText.endEditing(true)
                confirmarClavText.endEditing(true)
                correoText.endEditing(true)
            }else{
                confirmarClavText.endEditing(true)
            }
        }
    }
    @IBAction func CancelarRegistro(_ sender: AnyObject) {
        RegistroView.isHidden = true
        claveText.endEditing(true)
        confirmarClavText.endEditing(true)
        correoText.endEditing(true)
        nombreApText.text?.removeAll()
        telefonoText.text?.removeAll()
        claveText.text?.removeAll()
        confirmarClavText.text?.removeAll()
        correoText.text?.removeAll()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text?.removeAll()
        if textField.isEqual(claveText) || textField.isEqual(Clave) || textField.isEqual(self.Usuario){
            animateViewMoving(true, moveValue: 80, view: self.view)
        }
        else{
            if textField.isEqual(movilClaveRecover){
                textField.text?.removeAll()
                animateViewMoving(true, moveValue: 105, view: self.view)
            }
            else{
                if textField.isEqual(confirmarClavText) || textField.isEqual(correoText){
                    if textField.isEqual(confirmarClavText){
                        textField.textColor = UIColor.black
                        textField.isSecureTextEntry = true
                    }
                    animateViewMoving(true, moveValue: 155, view: self.view)
                }else{
                    if textField.isEqual(self.telefonoText){
                        textField.textColor = UIColor.black
                        animateViewMoving(true, moveValue: 70, view: self.view)
                    }
                }
            }
        }
    }
    func textFieldDidEndEditing(_ textfield: UITextField) {
        textfield.text = textfield.text!.replacingOccurrences(of: ",", with: ".")
        if textfield.isEqual(claveText) || textfield.isEqual(Clave) || textfield.isEqual(self.Usuario){
            animateViewMoving(false, moveValue: 80, view: self.view)
        }else{
            if textfield.isEqual(confirmarClavText) || textfield.isEqual(correoText){
                if textfield.text != claveText.text && textfield.isEqual(confirmarClavText){
                    textfield.textColor = UIColor.red
                    textfield.text = "Las claves no coinciden"
                    textfield.isSecureTextEntry = false
                    RegistroBtn.isEnabled = false
                }
                else{
                    RegistroBtn.isEnabled = true
                }
                animateViewMoving(false, moveValue: 155, view: self.view)
            }else{
                if textfield.isEqual(telefonoText){
                    animateViewMoving(false, moveValue: 70, view: self.view)
                }else{
                    if textfield.isEqual(movilClaveRecover){
                        if movilClaveRecover.text?.characters.count != 10{
                            textfield.text = "Número de Teléfono Incorrecto"
                        }else{
                            self.RecuperarClaveBtn.isEnabled = true
                        }
                        animateViewMoving(false, moveValue: 105, view: self.view)
                    }
                }
            }
        }
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField.isEqual(self.Clave){
            let writeString = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# \n"
            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
            do {
                _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
            }
            self.Login()
        }
        return true
    }
    @objc func ocultarTeclado(){
        self.ClaveRecover.endEditing(true)
        self.RegistroView.endEditing(true)
    }
}
