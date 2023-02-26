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

//Task.detached {
//    do {
//        let url = URL(string: "https://example.com")! // A
//
//        let response = try await request(url: url)
//        //isLoding = false // Errorがなければ必ず通る
//        //print(response) // B
//    } catch {
//        //isLoding = false // Errorの場合でも必ず通る
//        //print(error.localizedDescription)
//
//    }
//}

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
       // print(message)
    }
}



// 非同期関数の定義

// 戻り値なし　非同期関数
func sample1() async {
   // print(#function)
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
       // print("no error")
    }
}

//Task.detached {
//    await sample1()
//}
//
//Task.detached {
//    let result = await sample2()
//    //print(result)
//}
//
//Task.detached {
//    do {
//        try await sample3(showError: true)
//    } catch {
//       // print(error.localizedDescription)
//    }
//}


 // イニシャライザにもつけられる

class Sample {
    init(label: String) async {
        //print("init async")
    }
}

//Task.detached {
//    _ = await Sample(label: "aaaa")
//}

/*
 
 await キーワードはどこでも使えるわけではない
 await プログラムに待機させるということ
 
 使える場所
 - 非同期関数　body
 - @mainがついている型のmainメソッドのbody
 - Task内
 */

//
//Task.detached {
//    let result = await sample2()
//    let sample = await Sample(label: result)
//    //print(sample)
//}

// 以下にまとめてかける

//Task.detached {
//    // awaitを一つにできる
//    let sample = await Sample(label: sample2())
//}
//
//
//// 順列実行

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

//Task.detached {
//    await asParallel()
//}

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

//Task.detached {
//    let userID = "1234"
//    let user = await wrappedAsyncFetchUser(userID: userID)
//    //print(user ?? "")
//
//    let noUser = await wrappedAsyncFetchUser(userID: "")
//    //print(noUser ?? "no user")
//}

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

//Task.detached {
//    // let urlString = "https://example.com"
//    // let result = try await wrappedRequest(with: urlString)
//    // print(result)
//}


// ラップする場合は必ず resumeを呼ぶこと
//　resumeは2回以上呼ぶとErrorになる、guardとかの中なら条件判定とかされるので関係ない


// Actor
/*
 データ競合を守る新しい型
 マルチスレッドプログラミングに置いて重要な問題としてはいかにデータ競合を防ぐことが大切
 複数のスレッドから一つのデータにアクセスした場合、少なくとも一つのスレッドがデータを更新するとデータが不整合を起こしてしまう可能性がある
 デバックが非常に難しい厄介なバグになりがち

 
 */

class Score {
    var logs: [Int] = []
    private(set) var highScore: Int = 0
    
    func update(with score: Int) {
        logs.append(score)
        if score > highScore {
            highScore = score
        }
    }
}

let score = Score()

//DispatchQueue.global(qos: .default).async {
//    score.update(with: 100)
//    print(score.highScore)
//}
//
//DispatchQueue.global(qos: .default).async {
//    score.update(with: 110)
//    print(score.highScore)
//}

// シリアルキューでデータ競合を防ぐ
// 昔はNSLockを使っていた。扱いが難しい
// DispatchQueueでは以下の実装をする

class Score_Old {
    
    private let serialQueue = DispatchQueue(label: "serial-dispatch-queue")
    var logs: [Int] = []
    private(set) var heghScore: Int = 0
    
    func update(with score: Int, completion: @escaping ((Int) -> ())) {
        serialQueue.async { [weak self] in
            guard let self else { return }
            self.logs.append(score)
            if score > self.heghScore {
                self.heghScore = score
            }
            completion(self.heghScore)
        }
    }
}

let scoreOld = Score_Old()

//DispatchQueue.global(qos: .default).async {
//    scoreOld.update(with: 100) { highScore in
//        print("従来の実装", highScore)
//    }
//}
//
//DispatchQueue.global(qos: .default).async {
//    scoreOld.update(with: 110) { highScore in
//        print("従来の実装", highScore)
//    }
//}


// Actorでデータ競合を防ぐ
actor ScoreActor {
    
    var logs: [Int] = []
    private (set) var highScore: Int = 0
    
    func update(with score: Int) {
        logs.append(score)
        if score > highScore {
            highScore = score
        }
    }
}

let scoreActor = ScoreActor()
//
//Task.detached {
//    await scoreActor.update(with: 100)
//    print("actorで実装", await scoreActor.highScore)
//}
//
//Task.detached {
//    await scoreActor.update(with: 110)
//    print("actorで実装", await scoreActor.highScore)
//}

 
// Actorは参照型
// class Enum structと同じ機能を持つ
// Actorは継承できない

