import UIKit
import AVFoundation

final class ViewController: UIViewController {

    lazy var totalSecondsOfWork = 0
    lazy var totalSecondsOfRelaxation = 0
    private var counter: Int = 0
    {
        didSet {
            counter == 0 ? startWorking() : startRelaxing()
        }
    }
    weak var timer: Timer?
    
    // MARK: work messages array you can set your own of course 
    lazy var utterenceArr52: [AVSpeechUtterance] = [
        AVSpeechUtterance(string: "52 минуты усиленной работы, время пошло!"),
        AVSpeechUtterance(string: "Ярослав, пора поработать, вперед за знаниями. Это самая ценная инвестиция твоего времени."),
        AVSpeechUtterance(string: "Наша цель - стать сеньор девелопером и великим разработчиком. 52 минуты интесивной работы время пошло!"),
        AVSpeechUtterance(string: "Продуктивность это важно.Время работать - вперед! Пришло время покорить новые вершины!")
    ]
    // MARK: rest messages array
    lazy var utterenceArr17: [AVSpeechUtterance] = [
        AVSpeechUtterance(string: "Поработал, теперь можно и перерыв сделать - 17 минут, время пошло! Необходимо дать отдохнуть глазам."),
        AVSpeechUtterance(string: "Настало время отдохнуть, 17 минут пошли!"),
        AVSpeechUtterance(string: "Какой ты молодец, можешь теперь отдохнуть мой повелитель"),
        AVSpeechUtterance(string: "Ярослав, супер, пора сделать перерыв")
    ]
    lazy var synthesizer = AVSpeechSynthesizer()
    
    private let workNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.text = "Общее время работы:"
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.1
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return lbl
    }()
    
    private let relaxationNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.text = "Общее время отдыха:"
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.1
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return lbl
    }()
    
    private let workStatusLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.numberOfLines = 0
        lbl.text = "0"
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        return lbl
    }()
    
    private let relaxationStatusLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.layer.masksToBounds = true
        lbl.numberOfLines = 0
        lbl.text = "0"
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        return lbl
    }()
    
    private let stackViewWork: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .systemOrange
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    private let stackViewRelaxation: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .systemOrange
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    private let startButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Start",
                     for: .normal)
        btn.setTitleColor(.black,
                          for: .normal)
        btn.backgroundColor = .systemOrange
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return btn
    }()
    
    private func setTapPoliticsForStartButton() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(tapStart))
        gesture.minimumPressDuration = 0
        startButton.addGestureRecognizer(gesture)
    }
    @objc private func tapStart(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            startButton.layer.borderWidth = 1.0
            startButton.backgroundColor = .systemYellow
            counter = 0
            DispatchQueue.global(qos: .utility).async { [weak self] in
                self?.synthesizer.speak((self?.utterenceArr52.randomElement()!)!)
            }
        } else {
            startButton.layer.borderWidth = 5.0
            startButton.backgroundColor = .systemOrange
        }
    }
    
    private let stopButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Stop",
                     for: .normal)
        btn.setTitleColor(.black,
                          for: .normal)
        btn.backgroundColor = .systemOrange
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return btn
    }()
    
    private func setTapPoliticsForStopButton() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(tapStop))
        gesture.minimumPressDuration = 0
        stopButton.addGestureRecognizer(gesture)
    }
    @objc private func tapStop(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            stopButton.layer.borderWidth = 1.0
            stopButton.backgroundColor = .systemYellow
            timer?.invalidate()
            workStatusLabel.text = "0"
            relaxationStatusLabel.text = "0"
            totalSecondsOfWork = 0
            totalSecondsOfRelaxation = 0
        } else {
            stopButton.layer.borderWidth = 5.0
            stopButton.backgroundColor = .systemOrange
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTapPoliticsForStartButton()
        setTapPoliticsForStopButton()
        view.backgroundColor = .black
        stackViewWork.addArrangedSubview(workNameLabel)
        stackViewWork.addArrangedSubview(workStatusLabel)
        stackViewRelaxation.addArrangedSubview(relaxationNameLabel)
        stackViewRelaxation.addArrangedSubview(relaxationStatusLabel)
        view.addSubview(stackViewWork)
        view.addSubview(stackViewRelaxation)
        view.addSubview(startButton)
        view.addSubview(stopButton)
        
        _ = utterenceArr52.map{
            $0.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        }
        _ = utterenceArr17.map{
            $0.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let inset: CGFloat = 20
        stackViewWork.frame = CGRect(x: view.bounds.minX + inset*2,
                                     y: view.bounds.height/6,
                                     width: view.bounds.width - inset*4,
                                     height: view.bounds.height/6)
        stackViewWork.layer.cornerRadius = stackViewWork.bounds.height/2
        stackViewRelaxation.frame = CGRect(x: view.bounds.minX + inset*2,
                                           y: view.bounds.height/3 + inset,
                                           width: view.bounds.width - inset*4,
                                           height: view.bounds.height/6)
        stackViewRelaxation.layer.cornerRadius = stackViewWork.bounds.height/2
        startButton.frame = CGRect(x: view.bounds.width/4 + view.safeAreaInsets.left - inset,
                                   y: view.bounds.height/6*4 - inset*2,
                                   width: view.bounds.width/4,
                                   height: view.bounds.width/4)
        startButton.layer.cornerRadius = startButton.bounds.height/2
        startButton.layer.borderWidth = 5.0
        stopButton.frame = CGRect(x: view.bounds.width/2 + inset - view.safeAreaInsets.left,
                                   y: view.bounds.height/6*4 - inset*2,
                                   width: view.bounds.width/4,
                                  height: view.bounds.width/4)
        stopButton.layer.cornerRadius = stopButton.bounds.height/2
        stopButton.layer.borderWidth = 5.0
    }
    
    private func startWorking() {
        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(self.start),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    @objc private func start() {
        totalSecondsOfWork += 1
        if totalSecondsOfWork % 3120 == 0 {
            self.counter = 1
            synthesizer.speak(utterenceArr17.randomElement()!)
        } else {
            self.counter = 0
        }
        workStatusLabel.pulsate()
        self.workStatusLabel.text = String(totalSecondsOfWork).presentInHoursAndMinutes()
    }
    
    private func startRelaxing() {
        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(self.startRelax),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    @objc private func startRelax() {
        totalSecondsOfRelaxation += 1
        if totalSecondsOfRelaxation % 1020 == 0 {
            self.counter = 0
            synthesizer.speak(utterenceArr52.randomElement()!)
        } else {
            self.counter = 1
        }
        relaxationStatusLabel.pulsate()
        self.relaxationStatusLabel.text = String(totalSecondsOfRelaxation).presentInHoursAndMinutes()
    }
}

extension UILabel {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.1
        pulse.fromValue = 0.98
        pulse.toValue = 1.1
        pulse.damping = 1.1
        layer.add(pulse, forKey: nil)
    }
}
// MARK: "translating" into hours : minutes : seconds view as we need to display
extension String {
    func presentInHoursAndMinutes() -> String {
        var hours = 0
        var minutes = 0 {
            didSet {
                if minutes >= 60 {
                    hours = minutes / 60
                    minutes = minutes % 60
                }
            }
        }
        var seconds = 0
        minutes = Int(String(String((Int(self) ?? 0) / 60).drop(while: { character in
            character == "."
        }))) ?? 0
        seconds = (Int(self) ?? 0) % 60
        return "\(hours)ч : \(minutes)мин : \(seconds)с"
    }
}

