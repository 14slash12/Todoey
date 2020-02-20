//
//  CategoryViewController.swift
//  Todoey
//
//  Created by David Louis Lin on 01.02.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
//    var categories = [Category]()
    var categories: Results<Category>?
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Nil coelescing operator to ensure if categories are nil to load 1 row
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        //cell.textLabel?.text = categories[indexPath.row].name
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added yet"
        
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Wenn wir mehrere Segues von CategoryViewController hätten, würden wir ein If-Statement verwenden, um den Identifier (hier: "goToItem") zu überprüfen, um dann innerhalb des If-Statements das Downcasting der destinationVC zum TodoListViewController zu machen.
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
//        do {
//            try context.save()
//        } catch {
//            print("Error saving context: \(error)")
//        }
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {

        categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    
//    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
//
//            do {
//                categories = try context.fetch(request)
//            } catch {
//                print("Error fetching data from context: \(error)")
//            }
//
//            tableView.reloadData()
//        }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            //let newCategory = Category(context: self.context)
            let newCategory = Category()
            
            newCategory.name = textField.text!
            
//            self.categories.append(newCategory)
            
            // Speichern neue Category als einzelnen Datenpunkt. Beim Laden werden alle Kategorien wieder in das categories-Array geladen.
            self.save(category: newCategory)
        }
        
        alert.addTextField { (field) in
            field.placeholder = "Create new category"
            textField = field
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
