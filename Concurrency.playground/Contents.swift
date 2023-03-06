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

// PlaygroundPage.current.setLiveView(AsyncStreamView())

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


/*
 Task
 
 並行処理をTaskという単位で実行する
 全ての非同期関数はTaskを通して実行される
 
タスクに以下がある
 
 - Structured Concurrency(構造化された並行性)
 　- キャンセル処理をある程度自動で行なってくれる
 　-　動作の正しさをSwift Concurrencyに委ねられる
 - Unstructurd Concurrency(構造化されていない並行性)
 　- 開発者がマニュアルで操作する
 　- コードの正しさも開発者が保証しなければいけない
 
*/

/*
 Structured Concurrency
 - 近年話題になっているプログラミングパラダイムの一 種
 - Structuredという言葉は　Structured　programming
 - 現代的なプログラミング言語では当たり前に備わっている、プログラミングに if 文や for 文などの制御構文を導入して、
 　変数や関数がブ ロックのスコープを超えてアクセスできないようにするプログラミングのパラダイムのこと
 
 - タスクの生存期間がスコープを超えて生存しないような作りになっている
 - 重要なのはタスクグループと async let バインディング
 
 
 */



/*
 
 タスクツリー
 
 タスクツリーは複数のタスクを親子関係で構造化し、従来よりも優先度やキャンセルの制御を簡潔に表すことができます。
 親タスクの下に子タスクがあり、その下に孫タスクといったようにタスクを階層化します。
 一番下の階層のタスクがすべて完了したら上位のタスクが実行されます。
 それを繰り返し、最終的にすべての子タスクが完了すると、親タスクが自分のタスクを実行するのです。
 言い換えると、親タスクの関数やメソッドは子タスクの処理が完了するまでリターンしません。
 
 
 もしも下位のタスクのひとつにエラーが起こると、自動的に同じ階層の他のタスクはキャンセルされたものとしてマークされます。
 ただし、このマークはタスクが不要になったことを示すだけで、タスクの処理は停止せずに継続されます。
 実際にタスクをキャンセルし、処理を止めるには CancellationError というエラーをスローしなければいけません。
 タスクがキャンセルされると、その子孫タスクは自動的にキャンセルされます。
 子タスクがすべてエラーやキャンセルでタスクが完了すると、親タスクにエラーが伝播します。
 親タスクはエラーをスローして終了します。
 
 
 */


/* タスクグループ
 
 - Structured Concurrency の一種
 - タスクグループはタスクのグループに対して子タスクを追加することで簡単に並列処理を実行できる
 - タスクの生存期間はタスクグループのスコープ内に閉じ込められており、タスクツリーが形成される
 
 - withTaskGroup
 - withThrowingTaskGroup
 
 */



// Errorなし

// 通信している想定としての疑似Code
struct Util {
    
    static func wait(seonds: UInt64) async {
        // タスクが時間終了前にキャンセルされた場合、この関数はCancellationErrorを投げる。
        // 途中でキャンセルされたら途中で終了する
        try? await Task.sleep(nanoseconds: seonds * NSEC_PER_SEC)
    }
}


struct MypageInfo {
    let friends: [String]
    let airticleTitles: [String]
    
}


class SampleClass  {
    // 友達一覧を取得
    private func fetchFriends() async -> [String] {
        await Util.wait(seonds: 3)
        return ["Aris", "Bob", "Cooper"]
    }
    
    // Errorを返す
    private func fetchFriendsFromLocalDB() async throws -> [String] {
        await Util.wait(seonds: 1)
        throw SampleError()
    }
    
    
    // 投稿記事のタイトル一覧
    private func fetchAirticleTitles() async -> [String] {
        await Util.wait(seonds: 1)
        return ["猫を飼い始めました", "名前はココア", "仕事の邪魔をするココア"]
    }
    
    
    // 二つのAPIから必要なデータを取得する
    // 親タスク
    func fetchMypageData() async -> MypageInfo {
        
        var friends: [String] = []
        var airticles: [String] = []
        
        // 子タスクの方を定義
        enum FetchType {
            case friends([String])
            case airticles([String])
        }
        
        // ofで子タスクが返す型を設定
        await withTaskGroup(of: FetchType.self, body: { group in
            // 子タスクの作成
            group.addTask { [weak self] in
                let friends = await self?.fetchFriends() ?? []
                return FetchType.friends(friends)
            }
            
            // 子タスクの作成
            group.addTask { [weak self] in
                let airticles = await self?.fetchAirticleTitles() ?? []
                return FetchType.airticles(airticles)
            }
            
            // 子タスクの結果を取得
            for await fetchResult in group {
                switch fetchResult {
                case .friends(let value):
                    friends = value
                case .airticles(let value):
                    airticles = value
                }
            }
            
            // 取得する方法はnext()を呼ぶ方法がある
            // next()を使うことによってタスクごとに柔軟に結果を制御できる
            // APIのレスポンスによって他の子タスクの処理をキャンセルするとかができる
            
            // 最初に終わったタスク結果を取得する
            guard let firstResult = await group.next() else {
                group.cancelAll()
                return
            }
            
            // 最初の結果を見て必要ならキャンセルできる
            // group.cancelAll()
            // ただしキャンセルのチェックをしなければ子タスクの処理は続いてしまうので注意が必要
            
            switch firstResult {
            case .airticles(let a):
                print(a)
                
            case .friends(let f):
                print(f)
            }
        })
        
        
        return MypageInfo(friends: friends, airticleTitles: airticles)
    }
    
