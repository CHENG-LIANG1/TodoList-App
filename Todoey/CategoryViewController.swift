//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Cheng Liang(Louis) on 2022/1/20.
//

import UIKit
import CoreData
import SnapKit

class CategoryViewController: UIViewController {
    
    let categoryTableView = Tools.setUpTableView(borderWidth: 0, rowHeight: 60, enableScroll: true)
    
    var cateArray: [Category] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))

        navigationItem.rightBarButtonItems = [add]

        self.title = "Category"
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.register(CateCell.self, forCellReuseIdentifier: "CateCell")
        view.addSubview(categoryTableView)
        categoryTableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        loadItems()
    }
    
    @objc func addButtonPressed(sender: UIBarButtonItem){
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new to-do", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            let newCate = Category(context: self.context)
            newCate.name = textField.text!


            self.cateArray.append(newCate)
            
            self.saveItems()
            
            self.categoryTableView.reloadData()
        }
        
        alert.addTextField { alertTextField  in
            alertTextField.placeholder = "Add"
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
        self.categoryTableView.reloadData()
    }
    
    func loadItems(request: NSFetchRequest<Category> = Category.fetchRequest()){
        do {
          cateArray = try context.fetch(request)
        }catch {
            print(error)
        }
        categoryTableView.reloadData()
    }
    
}

extension CategoryViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CateCell", for: indexPath) as! CateCell
        cell.textLabel?.text = cateArray[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
