import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// Closure
// HTTPリクエストして、レスポンスからイメージを取得し、リサイズして渡す
// これだと読みづらい
func request(url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> ()) {
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard error == nil else { return }
        downloadImage(data: data) { result in
            let image = try? result.get()
            resizeImage(iamge: image) { result in
                completionHandler(result)
            }
        }
    }
    task.resume()
}


func downloadImage(data: Data?, completionHandler: @escaping (Result<UIImage, Error>) ->()) {
    // not impl
}

func resizeImage(iamge: UIImage?, completionHandler: @escaping (Result<UIImage, Error>) ->()) {
    // not impl
}

// async await
// 関数を非同期関数にできる

func request(url: URL) async throws -> UIImage {
    // URLリクエストし、レスポンスをもらう
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
    // イメージをダウンロード
    let image = try await downloadImage(data: data)
    // イメージをリサイズする
    let resizeImage = try await resizeImage(image: image)
    return resizeImage
}
// 非同期関数
func downloadImage(data: Data?) async throws -> UIImage {
    return UIImage()
}

// 非同期関数
func resizeImage(image: UIImage) async throws -> UIImage {
    return UIImage()
}


// 通信中にローディングViewを表示したいなど

var isLoding: Bool = false

// メソッド呼び出しとか
//

func fetch() {
    isLoding = true
    
    let url = URL(string: "https://example.com")!
    request(url: url) { result in
        // ここで書くとコールバックが来た時に呼ばれない
        isLoding = false
        switch result {
        case .success(let image):
            print(image)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

// async await

Task.detached {
    do {
        let url = URL(string: "https://example.com")! // A
        
        let response = try await request(url: url)
        isLoding = false // Errorがなければ必ず通る
        print(response) // B
    } catch {
        isLoding = false // Errorの場合でも必ず通る
        print(error.localizedDescription)
        
    }
}

// AとBのスレッドは同じものとは限らない request(url:)で変わる可能性がある

/*
 await
 プログラムの待機可能性
 - プログラムにそのメソッドやプロパティが待機可能であることを伝える
 - awaitがつけられると、実行中のメソッドやプロパティは待機状態になる
 - そのメソッドやプロパティを実行していたスレッドはブロックを解除し、他の作業を行う
 - システムがそのメソッドやプロパティを再開すると処理が完了し、戻り値があれば左辺に変数が代入される
 
 例:
 通信中Userがボタンを押したり、スクロールするなどUIイベントが発火されることがある
 そのような場合でも、スレッドはブロックされず、他のタスクを実行する
 そしてrequestメソッドが再開されると、結果が変数に代入される
 
 Swift concurrencyでは実行中のメソッドやプロパティを中断、再開して非同期処理を行う
 開発者はスレッドの管理を気ににすることなく同期的なコードと同じような書き方で、非同期処理を実行できる
 awaitキーワードで実行後のスレッドはその前で実行されたスレッドされたスレッドのものとは限らない
 
 
 
 */
