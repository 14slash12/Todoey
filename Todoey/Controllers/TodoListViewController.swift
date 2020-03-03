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

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    // Wissen allgemein nicht welche Kategorie es ist, da diese vom User selbst definiert wird. Deswegen macht es Sinn eine Optional-Variable zu verwenden (s. Fragezeichen hinter "Category").
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
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
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once the user clicks the Add Item Button in our UIAlert
            
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
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let selectedItem = self.todoItems?[indexPath.row] {
            
            do {
                try realm.write {
                    realm.delete(selectedItem)
                }
            } catch {
                print("Error while deleting a category: \(error)")
            }
            
            //tableView.reloadData() nicht notwendig, da die function tableView(_:, editActionsOptionsForRowAt:, for:) den tableView schon neu lädt. Führt sogar so zu einem Fehler in der App, wenn die obig erwähnte delegate-Function verwendet wird. Ohne die obig erwähnte delegate-Function ist hier jedoch tableView.reloadData() notwendig.
        }
    }
}

//MARK: - Search bar Methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
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

