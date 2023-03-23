//
//  ViewController.swift
//  taskapp
//
//  Created by user on 2023/03/20.
//

import UIKit
import RealmSwift
import UserNotifications
import SwiftUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    
    
    @IBOutlet weak var categorySearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
//    realmインスタンス取得
    let realm = try! Realm()

//    タスク格納リスト
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        //罫線
        tableView.fillerRowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        categorySearchBar.delegate = self
        
        //何も入力されていなくてもReturnキーを押せるようにする。
        categorySearchBar.enablesReturnKeyAutomatically = false
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            tableView.reloadData()
        } else {
            print(searchText)
            let result = try! Realm().objects(Task.self).filter("category == %@",searchText).sorted(byKeyPath: "date", ascending: true)
            taskArray = result
            tableView.reloadData()
        }
    }
    
//    タスクタップと＋ボタンの画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else{
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
//    入力・編集から戻ってきたときテーブルをリロード
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //セルの高さ見やすくカスタマイズ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
//  セル選択で画面遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
//    セル削除可能
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    deleteボタンでタスク削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write{
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests {(requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/----------------------------")
                    print(request)
                    print("/----------------------------")

                }
            }
        }
    }
}

