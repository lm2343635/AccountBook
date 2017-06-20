//
//  JSONFormatter.swift
//  AccountBook
//
//  Created by lidaye on 20/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import UIKit
import M80AttributedLabel

enum PrettyColor: Int {
    case normal = 0x888888
    case key = 0xFF9999
    case value = 0x33CCFF
}

let symbols = ["{", "}", "[", "]", ":", ","]

@objc class JSONFormatter: NSObject {
    
    class func prettyViewIn(_ parentView: UIView, message: String) -> UIScrollView {
        let prettyLabel = M80AttributedLabel()
        
        var space = String()
        var color = RGB(PrettyColor.normal.rawValue)
        var isText = false
        for char in message.characters {
            let text: String
            switch char {
            case "\"":
                isText = !isText
                text = "\(char)"
            case "{":
                color = RGB(PrettyColor.key.rawValue)
                fallthrough
            case "[":
                space.append("  ")
                text = "\(char)\n\(space)"
            case ",":
                text = "\(char)\n\(space)"
                color = RGB(PrettyColor.key.rawValue)
            case "}":
                fallthrough
            case "]":
                space = space.substring(to: space.index(space.endIndex, offsetBy: -2))
                text = "\n\(space)\(char)"
            case ":":
                color = RGB(PrettyColor.value.rawValue)
                text = "\(char) "
            case "\n":
                fallthrough
            case " ":
                text = isText ? " " : ""
            default:
                text = "\(char)"
            }
            
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.m80_setTextColor(symbols.contains("\(char)") ? RGB(PrettyColor.normal.rawValue) : color)
            attributedText.m80_setFont(UIFont(name: "Menlo", size: 12)!)
            prettyLabel.appendAttributedText(attributedText)
        }

        let width = parentView.frame.size.width
        let height = parentView.frame.size.height
        //Set pretty scroll view
        let prettySize = prettyLabel.sizeThatFits(CGSize.init(width: width - 10, height: CGFloat.greatestFiniteMagnitude))
        prettyLabel.frame = CGRect.init(x: 5, y: 5, width: prettySize.width, height: prettySize.height)
        prettyLabel.backgroundColor = UIColor.clear
        let prettyScrollView: UIScrollView = {
            let view = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height - 50))
            view.contentSize = CGSize.init(width: width, height: prettySize.height + 70)
            view.backgroundColor = RGB(0xf2f2f2)
            view.addSubview(prettyLabel)
            return view
        }()
        return prettyScrollView
    }
    
    class func RGB(_ value : Int) -> UIColor {
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0x00FF00) >> 8 ) / 255.0
        let b = CGFloat((value & 0x0000FF)      ) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}

