//
//  CommentViewController.swift
//  Instagram
//
//  Created by 丸山万綾 on 2023/12/15.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommentViewController: UIViewController {

    var commentData: PostData!
    
    //遷移前のデータから値を受け取る器を作る必要がある
    //クラスがそのまま型になる
    //ここのクラスもCommentViewController型になる
    //クラスはみんな型になる
    //PostData型を使用している
    //型じゃないものはインスタンスが作れない
    //クラスであり型だからインスタンスを作ることができる
    //UI~（例えばUITextFieldとかUIButtonなど）これらも全て型である
    //var targetPostData: PostData?でも記載可能
    //オプショナル型にした理由はポストデータは一意に決めることができないから，オプショナルにして初期値はなしにする
    //アンラップするのが面倒であるのであれば，
    //var targetPostData: PostData!で記載することも可能
    
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func PostCommentButton(_ sender: Any) {
        //1件分のコメントをFieldValueを使用してFireStoreに格納する
        var updateValue: FieldValue
        let userName = Auth.auth().currentUser!.displayName!
        //FireBaseAuthのimportが足りていないとエラーが発生する
        let commentText = commentTextField.text!
        let updateComment = "\(userName): \(commentText)"
        //arrayUnionは元の配列に結合することを命令するコード
        updateValue = FieldValue.arrayUnion([updateComment])
        //1次元の配列の中にユーザー名とコメントを入れる必要がある（FieldValueに支障をきたさないように）
        //どのポストデータにそのコメントを受けわたすかをコードで入れる必要がある
        let postRef = Firestore.firestore().collection(Const.PostPath).document(commentData.id)
        postRef.updateData(["comment": updateValue])
        //commentという名前でFireStoreに格納される
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        //画面を閉じる，dismiss
        self.dismiss(animated: true, completion: nil)
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
