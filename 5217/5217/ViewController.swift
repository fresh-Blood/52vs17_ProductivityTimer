//
//  ViewController.swift
//  5217
//
//  Created by Admin on 13.12.2021.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {

    lazy var totalSecondsOfWork = 0
    lazy var totalSecondsOfRelaxation = 0
    var counter: Int = 0 {
        didSet {
            counter == 0 ? startWorking() : startRelaxing()
        }
    }
    weak var timer: Timer?
    lazy var utterenceArr52: [AVSpeechUtterance] = [
        AVSpeechUtterance(string: "52 минуты усиленной работы, время пошло!"),
        AVSpeechUtterance(string: "Ярослав, пора поработать, вперед за знаниями. Это самая ценная инвестиция твоего времени."),
        AVSpeechUtterance(string: "Наша цель - стать сеньор девелопером и великим разработчиком. 52 минуты интесивной работы время пошло!"),
        AVSpeechUtterance(string: "Продуктивность это важно.Время работать - вперед! Пришло время покорить новые вершины!")
    ]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        stackViewWork.addArrangedSubview(workNameLabel)
        stackViewWork.addArrangedSubview(workStatusLabel)
        stackViewRelaxation.addArrangedSubview(relaxationNameLabel)
        stackViewRelaxation.addArrangedSubview(relaxationStatusLabel)
        view.addSubview(stackViewWork)
        view.addSubview(stackViewRelaxation)
        
        _ = utterenceArr52.map{
            $0.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        }
        _ = utterenceArr17.map{
            $0.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        counter = 0
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.synthesizer.speak((self?.utterenceArr52.randomElement()!)!)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let inset: CGFloat = 20
        stackViewWork.frame = CGRect(x: view.bounds.minX + inset*2, y: view.bounds.height/4, width: view.bounds.width - inset*4, height: view.bounds.height/5)
        stackViewWork.layer.cornerRadius = stackViewWork.bounds.height/2
        stackViewRelaxation.frame = CGRect(x: view.bounds.minX + inset*2, y: view.bounds.height/2, width: view.bounds.width - inset*4, height: view.bounds.height/5)
        stackViewRelaxation.layer.cornerRadius = stackViewWork.bounds.height/2
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

