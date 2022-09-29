//
//  File.swift
//  
//
//  Created by muze on 2022/09/05.
//

import Foundation
import UIKit
 
// chain
import Foundation

public class Chain<OriginType> {
    public var origin: OriginType
    
    public init(origin: OriginType) {
        self.origin = origin
    }
}

public protocol Chainable { }
extension Chainable {
     public var chain: Chain<Self> { // 타입은 나 자신의 타입, 즉 프로토콜 타입(==Chainable을 뜻함)
        return Chain(origin: self) // 나 자신instance를 넣는다.
    }
}
  
// uicontrol
import UIKit
  
public extension Chain where OriginType: UILabel {
    @discardableResult
    func text(_ text: String) -> Chain {
        origin.text = text
        return self
    }
    
    // 가장 많은 인자를 가져서 많이 안 쓸듯함.
    @discardableResult
    func attributedText(text: String, _ font: UIFont, _ color: UIColor, _ align: NSTextAlignment) -> Chain {
        let attr = text.attrbuted(font, color, align)
        origin.attributedText = attr
        return self
    }
   
    @discardableResult
    func attributedText(text: String, _ font: UIFont, _ color: UIColor) -> Chain {
        let attr = text.attrbuted(font, color)
        origin.attributedText = attr
        return self
    }
    
    @discardableResult
    func attributedText(_ attrStr: NSAttributedString) -> Chain {
        origin.attributedText = attrStr
        return self
    }
    
    @discardableResult
    func textColor(_ color: UIColor) -> Chain {
        origin.textColor = color
        return self
    }
    
    @discardableResult
    func font(_ fontName: UIFont) -> Chain {
        origin.font = fontName
        return self
    }
    
    @discardableResult
    func numOfLines(_ num: Int) -> Chain {
        origin.numberOfLines = num
        return self
    }
    
    @discardableResult
    func align(_ alignment: NSTextAlignment) -> Chain {
        origin.textAlignment = alignment
        return self
    }
   
}

public extension Chain where OriginType: UIButton {
    @discardableResult
    func title(_ title: String) -> Chain {
        origin.setTitle(title, for: .normal)
        return self
    }
    @discardableResult
    func text(_ text: String, state: UIControl.State = .normal) -> Chain {
        origin.setTitle(text, for: state)
        return self
    }
    @discardableResult
    func textColor(_ color: UIColor, state: UIControl.State = .normal) -> Chain {
        origin.setTitleColor(color, for: state)
        return self
    }
    
    @available(*, deprecated)
    func font(_ fontName: UIFont) -> Chain {
        origin.titleLabel?.font = fontName
        return self
    }
}

public extension Chain where OriginType: UITextField {
    
    @discardableResult
    func placeholder(_ text: String) -> Chain {
        origin.placeholder = text
        return self
    }
    
    @discardableResult
    func text(_ text: String) -> Chain {
        origin.text = text
        return self
    }
    
    @discardableResult
    func textColor(_ color: UIColor) -> Chain {
        origin.textColor = color
        return self
    }
    
    @discardableResult
    func font(_ fontName: UIFont) -> Chain {
        origin.font = fontName
        return self
    }
}

public extension Chain where OriginType: UISwitch {
    @discardableResult
    func setOn() -> Chain {
        origin.setOn(true, animated: true)
        return self
    }
    
    @discardableResult
    func setOff() -> Chain {
        origin.setOn(false, animated: true)
        return self
    }
      
}
 
public extension Chain where OriginType: UIStackView {
    
    @discardableResult
    func setVertical() -> Chain {
        origin.axis = .vertical
        return self
    }
    
    @discardableResult
    func setHorizontal() -> Chain {
        origin.axis = .horizontal
        return self
    }
    
    @discardableResult
    func spacing(_ space: CGFloat) -> Chain {
        origin.spacing = space
        return self
    }
    
    @discardableResult
    func align(_ align: UIStackView.Alignment) -> Chain {
        
        origin.alignment = align
        return self
    }
    
    @discardableResult
    func distribution(_ dist: UIStackView.Distribution) -> Chain {
        origin.distribution = dist
        return self
    }
    
    @discardableResult
    func addArrangedViews(_ views: [UIView]) -> Chain {
        views.forEach { origin.addArrangedSubview($0) }
        return self
    }
}

