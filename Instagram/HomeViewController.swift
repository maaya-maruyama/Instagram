//
//  HomeViewController.swift
//  Instagram
//
//  Created by 丸山万綾 on 2023/11/30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    let postData = PostData(document: document)
                    print("DEBUG_PRINT: \(postData)")
                    return postData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])

        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action:#selector(handlecommentButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
         print("DEBUG_PRINT: likeボタンがタップされました。")

         // タップされたセルのインデックスを求める
         let touch = event.allTouches?.first
         let point = touch!.location(in: self.tableView)
         let indexPath = tableView.indexPathForRow(at: point)

         // 配列からタップされたインデックスのデータを取り出す
         let postData = postArray[indexPath!.row]

         // likesを更新する
         if let myid = Auth.auth().currentUser?.uid {
             // 更新データを作成する
             var updateValue: FieldValue
             //Firestore上から一件分だけを追加したり削除したりする（データ通信量の削減）
             if postData.isLiked {
                 // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                 updateValue = FieldValue.arrayRemove([myid])
             } else {
                 // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                 updateValue = FieldValue.arrayUnion([myid])
             }
             // likesに更新データを書き込む
             let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
             postRef.updateData(["likes": updateValue])
             //ここで初めてFireStoreの更新をかけている（差分のデータだけをFireStore側で処理する）
         }
     }
    
    @objc func handlecommentButton(_ sender: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        //identifierとして指定するものは遷移先の画面のstoryboard ID（任意の文字列）
        //as!はクラスを指定しており，CommentViewController型を指定している
        //画面を開きたいときには，UIとそれに伴った.swiftファイルのインスタンスを作成したいときには，別のコードを記載する必要がある
        //遷移先のビューコントローラーのインスタンスを作るinstantiateViewControllerというメソッド
        //storyboard上の画面のインスタンスを作成したいときに使う
        //segueを使わず直接storyboardからインスタンスを取得している
        viewController.commentData = postData
        //インスタンスの取得ができているので，遷移先の画面が持つメソッドに受け渡すことができる
       
        present(viewController, animated: true,completion: nil)
        //ボタンを押したら画面遷移するようにしたい
        //引数にインスタンス名を入れることで画面遷移が可能になる
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