    // 並列処理を動的に実行する
    // 友達のアバター画像を友達のIDをもとに取得する
    func fetchFriendsAvators(ids: [String]) async -> [String: UIImage?] {
        return await withTaskGroup(of: (String, UIImage?).self) { group in
            for id in ids {
                group.addTask { [weak self] in
                    return (id, await self?.fetchAvatorImage(id: id))
                }
            }
            
            var avators: [String: UIImage?] = [:]
            for await (id, image) in group {
                avators[id] = image
            }
            return avators
        }
    }
    
    func fetchAvatorImage(id: String) async -> UIImage? {
        return nil
    }
    
}

extension SampleClass {
    
    struct SampleError: Error {
        
        init() {
            print("Errorです")
        }
    }
    
    /*
     
     withThrowingTaskGroup関数を利用してエラーが発生するタスクを タスクツリーとして実行することができます。
     ただし、注意としてgroupインスタンスに対して for try await in ループを回すか next メソッドを呼び出さないとエラーが親タスクに伝播しないので、
     子タスクの結果の収集は忘れずに行う
     
     */
    
    func fetchAllFriends() async throws -> [String] {
        return try await withThrowingTaskGroup(of: [String].self, body: { group in
            // Errorをthrowできる
            group.addTask { [weak self] in
                guard let self else { throw SampleError() }
                
                return await self.fetchFriends()
            }
            
            group.addTask { [weak self] in
                guard let self else { throw SampleError() }
                
                // Errorが発生する
                return try await self.fetchFriendsFromLocalDB()
            }
            
            var allFriends: [String] = []
            
            for try await friends in group {
                allFriends.append(contentsOf: friends)
            }
            
            return allFriends
        })
    }
    
    func showAllFriends() {
        Task {
            do {
                let friends = try await fetchAllFriends()
                print(friends)
            } catch {
                // fetchFriendsFromLocalDBのエラーを呼び出し元でキャッチする。
                print("error::::", error.localizedDescription)
            }
        }
    }
}

let sample = SampleClass()

Task {
    sample.fetchMypageData
}


sample.showAllFriends()

// 協調的なキャンセル

/*
 ## キャンセル方法とキャンセルをチェックする方法
 - CancellationError タスクをキャンセルする
 - Task.checkCancellation キャンセルマークが付けられた場合にCancellationErrorをスローする
 - Task.isCancelled タスクがキャンセルマークつけられたかを判別する
 
 */


// Task.checkCancellation
// 現在のタスクがキャンセルマークが付けられているかどうかを確認する方法の一つ
// 現在のタスクがキャンセルマークをつけられた場合にCancellationErrorをスローする
//


class CancellationSample {
    
    func veryLongTask() async {
        try? await Task.sleep(nanoseconds: 10 * NSEC_PER_SEC)
    }
    
    func fetchDataWithLongTask() async throws -> [String] {
        return try await withThrowingTaskGroup(of: [String].self) { group in
            group.addTask { [weak self] in
                // 現在のタスクにキャンセルチェックがついているか
                // ついていたらキャンセルする
                // ついていなかったらキャンセルしない
                try Task.checkCancellation()
                
                // とても重い処理
                await self?.veryLongTask()
                return ["a", "b"]
            }
            
            // 明示的にキャンセルを行う
            group.cancelAll()
            
            var alldata: [String] = []
            
            for try await data in group {
                alldata = data
            }
            return alldata
        }
    }
}


let cancellationSample = CancellationSample()

Task {
    do {
        let result = try await cancellationSample.fetchDataWithLongTask()
        print(result)
    } catch {
        // Errorが来る
        print("10秒待たずにErrorになる", error.localizedDescription)
    }
}

// Task.isCancelled
// 現在のタスクがキャンセルされたものとしてのマークがついているかどうかを確認する
// Task.checkCancellation() は CancellationErrorをスローするだけだが、独自のキャンセル処理をしたい場合に私用する


extension CancellationSample {
    
    func fetchImage(with id: String) async -> UIImage {
           try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
           return UIImage()
       }
    
    func fetchIconsWithLongTask(ids: [String]) async throws -> [UIImage] {
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            for id in ids {
                // もしキャンセルしたらブレイクしてループを抜ける
                if Task.isCancelled { break }
                group.addTask {
                    return await self.fetchImage(with: id)
                }
            }
            
            var icons: [UIImage] = []
            for try await image in group {
                // キャンセルされたらそこまで取得した画像を渡せる
                icons.append(image)
            }
            return icons
        }
    }
}

// 4.6.3 キャンセルチェックの有無と実行時間
