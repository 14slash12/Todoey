//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift
import SwipeCellKit

class TodoListViewController: UITableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    // Wissen allgemein nicht welche Kategorie es ist, da diese vom User selbst definiert wird. Deswegen macht es Sinn eine Optional-Variable zu verwenden (s. Fragezeichen hinter "Category").
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            //Tenary operatoer ==>
            // value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        
        
        return cell
    }

    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    
                    ///Delete from Realm-Database
                    //realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        
        tableView.reloadData()
        
        
//        Delete item when selected
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
//
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//
//        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once the user clicks the Add Item Button in our UIAlert
            
//            let newItem = Item(context: self.context)
//            newItem.title = textField.text!
//            newItem.done = false
//            newItem.parentCategory = self.selectedCategory
//            self.itemArray.append(newItem)
            
            //self.saveItems()
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        /// Creates a new item adding it to the Realm database
                        let newItem = Item()
                        newItem.title = textField.text!
                        //newItem.done = false not necessary anymore; default value specified in the Item class.
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving items: \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
            //Das würde nur "Optional("")" ausgeben, da dieses Print-Statement lediglich einmal beim Hinzufügen des textFields ausgeführt wird. Wir befinden uns ja in der Trailing-Closure der Funktion addTextField. Man übergibt das alertTextField einer für die ganze IBAction zugängliche Variable namens textField. Anschließend kann man darauf in der Trailing-Closure der initialisierung der action bzw. des Hinzufügens des "Add Item"-Buttons auf das textField zugreifen und den Text mit print() ausgeben bzw. dem itemArray hinzufügen.
            //print(alertTextField.text)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Model Manipulation Methods

    ///Save function only needed for CoreData
//    func saveItems() {
//        do {
//            try context.save()
//        } catch {
//            print("Error saving items: \(error)")
//        }
//         
//        tableView.reloadData()
//    }
    
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching items from context: \(error)")
//        }
//
//        tableView.reloadData()
//    }
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
}

//MARK: - Search bar Methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}

//MARK: - SwipeCell Delegate Methods

extension TodoListViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }

        var options = SwipeTableOptions()
        options.expansionStyle = .destructiveAfterFill
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            if let item = self.todoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        
                        ///Delete from Realm-Database
                        self.realm.delete(item)
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
                
            }
            
            // As we added the added the function tableView(_:, editActionsOptionsForRowAt:, for:) the gesture was added to delete tableViewCells with one complete slide from the right to the left.
            // If we reload the Data from the tableView an SIGBART-Error will occur due to following scenario:
            // 1. We swipe completly from right to left.
            // 2. The item get's deleted from the Realm-Database due to the call of THIS closure we are in right now (i.e. This SwipeActions closure get's triggered)
            // 3. We reload the the tableView -> The item dissappears from the tableView, because it is no longer in the Realm Database
            // 4. The tableView(_:, editActionsOptionsForRowAt:, for:) wants to delete the item from the tableView -> but due to the tableView.reloadData() call this item no longer exists in this tableView.
            // 5. The error occurs.
            //tableView.reloadData()
            
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        deleteAction.fulfill(with: .delete)

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }

}
