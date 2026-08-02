//
//  UColorViewController.swift
//  
//
//  Created by muze on 2022/12/07.
//

#if canImport(UIKit)
import UIKit

public class UColorViewController: UIViewController {

    public let backColor: UIColor
    
    required init(backColor: UIColor) {
        self.backColor = backColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backColor
    }
}
#endif
