//
//  InputViewController.swift
//  taskapp
//
//  Created by user on 2023/03/20.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    
//    realmインスタンス取得
    let realm = try! Realm()
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        背景タップでキーボード閉じる
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
//        タスク表示
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
        }
        
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
//    キーボード閉じる
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
//    ローカル通知
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        
        if task.title == ""{
            content.title = "（タイトルなし）"
        } else {
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "（内容なし）"
        } else {
            content.body = task.contents
        }

        content.sound = UNNotificationSound.default
        
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in
            print(error ?? "ローカル通知登録　OK")
        }
        center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
            for request in requests{
                print("/----------------------------")
                print(request)
                print("/----------------------------")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
