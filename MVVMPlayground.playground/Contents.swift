import UIKit
import PlaygroundSupport

/*
 MVVM 模式：
 VC --- 输入指令 ---> ViewModel
                       |
                       ↓
                        Model、数据处理
                       |
                       ↓
 VC <--- 输出指令 --- ViewModel
 */


// ViewModel 协议
public protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    func input(_ input:Input)
    var output:((Output)->Void)? { set get }
}

/// 基本输入指令
public enum InputType<I> {
    /// 请求数据 Bool 是否刷新
    case request(Bool)
    case put(I?)
}
/// 基本输出指令
public enum OutputType<O> {
    case loading(Any?)
    case loaded(Any?)
    case reload(Any?)
    case empty(Any?)
    case hud(Any?)
    case put(O?)
}





open class ViewModel: ViewModelProtocol {
    var _output:((Output)->Void)?
    
    public enum InputStyle {
        /// 请求数据 Bool 是否刷新
        case color
        case string
    }
    public enum OutputStyle {
        case color(UIColor)
        case string(String)
    }

    
    public typealias Input = InputType<InputStyle>
    public typealias Output = [OutputType<OutputStyle>]
    open func input(_ input: Input) {
        
    }
    public var output: ((Output) -> Void)? {
        get {
            return _output
        }
        set {
            _output = newValue
        }
    }
}


// 一个 Model
struct Model {
    var title = ""
}

// 一个 ViewModel
class ViewModelB: ViewModel {
    private var page = 1
    private var model = Model()
    
    override func input(_ input: ViewModel.Input) {
        print(input)
        switch input {
        case .request(let r):
            requestData(r)
        case .put(.color):
            let color = [UIColor.red, .green, .yellow, .brown, .blue, .cyan, .orange, .gray, .purple, .link][Int(arc4random() % 10)]
            _output?([.put(.color(color))])
        case .put(let c):
            print(c)
        }
    }
}

extension ViewModelB {
    func requestData(_ refresh:Bool) {
        let p = refresh ? 1 : page+1
        _output?([.loading(refresh ? "正在刷新" : "努力加载中...")])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.model.title = "数据 页数:\(p)"
            self.page = p
            self._output?([.loaded("已完成"), .reload(self.model)])
        })
    }
}
//  ViewModel 遵循 ViewModelProtocol 协议 提供 交换接口
extension ViewModelB {
    
    
}

// 一个 ViewController
class MyViewController : UIViewController {
    var vm:ViewModel? = ViewModelB()
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        let labelload = UILabel()
        labelload.frame = CGRect(x: 10, y: 100, width: 300, height: 30)
        labelload.text = ""
        labelload.textColor = .black
        view.addSubview(labelload)
        
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 150, width: 300, height: 30)
        label.text = "Hello World!"
        label.textColor = .black
        view.addSubview(label)
        
        for (i, item) in ["刷新", "加载更多", "更新颜色"].enumerated() {
            let button = UIButton(frame: CGRect(x: 10, y: 200 + i * 40, width: 200, height: 30))
            button.setTitle(item, for: .normal)
            button.backgroundColor = .red
            button.tag = 10 + i
            button.addTarget(self, action: #selector(clickButton(_ :)), for: .touchUpInside)
            view.addSubview(button)
        }
        self.view = view
        // ViewModel 输出
        vm?.output = { puts in
            puts.forEach { (put) in
                switch put {
                case .reload(let model):
                    guard let model = model as? Model else { break }
                    label.text = model.title
                case .put(.color(let col)):
                    label.backgroundColor = col
                case .loading(let str), .loaded( let str):
                    labelload.text = str as? String ?? ""
                default:
                    print(put)
                    break
                }
            }
        }
        vm?.input(.request(true))
    }
    @objc func clickButton(_ sender:UIButton) {
        // ViewModel 输入
        switch sender.tag {
        case 10:
            vm?.input(.request(true))
        case 11:
            vm?.input(.request(false))
        case 12:
            vm?.input(.put(.color))
        default:
            break
        }
    }
}
PlaygroundPage.current.liveView = MyViewController()
