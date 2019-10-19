import UIKit
class TarifarioController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, GMSMapViewDelegate {
    var coreLocationManager : CLLocationManager!
    var OrigenTarifario = GMSMarker()
    var DestinoTarifario = GMSMarker()
    var tarifario = CTarifario()
    var tarifas = [CTarifa]()
    @IBOutlet weak var origenIcono: UIImageView!
    @IBOutlet weak var ExplicacionView: UIView!
    @IBOutlet weak var ExplicacionText: UILabel!
    @IBOutlet weak var MapaTarifario: GMSMapView!
    @IBOutlet weak var DestinoTarifarioBtn: UIButton!
    @IBOutlet weak var CalcularTarifarioBtn: UIButton!    
    @IBOutlet weak var ReinciarTarifarioBtn: UIButton!
    @IBOutlet weak var DetallesCarreraView: UIView!
    @IBOutlet weak var DistanciaText: UILabel!
    @IBOutlet weak var DuracionText: UILabel!
    @IBOutlet weak var CostoText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        coreLocationManager.requestAlwaysAuthorization() 
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        coreLocationManager.startUpdatingLocation()  
        self.MapaTarifario.delegate = self
        MapaTarifario.camera = GMSCameraPosition.camera(withLatitude: (coreLocationManager.location?.coordinate.latitude)!,longitude: (coreLocationManager.location?.coordinate.longitude)!,zoom: 15)
        let JSONStyle = "[" +
            "  {" +
            "    \"featureType\": \"all\"," +
            "    \"elementType\": \"geometry.fill\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"weight\": \"2.00\"" +
            "      }" +
            "    ]" +
            "  }," +
            "       {" +
            "           \"featureType\": \"all\"," +
            "           \"elementType\": \"geometry.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#9c9c9c\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#f2f2f2\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"landscape.man_made\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"poi\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "      }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"saturation\": -100" +
            "           }," +
            "           {" +
            "           \"lightness\": 45" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#e1e2e2\"" +
            "          }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#232323\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"road.highway\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"simplified\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "          \"featureType\": \"road.arterial\"," +
            "           \"elementType\": \"labels.icon\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"off\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"transit\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"all\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"9aadb5\"" +
            "           }," +
            "           {" +
            "           \"visibility\": \"on\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"geometry.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#def5fe\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.fill\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#070707\"" +
            "           }" +
            "           ]" +
            "       }," +
            "       {" +
            "           \"featureType\": \"water\"," +
            "           \"elementType\": \"labels.text.stroke\"," +
            "           \"stylers\": [" +
            "           {" +
            "           \"color\": \"#ffffff\"" +
            "           }" +
            "           ]" +
            "       }," +
            "  {" +
            "    \"featureType\": \"transit\"," +
            "    \"elementType\": \"labels.icon\"," +
            "    \"stylers\": [" +
            "      {" +
            "        \"visibility\": \"on\"" +
            "      }" +
            "    ]" +
            "  }" +
        "]"
        do{
            self.MapaTarifario.mapStyle = try GMSMapStyle(jsonString: JSONStyle)
        }catch{
            print("NO PUEDEEEEEEEEEEEEEEEEEEEEEE")
        }
        self.tarifas = myvariables.tarifas
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        origenIcono.isHidden = true
        if DestinoTarifarioBtn.isHidden == false {
            OrigenTarifario = GMSMarker(position: MapaTarifario.camera.target)
            OrigenTarifario.icon = UIImage(named: "origen")
            OrigenTarifario.map = MapaTarifario
        }
        else{
            if CalcularTarifarioBtn.isHidden == false{
                DestinoTarifario = GMSMarker(position: MapaTarifario.camera.target)
                DestinoTarifario.icon = UIImage(named: "destino")
                DestinoTarifario.map = MapaTarifario
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if ReinciarTarifarioBtn.isHidden == true{
            origenIcono.isHidden = false
            if DestinoTarifarioBtn.isHidden == false {
                OrigenTarifario.map = nil
                ExplicacionText.text = "Localice el origen en el mapa"
            }
            else{
                DestinoTarifario.map = nil
                ExplicacionText.text = "Localice el destino en el mapa"
            }
        }
    }
    func fitAllMarkers(_ markers: [GMSMarker]) {
        var bounds = GMSCoordinateBounds()
        for marcador in markers{
            bounds = bounds.includingCoordinate(marcador.position)
        }
        MapaTarifario.animate(with: GMSCameraUpdate.fit(bounds))
    }
    @IBAction func DestinoTarifario(_ sender: AnyObject) {
        self.OrigenTarifario = GMSMarker(position: self.MapaTarifario.camera.target)
        self.tarifario.InsertarOrigen(OrigenTarifario.position)
        OrigenTarifario.icon = UIImage(named: "origen")
        OrigenTarifario.map = MapaTarifario
        origenIcono.image = UIImage(named: "destino2@2x")
        ExplicacionText.text = "Localice el destino"
        DestinoTarifarioBtn.isHidden = true
        CalcularTarifarioBtn.isHidden = false
        print(self.tarifas[0].valorMinimo)
    }
    @IBAction func CalcularTarifario(_ sender: AnyObject) {
        self.DestinoTarifario = GMSMarker(position: self.MapaTarifario.camera.target)
        self.tarifario.InsertarDestino(DestinoTarifario.position)
        DestinoTarifario.icon = UIImage(named: "destino")
        DestinoTarifario.map = MapaTarifario
        self.fitAllMarkers([self.OrigenTarifario, self.DestinoTarifario])
        origenIcono.isHidden = true
        ExplicacionView.isHidden = true
        ReinciarTarifarioBtn.isHidden = false
        CalcularTarifarioBtn.isHidden = true
        let temporal = self.tarifario.CalcularTarifa(tarifas)
        DetallesCarreraView.isHidden = false
        let lines = self.tarifario.CalcularRuta()
        lines.strokeWidth = 5
        lines.map = self.MapaTarifario
        lines.strokeColor = UIColor.green
        DistanciaText.text = temporal[0] + " KM"
        DuracionText.text = temporal[1]
        CostoText.text = "$" + temporal[2]
    }
    @IBAction func ReiniciarTarifario(_ sender: AnyObject) {
        MapaTarifario.clear()
        ExplicacionView.isHidden = false
        DetallesCarreraView.isHidden = true
        ReinciarTarifarioBtn.isHidden = true
        DestinoTarifarioBtn.isHidden = false
        self.OrigenTarifario = GMSMarker(position: self.MapaTarifario.camera.target)
        OrigenTarifario.icon = UIImage(named: "origen")
        OrigenTarifario.map = MapaTarifario
        ExplicacionText.text = "Localice el origen en el mapa"
    }
}
