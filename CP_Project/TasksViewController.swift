//
//  TasksViewController.swift
//  CP_Project
//
//  Created by Adam Anderson on 4/15/20.
//  Copyright © 2020 Manish Rajendran. All rights reserved.
//

import UIKit
import Parse

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var helper = ParseHelper()
    var groups : Array<PFObject> = []
    var tasks : Array<PFObject> = []
    var taskIds : Array<String> = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentUser = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
                
        
        getGroupsFromPFUser(user: PFUser.current()!)
        getTasksFromPFUser(user: PFUser.current()!)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        
        #warning("Timer runnning")
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)

    }
    
    @objc func loadList(notification: NSNotification){
        getTasksFromPFUser(user: PFUser.current()!)
    }
    
    func getGroupsFromPFUser(user: PFUser) -> Void {
        let query = PFQuery(className:"UserToGroup")
        query.whereKey("user", equalTo:user)
        query.includeKeys(["group"])
        query.selectKeys(["group"])
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) objects.")
                // Do something with the found objects
                for object in objects{
                    let group = object["group"] as! PFObject
                    self.groups.append(group)
                }
            }
        }
    }
    
    func getTasksFromPFUser(user: PFUser) -> Void {
        // TRIED TO DO A WHERE IT SEARCHES THE GROUP IN THE TASK ROW FOR THE PFUSER.CURRENT
//        let query = PFQuery(className:"Task")
//        query.whereKey("user", containedIn: PFObject!["group"])
//        query.includeKeys(["group"])
//        query.selectKeys(["group"])
//        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
//            if let error = error {
//                // Log details of the failure
//                print(error.localizedDescription)
//            } else if let objects = objects {
//                // The find succeeded.
//                print("Successfully retrieved \(objects.count) objects.")
//                // Do something with the found objects
//                for object in objects{
//                    print(object)
//                }
//            }
//        }
        
        
        let query = PFQuery(className:"TaskToUser")
        query.whereKey("user", equalTo:user)
        query.includeKeys(["task"])
//        query.selectKeys(["group"])
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) objects.")
                // Do something with the found objects
                for object in objects{
                    let task = object["task"] as! PFObject
                    if self.taskIds.contains(task.objectId!) {
                        print("Task already in array")
                    } else {
                        self.tasks.append(task)
                        self.taskIds.append(task.objectId!)
                    }
                }
            }
            self.tableView.reloadData()

        }

    }
    
    @IBAction func onJoker(_ sender: Any) {
        print("\n____ PRINTING GROUPS ____\n", self.groups, "\n____ DONE PRINTING GROUPS ____\n")
        print("\n____ PRINTING TASKS ____\n", self.tasks, "\n____ DONE PRINTING TASK ____\n")
        
    }
    
    @IBAction func onLogout(_ sender: Any) {
            
        PFUser.logOut()
        UserDefaults.standard.set(false, forKey: "UserLoggedIn")

        let main = UIStoryboard(name: "Main", bundle: nil)
        let viewController = main.instantiateViewController(withIdentifier: "ViewController")
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate

        sceneDelegate.window?.rootViewController = viewController
        
    }
    
     override func viewWillAppear(_ animated: Bool) {
//        if currentUser?["tasks"] != nil {
//            tasks = currentUser!["tasks"] as! [String]
//            self.tableView.reloadData()
//        }
        getTasksFromPFUser(user: PFUser.current()!)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskCell
        
        cell.taskLabel.text = tasks[indexPath.row]["title"] as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func onTimer() {
        getTasksFromPFUser(user: PFUser.current()!)
        #warning("Timer runnning")
        
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