//
public extension Chain where OriginType: UILabel {
    @discardableResult
    func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> Chain {
        origin.font = UIFont.systemFont(ofSize: size, weight: weight)
        // origin.font = Spoqa.of(size: size, weight: weight)
        return self
    }
}
 
public extension Chain where OriginType: UIButton {
    @discardableResult
    func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> Chain {
        origin.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: weight)
        // origin.titleLabel?.font = Spoqa.of(size: size, weight: weight)
        return self
    }
}

public extension Chain where OriginType: UITextField {
    @discardableResult
    func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> Chain {
        origin.font = UIFont.systemFont(ofSize: size, weight: weight)
        // origin.font = Spoqa.of(size: size, weight: weight)
        return self
    }
}

public extension Chain where OriginType: UITextView {
    @discardableResult
    func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> Chain {
        origin.font = UIFont.systemFont(ofSize: size, weight: weight)
        // origin.font = Spoqa.of(size: size, weight: weight)
        return self
    }
}

// UIView
extension UIView: Chainable { }

// debug
public extension Chain where OriginType: UIView {
    // only for debug
    func debugBorder(_ color: UIColor = .red) -> Chain {
        origin.layer.borderWidth = 0.5
        origin.layer.borderColor = color.cgColor
        return self
    }
}

public extension Chain where OriginType: UIView {
    
    // MARK: 색상, 외곽선 설정
    @discardableResult
    func background(color: UIColor) -> Chain {
        origin.backgroundColor = color
        return self
    }
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Chain {
        origin.layer.cornerRadius = radius
        origin.clipsToBounds = true
        return self
    }
    @discardableResult
    func border(_ color: UIColor = .black, width: CGFloat = 1.0) -> Chain {
        origin.layer.borderWidth = width
        origin.layer.borderColor = color.cgColor
        return self
    }
    @discardableResult
    func tag(_ tagNum: Int) -> Chain {
        origin.tag = tagNum
        return self
    }
    
    // MARK: 하단 라인 그리기.
    @discardableResult
    func borderBottom(height: CGFloat = 1, color: UIColor = .black) -> Chain {
        // MARK: Setup Bottom-Border
        origin.translatesAutoresizingMaskIntoConstraints = false
        let bottomBorder = UIView(frame: .zero)
        bottomBorder.backgroundColor = color
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        origin.addSubview(bottomBorder)
        
        // MARK: Setup Anchors
        bottomBorder.bottomAnchor.constraint(equalTo: origin.bottomAnchor).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: origin.leftAnchor).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: origin.rightAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        return self
    }
    
    @discardableResult
    func height(_ height: CGFloat) -> Chain {
        origin.heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
}

public extension Chain where OriginType: UIView {
    @discardableResult
    func add(to parent: UIView) -> Chain {
        parent.addSubview(origin)
        return self
    }
}
 
// MARK: Chain - 오토레이아웃 - x y position or width/height
public extension Chain where OriginType: UIView {
    
    // swiftlint:disable identifier_name
    @discardableResult
    func autolayout(x: CGFloat, y: CGFloat) -> Chain {
        origin.autolayout(x: x, y: y)
        return self
    }
    
    @discardableResult
    func autolayout(width: CGFloat? = nil, height: CGFloat? = nil) -> Chain {
        origin.autolayout(width: width, height: height)
        return self
    }
    
