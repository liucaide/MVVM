import UIKit
import PlaygroundSupport

// ViewModel 协议
protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    func input(_ input:Input)
    var output:((Output)->Void)? { set get }
}

// 一个 Model
struct Model {
    var title = ""
}

// 一个 ViewModel
class ViewModel {
    var page = 1
    var model = Model()
    private var _output:((Output)->Void)?
}
extension ViewModel {
    enum InputType {
        case request(Bool)
        case color
    }
    
    enum OutputType{
        case loading(String)
        case loaded(String)
        case reload(Model)
        case color(UIColor)
    }
}
extension ViewModel {
    func requestData(_ refresh:Bool) {
        let p = refresh ? 1 : page+1
        _output?([.loading(refresh ? "正在刷新" : "努力加载中...")])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {[weak self] in
            self?.model.title = "数据 页数:\(p)"
            self?.page = p
            self?._output?([.loaded("已完成"), .reload(self!.model)])
        })
    }
}
//  ViewModel 遵循 ViewModelProtocol 协议 提供 交换接口
extension ViewModel: ViewModelProtocol {
    typealias Input = InputType
    typealias Output = [OutputType]
    
    func input(_ input: Input) {
        switch input {
        case .request(let r):
            requestData(r)
        case .color:
            let color = [UIColor.red, .green, .yellow, .brown, .blue, .cyan, .orange, .gray, .purple, .link][Int(arc4random() % 10)]
            _output?([.color(color)])
        }
    }
    var output: ((Output) -> Void)? {
        get {
            return _output
        }
        set {
            _output = newValue
        }
    }
}

// 一个 ViewController
class MyViewController : UIViewController {
    var vm = ViewModel()
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
        
        do{
            let button = UIButton(frame: CGRect(x: 10, y: 200, width: 200, height: 30))
            button.setTitle("刷新", for: .normal)
            button.backgroundColor = .lightGray
            button.tag = 10
            button.addTarget(self, action: #selector(clickButton(_ :)), for: .touchUpInside)
            view.addSubview(button)
        }
        do{
            let button = UIButton(frame: CGRect(x: 10, y: 240, width: 200, height: 30))
            button.setTitle("加载更多", for: .normal)
            button.backgroundColor = .lightGray
            button.tag = 11
            button.addTarget(self, action: #selector(clickButton(_ :)), for: .touchUpInside)
            view.addSubview(button)
        }
        do{
            let button = UIButton(frame: CGRect(x: 10, y: 280, width: 200, height: 30))
            button.setTitle("更新颜色", for: .normal)
            button.backgroundColor = .lightGray
            button.tag = 12
            button.addTarget(self, action: #selector(clickButton(_ :)), for: .touchUpInside)
            view.addSubview(button)
        }
        
        self.view = view
        // ViewModel 输出
        vm.output = { puts in
            puts.forEach { (put) in
                switch put {
                case .reload(let model):
                    label.text = model.title
                case .color(let col):
                    label.backgroundColor = col
                case .loading(let str):
                    labelload.text = str
                case .loaded( let str):
                    labelload.text = str
                }
            }
            
        }
        vm.input(.request(true))
    }
    @objc func clickButton(_ sender:UIButton) {
        // ViewModel 输入
        switch sender.tag {
        case 10:
            vm.input(.request(true))
        case 11:
            vm.input(.request(false))
        case 12:
            vm.input(.color)
        default:
            break
        }
    }
}
PlaygroundPage.current.liveView = MyViewController()
