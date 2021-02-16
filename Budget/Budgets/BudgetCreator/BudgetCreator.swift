//
//  BudgetCreator.swift
//  Budget
//
//  Created by Bryan Oppong-Boateng on 30.01.21.
//

import UIKit

class BudgetCreator: UIViewController, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak private var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak private var budgetFace: BudgetFace!
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var saveButton: UIBarButtonItem!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openColorPicker))
        budgetFace.addGestureRecognizer(tap)
        
        textField.becomeFirstResponder()
        textField.addTarget(self, action: #selector(updateSaveButtonIsEnabled), for: .editingChanged)
        
        saveButton.isEnabled = false
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        budgetFace.color = viewController.selectedColor
        updateSaveButtonIsEnabled()
    }
        
    @objc private func openColorPicker(_ sender: Any) {
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = false
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomContraint.constant = .zero
        } else {
            bottomContraint.constant = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        }
    }
    
    @objc func updateSaveButtonIsEnabled() {
        saveButton.isEnabled = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) && budgetFace.color != nil
    }
}