    @discardableResult
    func autolayoutFull(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Chain {
        origin.autolayoutFull(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func autolayoutFullSafe(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Chain {
        origin.autolayoutFullSafe(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    func autolayoutHalf() -> Chain {
        origin.autolayoutHalf()
        return self
    }
}

// MARK: Chain - 오토레이아웃 - 좌우상하 Edge
public extension Chain where OriginType: UIView {
 
    /// 하단 anchor /  좌우는 붙임
    @discardableResult
    func autoBottomNSideSticky(height: CGFloat? = nil, bottomInset: CGFloat? = nil, sideSpacing: CGFloat = 0) -> Chain {
        origin.autoBottomNSideSticky(height: height, bottomInset: bottomInset, sideSpacing: sideSpacing)
        return self
    }
    /// 상단 anchor /  좌우는 붙임
    @discardableResult
    func autoTopNSideSticky(height: CGFloat? = nil, topInset: CGFloat? = nil, sideSpacing: CGFloat = 0) -> Chain {
        origin.autoTopNSideSticky(height: height, topInset: topInset, sideSpacing: sideSpacing)
        return self
    }
    
    /// 상단 anchor,  가로중앙정렬
    @discardableResult
    func autoCenter(width: CGFloat? = nil, height: CGFloat? = nil) -> Chain {
        origin.autoCenter(width: width, height: height)
        return self
    }
    /// 상단 anchor,  가로중앙정렬
    @discardableResult
    func autoTopXCenter(topInset: CGFloat = 0, height: CGFloat? = nil) -> Chain {
        origin.autoTopXCenter(topInset: topInset, height: height)
        return self
    }
    /// 하단 anchor,  가로중앙정렬
    @discardableResult
    func autoBottomXCenter(bottomInset: CGFloat = 0, height: CGFloat? = nil) -> Chain {
        origin.autoBottomXCenter(bottomInset: bottomInset, height: height)
        return self
    }
    /// 좌측  anchor,  아래위중앙
    @discardableResult
    func autoLeftYCenter(leftInset: CGFloat = 0, width: CGFloat? = nil) -> Chain {
        origin.autoLeftYCenter(leftInset: leftInset, width: width)
        return self
    }
    /// 우측 anchor,  아래위중앙
    @discardableResult
    func autoRightYCenter(rightInset: CGFloat = 0, width: CGFloat? = nil) -> Chain {
        origin.autoRightYCenter(rightInset: rightInset, width: width)
        return self
    }
    
    /// 구석
    @discardableResult
    func autoEdge(top: CGFloat, left: CGFloat) -> Chain {
        origin.autoEdge(top: top, left: left)
        return self
    }
    /// 구석
    @discardableResult
    func autoEdge(top: CGFloat, right: CGFloat) -> Chain {
        origin.autoEdge(top: top, right: right)
        return self
    }
    /// 구석
    @discardableResult
    func autoEdge(bottom: CGFloat, left: CGFloat) -> Chain {
        origin.autoEdge(bottom: bottom, left: left)
        return self
    }
    /// 구석
    @discardableResult
    func autoEdge(bottom: CGFloat, right: CGFloat) -> Chain {
        origin.autoEdge(bottom: bottom, right: right)
        return self
    }
}

// MARK: UIView - x y position or width/height

public extension UIView {
    // swiftlint:disable identifier_name
    func autolayout(x: CGFloat? = nil, y: CGFloat? = nil) {
        let origin = self
        guard let superView = origin.superview else {
            fatalError("add to superview first")
        }
        origin.translatesAutoresizingMaskIntoConstraints = false
        
        let xAxis = x ?? 0
        let yAxis = y ?? 0
        
        let edges: [NSLayoutConstraint] = [
            origin.topAnchor.constraint(equalTo: superView.topAnchor, constant: yAxis),
            origin.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: xAxis)
            
        ]
        
        NSLayoutConstraint.activate(edges)
       
    }
    func autolayout(width: CGFloat? = nil, height: CGFloat? = nil) {
        let origin = self
        guard origin.superview != nil else {
            fatalError("add to superview first")
        }
        origin.translatesAutoresizingMaskIntoConstraints = false
        
        let width = width ?? 0
        let height = height ?? 0
        
        let edges: [NSLayoutConstraint] = [
            origin.widthAnchor.constraint(equalToConstant: width),
            origin.heightAnchor.constraint(equalToConstant: height)
        ]
        
        NSLayoutConstraint.activate(edges)
 
    }
    
    func autolayoutFull(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let edges: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: superView.topAnchor, constant: top),
            leftAnchor.constraint(equalTo: superView.leftAnchor, constant: left),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -bottom),
            rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -right)
        ]
        
        NSLayoutConstraint.activate(edges)
    }
    
    func autolayoutFullSafe(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        
        guard #available(iOS 11, *) else {
            return
        }
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let edges: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: top),
            leftAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leftAnchor, constant: left),
            bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor, constant: -bottom),
            rightAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.rightAnchor, constant: -right)
        ]
        
        NSLayoutConstraint.activate(edges)
    }
    
    func autolayoutHalf() {
        let origin = self
        guard let superView = origin.superview else {
            fatalError("add to superview first")
        }
        origin.translatesAutoresizingMaskIntoConstraints = false
        
        let edges: [NSLayoutConstraint] = [
            origin.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: 0.5),
            origin.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: 0.5),
            origin.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            origin.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(edges)
        
    }
}

