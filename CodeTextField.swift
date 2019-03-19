//
//  CodeTextField.swift
//  Authorization
//
//  Created by Dmitry Gulyagin on 15/02/2019.
//  Copyright © 2019 Dmitry Gulyagin. All rights reserved.
//

import UIKit

/// Данный класс позволяет переписать свойство rect, подробнее https://developer.apple.com/documentation/uikit/uitextselectionrect
class SelectionRect: UITextSelectionRect {
    private var _rect: CGRect = .zero
    override var rect: CGRect { get { return _rect } }
    func setRect(_ rect: CGRect) { self._rect = rect }
}

/**
 Данный класс позволяет создовать поля для ввода кодов
 - important:
 Данный класс оптимизирован для вставки / копирования / удаления текста, стандартным способом, через GUI.
 Свойство text содержит значение
 */
@IBDesignable
class CodeTextField: UITextField, UITextFieldDelegate {
    @IBInspectable var count: Int = 6
    @IBInspectable var spacing: CGFloat = 13
    @IBInspectable var underlineColor: UIColor = #colorLiteral(red: 0.004144040868, green: 0.2855066359, blue: 0.5929411054, alpha: 1)
    @IBInspectable var underlineHeight: CGFloat = 3
    @IBInspectable var isHiddenWhenEntering: Bool = false
    
    /// Ширина одной буквы
    private var digtWidth: CGFloat {
        get {
            return self.frame.width / CGFloat(count)
        }
    }
    
    private var textHeigh: CGFloat {
        get {
            return self.font?.lineHeight ?? 0
        }
    }
    
    override func awakeFromNib() {
        self.delegate = self
        self.keyboardType = .numberPad
        self.textAlignment = .center
        if #available(iOS 12.0, *) {
            self.textContentType = .oneTimeCode
        }
    }
    
    /// Ожидаемый размер
    override var intrinsicContentSize: CGSize {
        let testString = Array(repeating: "0", count: self.count).joined()
        let stringSize = NSAttributedString(string: testString, attributes: self.defaultTextAttributes).size()
        return CGSize(width: stringSize.width + spacing * CGFloat(count), height: stringSize.height + underlineHeight)
    }
    
    // Размер и позиция курсор
    override func caretRect(for position: UITextPosition) -> CGRect {
        let defaultSize = super.caretRect(for: position).size
        let offset = CGFloat(self.offset(from: self.beginningOfDocument, to: position))
        return CGRect(origin: CGPoint(x: offset * digtWidth, y: self.frame.height - defaultSize.height), size: defaultSize)
    }
    
    // Позиция курсора в тексте по положению
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        var offset = Int((point.x / digtWidth).rounded())
        if offset > count {
            offset = count
        } else if offset < 0 {
            offset = 0
        }
        return self.position(from: self.beginningOfDocument, offset: offset)
    }
    
    // Расчет размера выделения
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        let start = CGFloat(self.offset(from: self.beginningOfDocument, to: range.start))
        let end = CGFloat(self.offset(from: self.beginningOfDocument, to: range.end) )
        
        let width = (end - start) * digtWidth

        let selection = SelectionRect()
        selection.setRect(CGRect(x: start * digtWidth, y: self.frame.height - self.textHeigh - self.underlineHeight, width: width, height: self.textHeigh + self.underlineHeight))
        return [selection]
    }
    
    // Стандартный текст и placeholder не отрисовываются
    override func drawText(in rect: CGRect) {
        setNeedsDisplay()
    }
    
    override func drawPlaceholder(in rect: CGRect) {}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        
        // Парсим ввод и обрезаем лишнее
        if let numbers = newString?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) {
            if numbers.count > count {
                let index = String.Index(encodedOffset: count)
                let string = String(numbers[..<index])
                textField.text = string
            } else {
                textField.text = numbers
            }
        } else {
            textField.text = nil
        }
        // Смещаем курсор
        let offset: Int = min(range.location + string.count, count)
        if let position = textField.position(from: textField.beginningOfDocument, offset: offset) {
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        return false
    }
    
    override func draw(_ rect: CGRect) {
        // Расставляем поля для цифр
        let digts: [String] = self.text?.map { String($0) } ?? []
        
        for index in 0 ..< count {
            if digts.count > index {
                let digtRect =  CGRect(x: digtWidth * CGFloat(index), y: rect.height - textHeigh - underlineHeight, width: digtWidth, height: rect.height)
                (digts[index] as NSString).draw(in: digtRect, withAttributes: defaultTextAttributes)
                
                // Не рисуем линии если уже нарисовали буквы, и включен флаг
                if isHiddenWhenEntering {
                    continue
                }
            }
            
            let path = UIBezierPath()
            let y = rect.height - underlineHeight / 2
            path.move(to: CGPoint(x: digtWidth * CGFloat(index) + spacing / 2, y: y))
            path.addLine(to: CGPoint(x: digtWidth * CGFloat(index + 1) - spacing / 2, y: y))
            path.lineWidth = underlineHeight
            underlineColor.setStroke()
            path.stroke()
        }
    }
}
