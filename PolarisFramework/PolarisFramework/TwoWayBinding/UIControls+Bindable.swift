//
//  UIControls+Bindable.swift
//  PolarisFramework
//
//  Created by overtheleaves on 31/01/2019.
//  Copyright © 2019 overtheleaves. All rights reserved.
//

import Foundation

extension UITextField : Bindable {
    public typealias BindingType = String
    
    public func observingValue() -> String? {
        return self.text
    }
    
    public func updateValue(_ value: String) {
        self.text = value        
    }
}

extension UISwitch : Bindable {
    public typealias BindingType = Bool
    
    public func observingValue() -> Bool? {
        return self.isOn
    }
    
    public func updateValue(_ value: Bool) {
        self.isOn = value
    }
}

extension UISlider : Bindable {
    public typealias BindingType = Float
    
    public func observingValue() -> Float? {
        return self.value
    }
    
    public func updateValue(_ value: Float) {
        self.value = value
    }
}

extension UIStepper : Bindable {
    public typealias BindingType = Double
    
    public func observingValue() -> Double? {
        return self.value
    }
    
    public func updateValue(_ value: Double) {
        self.value = value
    }
}

extension UISegmentedControl : Bindable {
    public typealias BindingType = Int
    
    public func observingValue() -> Int? {
        return self.selectedSegmentIndex
    }
    
    public func updateValue(_ value: Int) {
        self.selectedSegmentIndex = value
    }
}

public class BindableTextView: UITextView, Bindable, UITextViewDelegate {
    public typealias BindingType = String
    public override var delegate: UITextViewDelegate? {
        get {
            return self
        }
        
        set {
            if let val = newValue {
                self.delegateChain.append(val)
            }
        }
    }
    private var delegateChain: [UITextViewDelegate] = []
    
    public func observingValue() -> String? {
        return self.text
    }
    
    public func updateValue(_ value: String) {
        self.text = value
    }
    
    public func bind(with observable: Observable<String>) {
        self.delegate = self
        self.register(for: observable)
        self.observe(for: observable) { [weak self] (value) in
            self?.updateValue(value)
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        self.valueChanged()
        
        for delegate in delegateChain {
            delegate.textViewDidChange?(textView)
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        var ret: Bool = true
        for delegate in delegateChain {
            ret = ret && delegate.textViewShouldBeginEditing?(textView) ?? true
        }
        
        return ret
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        var ret: Bool = true
        for delegate in delegateChain {
            ret = ret && delegate.textViewShouldEndEditing?(textView) ?? true
        }
        
        return ret
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        for delegate in delegateChain {
            delegate.textViewDidBeginEditing?(textView)
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        for delegate in delegateChain {
            delegate.textViewDidEndEditing?(textView)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        var ret: Bool = true

        for delegate in delegateChain {
            ret = ret && delegate.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        }
        
        return ret
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        for delegate in delegateChain {
            delegate.textViewDidChangeSelection?(textView)
        }
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        var ret: Bool = true
        
        for delegate in delegateChain {
            ret = ret && delegate.textView?(textView, shouldInteractWith: URL,
                                           in: characterRange, interaction: interaction) ?? true
        }
        
        return ret
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        var ret: Bool = true
        
        for delegate in delegateChain {
            ret = ret && delegate.textView?(textView, shouldInteractWith: textAttachment,
                                            in: characterRange,
                                            interaction: interaction) ?? true
        }
        
        return ret
    }
}