// MARK: UIView - stick to top, bottom / Edge
public extension UIView {
    private func assertUnlessUIViewHasHeight(height: CGFloat?) {
        let hasIntrisicViewTypes = [UILabel.self, UIButton.self, UITextView.self, UITextField.self, UIStackView.self, UISlider.self, UISwitch.self]
        
        if hasIntrisicViewTypes.contains(where: { self.isKind(of: $0) }) {
            print("UIView class checked okay")
            
        } else {
            // 일반 uiview인 경우 진입함. 이 경우 height/높이가 있어야 함.
            if height == nil {
                assert(false, "plain uiview should have height, this type is \(self.classForCoder)")
            }
        }
    }
    /// 상단 anchor /  좌우는 붙임
    func autoTopNSideSticky(height: CGFloat? = nil, topInset: CGFloat? = nil, sideSpacing: CGFloat = 0) {
        // assertUnlessUIViewHasHeight(height: height)
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        var edges = [NSLayoutConstraint]()
        if let height = height {
            edges.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        let topPadding = topInset ?? 0
        edges.append(topAnchor.constraint(equalTo: superView.topAnchor, constant: topPadding))
     
        edges.append(leftAnchor.constraint(equalTo: superView.leftAnchor, constant: sideSpacing))
        edges.append(rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -sideSpacing))
        
        NSLayoutConstraint.activate(edges)
    }
    /// 하단 anchor /  좌우는 붙임
    func autoBottomNSideSticky(height: CGFloat? = nil, bottomInset: CGFloat? = nil, sideSpacing: CGFloat = 0) {
        // FIXME: Height could be nil
        // assertUnlessUIViewHasHeight(height: height)
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
 
        var edges = [NSLayoutConstraint]()
        if let height = height {
            edges.append(heightAnchor.constraint(equalToConstant: height))
        }
       
        let bottomPadding = bottomInset ?? 0
        edges.append(bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -bottomPadding))
        edges.append(leftAnchor.constraint(equalTo: superView.leftAnchor, constant: sideSpacing))
        edges.append(rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -sideSpacing))
        
        NSLayoutConstraint.activate(edges)
    }
    
    /// 정중앙
    func autoCenter(width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        var edges = [NSLayoutConstraint]()
          
        if let width = width {
            edges.append(widthAnchor.constraint(equalToConstant: width))
        }
        if let height = height {
            edges.append(heightAnchor.constraint(equalToConstant: height))
        }
        edges.append(centerXAnchor.constraint(equalTo: superView.centerXAnchor))
        edges.append(centerYAnchor.constraint(equalTo: superView.centerYAnchor))
        
        NSLayoutConstraint.activate(edges)
    }
    
    /// 상단 anchor,  가로중앙정렬
    func autoTopXCenter(topInset: CGFloat = 0, height: CGFloat? = nil) {
        // FIXME: Height could be nil
        // assertUnlessUIViewHasHeight(height: height)
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        var edges = [NSLayoutConstraint]()
         
        if let height = height {
            edges.append(heightAnchor.constraint(equalToConstant: height))
        }
          
        edges.append(topAnchor.constraint(equalTo: superView.topAnchor, constant: topInset))
        edges.append(centerXAnchor.constraint(equalTo: superView.centerXAnchor))
        
        NSLayoutConstraint.activate(edges)
    }
    /// 하단 anchor,  가로중앙정렬
    func autoBottomXCenter(bottomInset: CGFloat = 0, height: CGFloat? = nil) {
        assertUnlessUIViewHasHeight(height: height)
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        var edges = [NSLayoutConstraint]()
         
        if let height = height {
            edges.append(heightAnchor.constraint(equalToConstant: height))
        }
          
        edges.append(bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -bottomInset))
        edges.append(centerXAnchor.constraint(equalTo: superView.centerXAnchor))
        
        NSLayoutConstraint.activate(edges)
    }
    /// 좌측  anchor,  아래위중앙
    func autoLeftYCenter(leftInset: CGFloat = 0, width: CGFloat? = nil) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        var edges = [NSLayoutConstraint]()
         
        if let width = width {
            edges.append(widthAnchor.constraint(equalToConstant: width))
        }
          
        edges.append(leftAnchor.constraint(equalTo: superView.leftAnchor, constant: leftInset))
        edges.append(centerYAnchor.constraint(equalTo: superView.centerYAnchor))
        
        NSLayoutConstraint.activate(edges)
    }
    /// 우측 anchor,  아래위중앙
    func autoRightYCenter(rightInset: CGFloat = 0, width: CGFloat? = nil) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        var edges = [NSLayoutConstraint]()
         
        if let width = width {
            edges.append(widthAnchor.constraint(equalToConstant: width))
        }
          
        edges.append(rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -rightInset))
        edges.append(centerYAnchor.constraint(equalTo: superView.centerYAnchor))
        
        NSLayoutConstraint.activate(edges)
    }
    
    func autoEdge(top: CGFloat, left: CGFloat) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let edges: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: superView.topAnchor, constant: top),
            leftAnchor.constraint(equalTo: superView.leftAnchor, constant: left)
        ]
        
        NSLayoutConstraint.activate(edges)
    }
    func autoEdge(top: CGFloat, right: CGFloat) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let edges: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: superView.topAnchor, constant: top),
            rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -right)
        ]
        
        NSLayoutConstraint.activate(edges)
    }
    func autoEdge(bottom: CGFloat, left: CGFloat) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let edges: [NSLayoutConstraint] = [
            
            leftAnchor.constraint(equalTo: superView.leftAnchor, constant: left),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -bottom)
             
        ]
        
        NSLayoutConstraint.activate(edges)
    }
    func autoEdge(bottom: CGFloat, right: CGFloat) {
        guard let superView = self.superview else {
            fatalError("add to superview first")
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        let edges: [NSLayoutConstraint] = [
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -bottom),
            rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -right)
        ]
        
        NSLayoutConstraint.activate(edges)
    }
}

