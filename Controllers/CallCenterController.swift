import UIKit
class CallCenterController: UITableViewController {
    var telefonosCallCenter = [CTelefono]()
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
        return self.telefonosCallCenter.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("CallCenterViewCell", owner: self, options: nil)?.first as! CallCenterViewCell
        cell.ImagenOperadora.image = UIImage(named: self.telefonosCallCenter[indexPath.row].operadora)
        cell.NumeroTelefono.text = self.telefonosCallCenter[indexPath.row].numero
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: "tel://\(telefonosCallCenter[indexPath.row].numero)") {
            UIApplication.shared.openURL(url)
        }
    }
}
