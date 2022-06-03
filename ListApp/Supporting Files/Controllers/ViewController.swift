//
//  ViewController.swift
//  ListApp
//
//  Created by Hasan Kaya on 28.05.2022.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    var alertController = UIAlertController()
    var data = [NSManagedObject]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }
    
    func makeAlert(){
        let alert = UIAlertController(title: "Yeni eleman ekle", message: nil, preferredStyle: .alert)
        let defalutButton = UIAlertAction(title: "Ekle",
                                          style: .default) { UIAlertAction in
            let text = alert.textFields?.first?.text
            if text != "" {
                // self.data.append((alert.textFields?.first?.text!)!)
                self.saveData(title: text!)
                
                self.fetch()
            }
        }
        
        let cancellButton = UIAlertAction(title: "Vazgeç",
                                          style: .cancel,
                                        handler: nil)
        alert.addAction(defalutButton)
       
        alert.addAction(cancellButton)
        alert.addTextField()

        self.present(alert, animated: true)
    
    }
    
    @IBAction func removeButtonTouched(_ sender: Any) {
        // data.removeAll(keepingCapacity: false)
        self.fetch()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequset = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequset)
        do {
            try context.execute(deleteRequest)
            self.fetch()
        } catch  {
            print("silinemedi")
        }
    }
    
    @IBAction func AddButtonTouched(_ sender: Any) {
        presentAlert(title: "Ekle", message: "Eleman ekleyin", prefferedStyle: .alert, defaultButtonTitle: "Ekle", cancelButtonTitle: "Vazgeç", isTextFieldAvailable: true) { UIAlertAction in
            let text = self.alertController.textFields?.first?.text
            if  text != "" {
                self.saveData(title: text!)
                self.fetch()
                
            } else {
                self.presentAlert(title: "Hata", message: "Değer girmediniz", prefferedStyle: .alert, defaultButtonTitle: nil, cancelButtonTitle: "Tamam", isTextFieldAvailable: false, defaultButtonHandler: nil)
            }
        }
       
    }
    func presentAlert(title :String?,
                    message : String?,
                    prefferedStyle : UIAlertController.Style = .alert,
                    defaultButtonTitle : String? = nil,
                    cancelButtonTitle : String? = nil,
                    isTextFieldAvailable: Bool = false,
                      defaultButtonHandler  : ((UIAlertAction) -> Void)? = nil){
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
       
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelButton)
        if isTextFieldAvailable {
            alertController.addTextField()
        }
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        self.present(alertController, animated: true)
    }
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        data = try! context.fetch(fetch)
        tableView.reloadData()
    }
    func saveData(title :String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedContext)
        let listItem = NSManagedObject(entity: entity!, insertInto: managedContext)
        listItem.setValue(title, forKey: "title")
        try? managedContext.save()
    }

    
}
extension ViewController:  UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
     //vcell.textLabel?.text = data[indexPath.row]
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as! String
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Sil") { _, _, _ in
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(self.data[indexPath.row])
            try? context.save()
            self.fetch()
        }
        let editingAction = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Ekle", message: "Ekle", prefferedStyle: UIAlertController.Style.alert, defaultButtonTitle: "Ekle", cancelButtonTitle: "Vazgeç", isTextFieldAvailable: true) { UIAlertAction in
                let text = self.alertController.textFields?.first?.text
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                self.data[indexPath.row].setValue(text, forKey: "title")
                if context.hasChanges{
                    try? context.save()
                    
                }
                tableView.reloadData()
            }
        }
        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction,editingAction])
        return config
    }
}