// FIXME: attributed string
public extension String {
     
    func attributed() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func attrbuted(_ font: UIFont, _ color: UIColor) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func attrbuted(_ font: UIFont, _ color: UIColor, _ align: NSTextAlignment) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func attrbuted(_ font: UIFont, _ color: UIColor, _ align: NSTextAlignment, _ lineHeight: CGFloat) -> NSMutableAttributedString {
        
        return NSMutableAttributedString(string: self)
    }
}

// UIView + Extensions

public extension UIView {
   func setBorder(color: UIColor?, width: CGFloat) {
       borderColor = color
       borderWidth = width
   }
}
public extension UIView {
   var cornerRadius: CGFloat {
       get {
           return layer.cornerRadius
       }
       set {
           layer.cornerRadius = newValue
           layer.masksToBounds = newValue > 0
       }
   }
   
   var borderWidth: CGFloat {
       get {
           return layer.borderWidth
       }
       set {
           layer.borderWidth = newValue
       }
   }
   
   var borderColor: UIColor? {
       get {
           let color = UIColor(cgColor: layer.borderColor!)
           return color
       }
       set {
           layer.borderColor = newValue?.cgColor
       }
   }
}
public extension UIImage {
   convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
       let rect = CGRect(origin: .zero, size: size)
       UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
       color.setFill()
       UIRectFill(rect)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       guard let cgImage = image?.cgImage else { return nil }
       self.init(cgImage: cgImage)
   }
   
   static func makeDot(_ size: CGFloat) -> UIImage {
       let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
       let img = renderer.image { ctx in
           ctx.cgContext.setFillColor(UIColor.red.cgColor)
           ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
           ctx.cgContext.setLineWidth(10)

           let rectangle = CGRect(x: 0, y: 0,
                                  width: size, height: size)
           ctx.cgContext.addEllipse(in: rectangle)
           ctx.cgContext.drawPath(using: .fillStroke)
       }
       return img
   }
   
   static func makeRadioDot(_ size: CGFloat) -> UIImage {
       let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
       let img = renderer.image { ctx in
           ctx.cgContext.setFillColor(UIColor.gray.cgColor)
           ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
           ctx.cgContext.setLineWidth(8)

           let rectangle = CGRect(x: 0, y: 0,
                                  width: size, height: size)
           ctx.cgContext.addEllipse(in: rectangle)
           ctx.cgContext.drawPath(using: .fillStroke)
       }
       return img
   }
}
