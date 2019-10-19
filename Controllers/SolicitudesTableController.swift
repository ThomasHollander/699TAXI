import UIKit
class SolicitudesTableController: UITableViewController {
    var solicitudesMostrar = [CSolicitud]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.solicitudesMostrar.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Solicitudes", for: indexPath)
        cell.textLabel?.text = self.solicitudesMostrar[indexPath.row].fechaHora
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "SolPendientes") as! SolPendController
        vc.SolicitudPendiente = self.solicitudesMostrar[indexPath.row]
        vc.posicionSolicitud = indexPath.row
        self.navigationController?.show(vc, sender: nil)
    }
}
