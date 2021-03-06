//
//  PostContent.swift
//  base_beta
//
//  Created by 後藤壱成 on 2019/12/11.
//  Copyright © 2019 kaito. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore
import FirebaseFirestore

class PostContent: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var reply_contentTextView: UITextView!
    @IBOutlet weak var reply_tableView: UITableView!
    @IBOutlet weak var QuestionContent: UILabel!
    @IBOutlet weak var editbutton: UIButton!
    
    var database1: Firestore!
    var replyArray: [Reply] = []
    //reply_contentTextViewのUI設定関数
    func reply_contentTextView_option(){
        //枠線のUI
        reply_contentTextView.layer.borderColor = UIColor.blue.cgColor
        reply_contentTextView.layer.borderWidth = 2.0
        reply_contentTextView.layer.cornerRadius = 10.0
        reply_contentTextView.layer.masksToBounds = true
        reply_contentTextView.font = UIFont.systemFont(ofSize: 30)
    }
    //QuestionContentのUI設定関数
    func QuestionContent_option(){
        //枠線のUI
        QuestionContent.layer.borderColor = UIColor.blue.cgColor
        QuestionContent.layer.borderWidth = 2.0
        QuestionContent.layer.cornerRadius = 10.0
        QuestionContent.layer.masksToBounds = true
        QuestionContent.font = UIFont.systemFont(ofSize: 30)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reply_contentTextView_option()
        QuestionContent_option()
        if TimelineViewController.userID != Auth.auth().currentUser?.uid{//editbutton表示
            editbutton.isHidden = true
        }
        QuestionContent.text =
            TimelineViewController.content_dash//質問の表示
        //PostContentのタイトルtext sizeの変更
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: 35)!]

        database1 = Firestore.firestore()
        reply_tableView.delegate = self
        reply_tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ここは読み込み
        database1.collection("posts").document("\(TimelineViewController.postID_dash)").collection("reply").order(by: "updatedAt", descending: false).getDocuments{ (snapshot, error) in
            if error == nil, let snapshot1 = snapshot {
                self.replyArray = []
                for document in snapshot1.documents {
                    let data = document.data()
                    let reply_post = Reply(data: data)
                    self.replyArray.append(reply_post)
                }
                self.reply_tableView.reloadData()
            }
        }
    }

    //[戻る]ボタン
    @IBAction func backTiemline(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //返信ボタン
    @IBAction func reply_button(_ sender: Any) {
        let content = reply_contentTextView.text!
        let saveDocument = Firestore.firestore().collection("posts").document("\(TimelineViewController.postID_dash)").collection("reply").document()
        _ = Auth.auth().currentUser!.uid
        saveDocument.setData([
            "reply_content": content,
            "postID": saveDocument.documentID,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let reply_cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell_reply", for: indexPath)
        reply_cell.textLabel?.numberOfLines=0
        // セルに表示する値を設定する
        reply_cell.textLabel!.text = replyArray[indexPath.row].reply_content
        return reply_cell
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
