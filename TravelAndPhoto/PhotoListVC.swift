//
//  PhotoListVC.swift
//  TravelAndPhoto
//
//  Created by Vahit Emre TELLİER on 7.12.2021.
//

import UIKit
import CoreData

class PhotoListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID]()
    
    var choosenTitle = ""
    var choosenID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//          topbar ulaşıldı ve UIBarButtonItem.SystemItem.add ile add butonu koyuldu.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    @objc func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
//        veri çekmeyi hızlandırmak içi cash ile ilgili işlem
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
//            results is an Array
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
//                    tableView refresh
                    tableView.reloadData()
                }
            }
        } catch {
            print("error!")
        }
        
    }
    
    @objc func addButtonClicked(){
        choosenTitle = ""
        performSegue(withIdentifier: "toVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenTitle = titleArray[indexPath.row]
        choosenID = idArray[indexPath.row]
        performSegue(withIdentifier: "toVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
//        delete photo in row
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
    //        veri çekmeyi hızlandırmak içi cash ile ilgili işlem
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
    //            results is an Array
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
//                            id ile satırda seçtiğimi itemin id si eşit ise
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                    
                                } catch {
                                    print("Error!")
                                }
//                               we need to break when we work with huge databases
                                break
                            }
                        }
                    }
                }
            } catch {
                print("error!")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVC"{
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = choosenTitle
            destinationVC.selectedID = choosenID
            
        }
    }


}