//actor A {}
//actor B: A {} // Actor types do not support inheritance

// ActorはインスタンスごとにActor隔離として他のプログラムから守られている
// Actor外からアクセスするにはawaitをつける
// why -> コンパイラに他のタスクがアクセスしている場合はプログラムが中断されそのタスクが終わるまで待機することを伝えるため
// Actorのメソッドの前にawaitをつけないとErrorになる
// Actorの中にあるプロパティはActor外で直接更新はできない Errorになる

actor C {
    var num: Int = 0
    
    func update(with value: Int) {
        // ここにawaitはいらない
        // Actorが他のコードから隔離されているためActor内では自由に更新可能
        num = value
    }
}

let c = C()
//Task.detached {
//    // 以下はできない
//    // await c.num = 1 // Actor-isolated property 'num' can not be mutated from a Sendable closure
//    // これはできる
////    await c.update(with: 2)
//}


// nonisolatedでActor隔離を解除する

//以下のような場合はActor隔離だと都合が悪いのでhash()にnonisolatedをつける

actor B: Hashable {
    
    static func == (lhs: B, rhs: B) -> Bool {
        lhs.id == rhs.id
    }
    
    // Actor-isolated instance method 'hash(into:)' cannot be used to satisfy nonisolated protocol requirement
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: UUID = UUID()
    private(set) var number = 0
    
    func increace() {
        number += 1
    }
}

// nonisolated Actorを隔離するキーワード
// これをつけることで、Actorの外ではawaitなしで実行できる
// nonisolatedは呼び出したい時だけつける
// Protocolに準拠してProtocolが持っているメソッドを使いたい時だけはこれが必要
// 書き込み可能なデータにnonisolatedはつけられない


//actor G: Hashable {
//    static func == (lhs: G, rhs: G) -> Bool {
//        lhs.id == rhs.id
//    }
//
//
//   nonisolated func hash(into hasher: inout Hasher) {
      // 書き込み可能なデータをnonisolatedで操作しようとするとErrorになる
      // これはnumが書き込み可能なためError
//       hasher.combine(num) // Actor-isolated property 'num' can not be referenced from a non-isolated context
//    }
//
//    let id: UUID = UUID()
//    var num: Int = 0
//}
//


// 2.5 再入可能性と競合状態


actor ScoreA {
    
    var localLogs: [Int] = []
    
    private(set) var highScore: Int = 0
    
    func update(with score: Int) async {
        highScore = await requestHighScore(with: score)
        localLogs.append(score)
    }
    
    func requestHighScore(with score: Int) async -> Int {
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        return score
    }
}

let scoreA = ScoreA()

//Task.detached {
//    await scoreA.update(with: 100)
//    print(await scoreA.localLogs)
//    print(await scoreA.highScore)
//}
//
//Task.detached {
//    await scoreA.update(with: 110)
//    print(await scoreA.localLogs)
//    print(await scoreA.highScore)
//}


actor ImageDownloder {
    private var cached: [String: UIImage] = [:]
    
    func image(from url: String) async -> UIImage {
        // キャッシュがあればそれを使う
        if cached.keys.contains(url) {
            return cached[url]!
        }
        // イメージをダウンロード
        let image = await downloadImage(from: url)
        // キャッシュに保存
        cached[url] = image
        return cached[url]!
        
    }
    
    // サーバーに画像をリクエストすることを想定するmethod
    // 2秒後に画像をランダムで返す
    
    func downloadImage(from url: String) async -> UIImage {
        try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        switch url {
        case "monster":
            // サーバー側でリソースが変わったことを表すためランダムで画像をセットする
            let imageName = Bool.random() ? "cow" : "fox"
            return UIImage(named: imageName)!
        default:
            return UIImage()
        }
    }
}


let imageDownLoder = ImageDownloder()

//Task.detached {
//    let image = await imageDownLoder.image(from: "monster")
//    print(image)
//}
//
//Task.detached {
//    let image = await imageDownLoder.image(from: "monster")
//    print(image)
//}


func downloadImage(from: String) async -> UIImage {
    return UIImage()
}
// Task で競合状態を防ぐ

