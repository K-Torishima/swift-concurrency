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

struct AsyncError: Error {
    
    let message: String
    
    init(message: String) {
        self.message = message
        print(message)
    }
}



// 非同期関数の定義

// 戻り値なし　非同期関数
func sample1() async {
    print(#function)
}

// 戻り値あり　非同期関数
func sample2() async -> String {
    return "result"
}

// Errorがある非同期関数
func sample3(showError: Bool) async throws {
    if showError {
        throw AsyncError(message: "error")
    } else {
        print("no error")
    }
}

Task.detached {
    await sample1()
}

Task.detached {
    let result = await sample2()
    print(result)
}

Task.detached {
    do {
        try await sample3(showError: true)
    } catch {
        print(error.localizedDescription)
    }
}


 // イニシャライザにもつけられる

class Sample {
    init(label: String) async {
        print("init async")
    }
}

Task.detached {
    _ = await Sample(label: "aaaa")
}

/*
 
 await キーワードはどこでも使えるわけではない
 await プログラムに待機させるということ
 
 使える場所
 - 非同期関数　body
 - @mainがついている型のmainメソッドのbody
 - Task内
 */


Task.detached {
    let result = await sample2()
    let sample = await Sample(label: result)
    print(sample)
}

// 以下にまとめてかける

Task.detached {
    // awaitを一つにできる
    let sample = await Sample(label: sample2())
}


// 順列実行

// クロージャーの時

// １秒まつメソッドを３回呼ぶ
func waitOneSecond(completionHandler: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
        completionHandler()
    })
}


func runAsSequence() {
    waitOneSecond {
        waitOneSecond {
            waitOneSecond {
                // do something
            }
        }
    }
}

// async/await

// クロージャーのコードを書き換えた
func waitOneSecond() async {
     try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
}

func runAsSequence() async {
    await waitOneSecond()
    await waitOneSecond()
    await waitOneSecond()
}

// 並列実行

func asParallel(completionHandler: @escaping () -> ()) {
    let group: DispatchGroup = .init()
    
    group.enter()
    waitOneSecond {
        group.leave()
    }
    
    group.enter()
    waitOneSecond {
        group.leave()
    }
    
    group.enter()
    waitOneSecond {
        group.leave()
    }
    
    group.notify(queue: .global()) {
        completionHandler()
    }
}

asParallel {
    // １秒まつを３つ並列に実行した後に呼ばれる
}

func asParallel() async {
    async let first: Void = waitOneSecond()
    async let second: Void = waitOneSecond()
    async let third: Void = waitOneSecond()
    
    await first
    await second
    await third
}

Task.detached {
    await asParallel()
}

// withCheckedContinuation

struct User {}

// クロージャーで実装されている関数
func fetchUser(userID: String, completionHandler: @escaping ((User?) -> ())) {
    if userID.isEmpty {
        completionHandler(nil)
    } else {
        completionHandler(User())
    }
}

//　非同期関数にラップする
func wrappedAsyncFetchUser(userID: String) async -> User? {
    return await withCheckedContinuation({ continuation in
        fetchUser(userID: userID) { user in
            continuation.resume(returning: user)
        }
    })
}

Task.detached {
    let userID = "1234"
    let user = await wrappedAsyncFetchUser(userID: userID)
    print(user ?? "")
    
    let noUser = await wrappedAsyncFetchUser(userID: "")
    print(noUser ?? "no user")
}

// withCheckedThrowingContinuation

enum APIError: Error {
    case error
    
    var errorType: String {
        switch self {
        case .error:
            return "これはエラーです"
        }
    }
}

func request(with urlString: String, completionHandler: @escaping (Result<String, APIError>) -> ()) {
    // do somting
    
}


func wrappedRequest(with urlString: String) async throws -> String {
    return try await withCheckedThrowingContinuation({ continuation in
        request(with: urlString) { result in
            continuation.resume(with: result)
        }
    })
}

Task.detached {
    let urlString = "https://example.com"
    let result = try await wrappedRequest(with: urlString)
    print(result)
}


// ラップする場合は必ず resumeを呼ぶこと
//　resumeは2回以上呼ぶとErrorになる、guardとかの中なら条件判定とかされるので関係ない
