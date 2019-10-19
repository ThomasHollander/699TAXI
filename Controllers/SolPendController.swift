import UIKit
import MapKit
import SocketIO
class SolPendController: UIViewController, MKMapViewDelegate, UITextViewDelegate,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var SolicitudPendiente: CSolicitud!
    var posicionSolicitud: Int!
    var OrigenSolicitud = MKPointAnnotation()
    var TaxiSolicitud = MKPointAnnotation()
    var evaluacion: CEvaluacion!
    var grabando = false
    var fechahora: String!
    @IBOutlet weak var MapaSolPen: MKMapView!
    @IBOutlet weak var DetallesCarreraView: UIView!
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var MensajesBtn: UIButton!
    @IBOutlet weak var LlamarCondBtn: UIButton!
    @IBOutlet weak var SMSVozBtn: UIButton!
    @IBOutlet weak var DatosConductor: UIView!
    @IBOutlet weak var ImagenCond: UIImageView!
    @IBOutlet weak var NombreCond: UILabel!
    @IBOutlet weak var MovilCond: UILabel!
    @IBOutlet weak var MarcaAut: UILabel!
    @IBOutlet weak var ColorAut: UILabel!
    @IBOutlet weak var MatriculaAut: UILabel!
    @IBOutlet weak var AlertaEsperaView: UIView!
    @IBOutlet weak var MensajeEspera: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.MapaSolPen.delegate = self
        self.OrigenSolicitud.coordinate = self.SolicitudPendiente.origenCarrera
        self.OrigenSolicitud.title = "origen"
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SolPendController.longTap(_:)))
        longGesture.minimumPressDuration = 0.5
        self.SMSVozBtn.addGestureRecognizer(longGesture)
        myvariables.socket.on("Taxi"){data, ack in
            let datosConductor = String(describing: data).components(separatedBy: ",")
            self.NombreCond.text! = "Conductor: " + datosConductor[1]
            self.MarcaAut.text! = "Marca: " + datosConductor[5]
            self.ColorAut.text! = "Color: " + datosConductor[6]
            self.MatriculaAut.text! = "Matrícula: " + datosConductor[7]
            self.MovilCond.text! = "Movil: " + datosConductor[2]
            if datosConductor[8] != "null" && datosConductor[8] != ""{
                let url = URL(string:datosConductor[8])
                let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    DispatchQueue.main.sync() {
                        self.ImagenCond.image = UIImage(data: data)
                    }
                }
                task.resume()
            }else{
                self.ImagenCond.image = UIImage(named: "chofer")
            }
            self.AlertaEsperaView.isHidden = true
            self.DatosConductor.isHidden = false
        }
        myvariables.socket.on("V"){data, ack in
            self.MensajesBtn.isHidden = false
            self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControl.State())
        }
        myvariables.socket.on("Geo"){data, ack in
            let temporal = String(describing: data).components(separatedBy: ",")
            if myvariables.solpendientes.count != 0 {
                if (temporal[2] == self.SolicitudPendiente.idTaxi){
                    self.MapaSolPen.removeAnnotation(self.TaxiSolicitud)
                    self.SolicitudPendiente.taximarker = CLLocationCoordinate2DMake(Double(temporal[3])!, Double(temporal[4])!)
                    self.MostrarDetalleSolicitud()
                }
            }
        }
        if myvariables.urlconductor != ""{
            self.MensajesBtn.isHidden = false
            self.MensajesBtn.setImage(UIImage(named: "mensajesnew"),for: UIControl.State())
        }
        self.MostrarDetalleSolicitud()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var anotationView = MapaSolPen.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        anotationView = MKAnnotationView(annotation: self.OrigenSolicitud, reuseIdentifier: "annotationView")
        if annotation.title! == "origen"{
            anotationView?.image = UIImage(named: "origen")
        }else{
            anotationView?.image = UIImage(named: "taxi_libre")
        }
        return anotationView
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    @objc func longTap(_ sender : UILongPressGestureRecognizer){
      if sender.state == .ended {
        if !myvariables.SMSVoz.reproduciendo && myvariables.grabando{
            self.SMSVozBtn.setImage(UIImage(named: "smsvoz"), for: .normal)
                let dateFormato = DateFormatter()
                dateFormato.dateFormat = "yyMMddhhmmss"
                self.fechahora = dateFormato.string(from: Date())
                let name = self.SolicitudPendiente.idSolicitud + "-" + self.SolicitudPendiente.idTaxi + "-" + fechahora + ".m4a"
                myvariables.SMSVoz.TerminarMensaje(name)
                myvariables.SMSVoz.SubirAudio(myvariables.UrlSubirVoz, name: name)
                myvariables.grabando = false
        }
    }else if sender.state == .began {
        if !myvariables.SMSVoz.reproduciendo{
            self.SMSVozBtn.setImage(UIImage(named: "smsvozRec"), for: .normal)
                myvariables.SMSVoz.ReproducirMusica()
                myvariables.SMSVoz.GrabarMensaje()
                myvariables.grabando = true
            }
        }
    }
    func EnviarSocket(_ datos: String){
        if CConexionInternet.isConnectedToNetwork() == true{
            if myvariables.socket.status.active{
                myvariables.socket.emit("data",datos)
            }else{
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
    func ErrorConexion(){
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
           // exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
    }
    func MostrarDetalleSolicitud(){
        if self.SolicitudPendiente.idTaxi != "null" && self.SolicitudPendiente.idTaxi != ""{
            self.TaxiSolicitud.coordinate = self.SolicitudPendiente.taximarker
            self.MapaSolPen.fitAll(in: [self.OrigenSolicitud, self.TaxiSolicitud], andShow: true)
            let temporal = self.SolicitudPendiente.DistanciaTaxi()
            DistanciaText.text = temporal + " KM"
            DetallesCarreraView.isHidden = false
            self.SMSVozBtn.setImage(UIImage(named:"smsvoz"),for: UIControl.State())
        }else{
            self.MapaSolPen.addAnnotation(self.OrigenSolicitud)
        }
    }
    func MostrarMotivoCancelacion(){
        let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertController.Style.actionSheet)
        motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
                self.CancelarSolicitud("No necesito")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
           self.CancelarSolicitud("Demora el servicio")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
            self.CancelarSolicitud("Tarifa incorrecta")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
            self.CancelarSolicitud("Vehículo en mal estado")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
            self.CancelarSolicitud("Solo probaba el servicio")
        }))
        motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
        }))
        self.present(motivoAlerta, animated: true, completion: nil)
    }
    func CancelarSolicitud(_ motivo: String){
        let Datos = "#Cancelarsolicitud" + "," + self.SolicitudPendiente.idSolicitud + "," + self.SolicitudPendiente.idTaxi + "," + motivo + "," + "# \n"
        EnviarSocket(Datos)
        myvariables.solpendientes.remove(at: self.posicionSolicitud)
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
        self.navigationController?.show(vc, sender: nil)        
    }
    @IBAction func LLamarConductor(_ sender: AnyObject) {
        if let url = URL(string: "tel://\(self.SolicitudPendiente.movil)") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func ReproducirMensajesCond(_ sender: AnyObject) {
        if myvariables.urlconductor != ""{
            myvariables.SMSVoz.ReproducirVozConductor(myvariables.urlconductor)
        }
    }
    @IBAction func DatosConductor(_ sender: AnyObject) {
        if self.SolicitudPendiente.marcaVehiculo != ""{
            self.NombreCond.text! = "Conductor: " + self.SolicitudPendiente.nombreApellido
            self.MarcaAut.text! = "Marca: " + self.SolicitudPendiente.marcaVehiculo
            self.ColorAut.text! = "Color: " + self.SolicitudPendiente.colorVehiculo
            self.MatriculaAut.text! = "Matrícula: " + self.SolicitudPendiente.matricula
            self.MovilCond.text! = "Movil: " + self.SolicitudPendiente.movil
            if self.SolicitudPendiente.urlFoto != "null" && self.SolicitudPendiente.urlFoto != ""{
                let url = URL(string:self.SolicitudPendiente.urlFoto)
                let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.sync() {
                        self.ImagenCond.image = UIImage(data: data)
                    }
                }
                task.resume()
            }else{
                self.ImagenCond.image = UIImage(named: "chofer")
            }
            self.DatosConductor.isHidden = false
        }else{
            let datos = "#Taxi," + myvariables.cliente.idUsuario + "," + self.SolicitudPendiente.idTaxi + ",# \n"
            self.EnviarSocket(datos)
            MensajeEspera.text = "Procesando..."
            AlertaEsperaView.isHidden = false
        }
    }
    @IBAction func AceptarCond(_ sender: UIButton) {
        self.DatosConductor.isHidden = true        
    }
    @IBAction func NuevaSolicitud(_ sender: Any) {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
        self.navigationController?.show(vc, sender: nil)
    }
    @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
        MostrarMotivoCancelacion()
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
