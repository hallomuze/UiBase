//
//  File.swift
//  
//
//  Created by muze on 2022/09/29.
//
 
import UIKit
import UiBase

class TViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        common()
    }

    func common() {
        let label = UILabel()
        label.setBorder(color: .blue, width: 3)
        label.cornerRadius = 10
        label.text = "ssss"
        label.frame = CGRect(x: 100, y: 100, width: 100, height: 20)
        self.view.addSubview(label)
        label.lets {
            $0.text = "kkkk"
        }
        
        let btn = UIButton()
         
        btn.chain
            .add(to: self.view)
            .text("hahaha")
            .background(color: .brown)
            .autoLeftYCenter()
        
        let chainedLabel = UILabel()
         
        chainedLabel.chain
            .add(to: self.view)
            .text("hahaha")
            .background(color: .brown)
            .autoLeftYCenter()
    }

}