actor ImageDownloader2 {
    private enum CacheEntry {
        case inProgress(Task<UIImage, Never>)
        case ready(UIImage)
    }
    
    //　キャッシュにタスクを保存する
    private var cache: [String: CacheEntry] = [:]
    
    
    func image(from url: String) async -> UIImage? {
        // キャッシュチェック
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let task):
                // 処理中ならtask.valueで画像を取得
                // awaitがあるのでプログラムは中断する
                return await task.value
            }
        }
        
        let task = Task {
            await downloadImage(from: url)
        }
        
        // タスクをキャッシュに保存
        // awaitがないのでプログラムは中断しない
        cache[url] = .inProgress(task)
        // task.valueでイメージを取得
        let image = await task.value
        cache[url] = .ready(image)
        return image
    }
}



// MainActor

/*
 UIKitやSwiftUIなどのUI操作のコードの実装にはメインスレッドでの実行が欠かせない。
 UI操作のコードもデータ競合が発生しないよう特別なActorを用意した。それがMainActor
 通常のActor隔離は各インスタンスごとに適応されるがMainActorを適応するとグローバルに共通なActorインスタンスが作成されそのインスタンスと通じてActor隔離が行われる
 MainActorは内部でDispatchQueue. mainを呼び足しており、データ競合を防ぎつつ処理をメインスレッドで実行することを保証している


*/


// 型全体に適応できる
@MainActor
class UserDataSource {
    // 暗黙的にMainActorが適応されている
    var user: String = ""
    // 暗黙的にMainActorが適応されている
    func updateUser() {}
    //　nonisolatedでMainActorを解除する
    nonisolated func sendLogs() {}
}


struct Mypage {
    // プロパティに適応　swift5.xではErrorにならないけど　Swift6からErrorになる
    // Stored property 'info' within struct cannot have a global actor; this is an error in Swift 6
    @MainActor
    var info: String = ""
    
    // メソッドに適応
    @MainActor
    func updateInfo() {}
    
    // MainActorに適応されない
    func sendLogs() {}
}


// MainActorでUIのデータ更新

@MainActor
final class ViewModel: ObservableObject {
    
    @Published private(set) var text: String = ""
    
    nonisolated func fetchUser() async -> String {
        return await waitOneSecond(with: "Arex")
    }
    
    func didTapButton() {
        Task {
            text = ""
            await fetchUser()
        }
    }
    
    private func waitOneSecond(with string: String) async -> String {
        try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        return string
    }
}


// Actor はデータ競合という並行プログラミングにおいて厄介な問題をスマートに解決する新しい型
// Actorのおかげで複数タスクから同時にデータを書き込もうとしてもデータを守れるコードを簡単に実装できる
// ただし、Actorの再入可能の特徴のため競合状態が発生する可能性がある
//　プログラムの中断と再開でActorの状態が変わるそれに対応するコードを書かないと思わぬ不具合につながる
// UI操作のコードはメインメソッドでの実行が必要だが、MainActorという特別なActorを利用することで処理をメインスレッドで実行しつつデータ競合を防ぐことができる


// Async Sequence
// for await inとか既存のやつとかを非同期にできる
// ios15からfor await in が使える


// URL.lines
// iOS15から追加されたAPI
// ファイルを for await in を使って一行ずつ読み込むことができるプロパティ
// ファイル読み込みという思い処理を非同期処理で行いつつ、呼び出し元ではループを回してファイル内容を読み取れるようなAPIとなっている
//

var text: String = ""

