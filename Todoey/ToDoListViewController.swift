//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import SnapKit
import CoreData
class ToDoListViewController: UIViewController {

    var itemArray: [Item] = []
    
    var selectedCategory : Category? {
        didSet{
            let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            loadItems(predicate: predicate)
        }
    }
    
    
    let todolistTableView = Tools.setUpTableView(borderWidth: 0, rowHeight: 60, enableScroll: true)
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Todoey"

        navigationController?.navigationBar.backgroundColor = .white
        view.backgroundColor = .white
        todolistTableView.delegate = self
        todolistTableView.dataSource = self
        todolistTableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(70)
        }
        
        
        view.addSubview(todolistTableView)
        todolistTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp_bottomMargin)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))

        navigationItem.rightBarButtonItems = [add]
        
//        if let items = UserDefaults.standard.array(forKey: "todos") as? [Item] {
//            itemArray = items
//        }
        
        searchBar.delegate = self
        
        
    }
    
    @objc func addButtonPressed(sender: UIBarButtonItem){


        var textField = UITextField()

        let alert = UIAlertController(title: "Add a new to-do", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            self.todolistTableView.reloadData()
        }
        
        alert.addTextField { alertTextField  in
            alertTextField.placeholder = "Create a new task"
            textField = alertTextField
        }

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func saveItems(){
        do {
            try context.save()
            
        }catch{
            print(error)
        }
        self.todolistTableView.reloadData()
    }
    
    func loadItems(request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
  
        
        request.predicate = predicate
        do {
          itemArray = try context.fetch(request)
        }catch {
            print(error)
        }
        todolistTableView.reloadData()
    }
    
//
//    func saveItems(){
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(self.itemArray)
//            try data.write(to: self.dataFilePath!)
//        }catch{
//            print("error")
//        }
//    }
//
//    func loadItems(){
//        if let data = try? Data(contentsOf: dataFilePath!){
//            let decoder = PropertyListDecoder()
//            itemArray = decoder.decode([Item].self, from: dataFilePath!)
//        }
//
//    }
    
    
}

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()

        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
        loadItems(request: request, predicate: predicate)
        
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

extension ToDoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveItems()
        tableView.reloadData()
        
    }

}