@MainActor
func roadText() {
    Task {
        text = ""
        guard let url = Bundle.main.url(forResource: "text", withExtension: "txt") else {
            return
        }
        
        do {
            for try await line in url.lines {
                text += "\(line)\n"
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// apple boy cat dog east five goat
// for await in は for inと同じプロパティを使える
// continueとかbreak とか使える

// NotificationCenterにも使える　notificationsというメソッドが生えた
// 今まではNotificationのイベント購読はaddObserverの実行が必要だった
// selecterで行うやつと、forNameで行うやつがあった


// アプリがバックグラウンドから復帰したイベントを購読する
let notificationCenter = NotificationCenter.default
notificationCenter
    .addObserver(forName: UIApplication.willEnterForegroundNotification,
                 object: nil,
                 queue: nil) { notification in
        print(notification)
}


// iOS15から以下の書き方でも同様な処理になる
// notificationsの引数に購読するNotificationを渡してその戻り値に対してfor await in ループを回すだけ
// イベントが通知されるたびにfor await in ループが通り、イベントをハンドリングできるようにする
// for await in は「時間経過によって繰り返し行われるイベント処理」にも利用できる
//let notificationCenter2 = NotificationCenter.default
//let willEnterForeground = notificationCenter2.notifications(named: UIApplication.willEnterForegroundNotification)
//for await notification in willEnterForeground {
//    print(notification)
//}


// キャンセル
// addObserverの時はremoveObserverで解除をする
// notificationsでは、Task.init Task.detachedを利用する
// Task.initやTask.detachedのインスタンスを保持しておいてキャンセルする場合にcancelを実行することで購読キャンセルができる

// Taskを作ってその中で操作する的な感じになる

var enterForegroundTask: Task<Void, Never>?

func checkAppStatus() {
    let notificationCenter = NotificationCenter.default
    
    // タスクのインスタンスを保持する
    enterForegroundTask = Task {
        let willEnterForeground = await notificationCenter.notifications(named: UIApplication.willEnterForegroundNotification)
        
        for await Notification in willEnterForeground {
            print(Notification)
        }
    }
}

func cleanup() {
    // キャンセルを呼び出して購読を解除
    enterForegroundTask?.cancel()
}

// Task インスタンスによるキャンセルはNotification Centerに限らず for await in ループに対して途中でキャンセルさせる方法
// for await in が長い時間かかっている場合などでもこの方法でキャンセルができる

// カスタム定義
//for await in でループを回せる型を定義できる
// AsyncSequence

// Counterという渡させた値でカウントダウンができる型を定義する

struct Counter {
    // MARK: -
    struct AsyncCounter: AsyncSequence {
        typealias Element = Int
        
        let amount: Int
        
        struct AsyncIterator: AsyncIteratorProtocol {
            var amount: Int
            
            mutating func next() async throws -> Element? {
                // 0未満だったらnilを返してループを終了させる
                guard amount >= 0 else {
                    return nil
                }
                
                let result = amount
                amount -= 1
                return amount
            }
        }
        
        func makeAsyncIterator() -> AsyncIterator {
            return AsyncIterator(amount: amount)
        }
    }
    
    // MARK: -
    
    func countdown(amount: Int) ->  AsyncCounter {
        return AsyncCounter(amount: amount)
    }
}

let counter = Counter()

//for try await i in counter.countdown(amount: 10) {
//    print(i)
//}

// filter, contains, map, compactMap, flatMap, allStatisfy, min, max　とか使える
//let firstEven = await counter.countdown(amount: 10).filter { $0 % 2 == 0 }


// 既存コードの適応
// AsyncStream AsyncThrowingStream

//　位置情報取得コードをfor await inが使えるようにする

import MapKit
import SwiftUI

@MainActor
final class LocationManager: NSObject, ObservableObject {
    
    @Published var coordinate: CLLocationCoordinate2D = .init()
    
    private let locationManager = CLLocationManager()
    
    func setup() {
        locationManager.delegate = self
    }
    
    func startLocation() {
        locationManager.startUpdatingHeading()
    }
    
    func stopLocation() {
        locationManager.stopUpdatingHeading()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        
        coordinate = lastLocation.coordinate
    }
}

struct AsyncStreamView: View {
    @StateObject
    private var locationManager: LocationManager
    
    var body: some View {
        VStack {
            Text("緯度:\(locationManager.coordinate .latitude)\n経度:\(locationManager.coordinate .longitude)")
                .font(.largeTitle)
            
            List {
                Button {
                    locationManager.startLocation()
                } label: {
                    Text("start")
                }
            }
        }
        .onAppear {
            locationManager.setup()
        }
    }
    
    init() {
        self._locationManager = StateObject(wrappedValue: LocationManager())
    }
}

PlaygroundPage.current.setLiveView(AsyncStreamView())

// 非同期シーケンスを使う

@MainActor
final class LocationManager2: NSObject, ObservableObject {
    
    var locations: AsyncStream<CLLocationCoordinate2D> {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }
    
    func stopLocation() {
        locationManager.stopUpdatingHeading()
        continuation?.finish()
    }
    
    private var continuation: AsyncStream<CLLocationCoordinate2D>.Continuation? {
        didSet {
            continuation?.onTermination = { @Sendable [weak self] _ in
                self?.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    private let locationManager = CLLocationManager()
}

extension LocationManager2: CLLocationManagerDelegate {
    // do someting
}

// ここのところは深ぼって実装コードを書いてみると良さそう
// https://github.com/SatoTakeshiX/first-step-swift-concurrency/tree/main/AsyncSequence/AsyncSequence


// Task

