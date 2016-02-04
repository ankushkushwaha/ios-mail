//
//  SignUpEmailViewController.swift
//  
//
//  Created by Yanfeng Zhang on 12/18/15.
//
//

import UIKit

class SignUpEmailViewController: UIViewController {
    
    //define
    private let hidePriority : UILayoutPriority = 1.0;
    private let showPriority: UILayoutPriority = 750.0;
    
    @IBOutlet weak var logoTopPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoLeftPaddingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleTopPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLeftPaddingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recoveryEmailTopPaddingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleWarningLabel: UILabel!
    
    @IBOutlet weak var scrollBottomPaddingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recoveryEmailField: TextInsetTextField!
    
    @IBOutlet weak var checkButton: UIButton!
    
    var viewModel : SignupViewModel!
    
    func configConstraint(show : Bool) -> Void {
        let level = show ? showPriority : hidePriority
        
        logoTopPaddingConstraint.priority = level
        logoLeftPaddingConstraint.priority = level
        titleTopPaddingConstraint.priority = level
        titleLeftPaddingConstraint.priority = level

        recoveryEmailTopPaddingConstraint.priority = level
        
        titleWarningLabel.hidden = show
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recoveryEmailField.attributedPlaceholder = NSAttributedString(string: "Recovery Email", attributes:[NSForegroundColorAttributeName : UIColor(hexColorCode: "#9898a8")])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        NSNotificationCenter.defaultCenter().addKeyboardObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeKeyboardObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

    @IBAction func checkAction(sender: UIButton) {
        checkButton.selected = !checkButton.selected
    }

    @IBAction func backAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private var doneClicked : Bool = false
    @IBAction func doneAction(sender: UIButton) {
        if doneClicked {
            return
        }
        doneClicked = true;
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        dismissKeyboard()
        viewModel.setRecovery(checkButton.selected, email: recoveryEmailField.text)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.viewModel.createNewUser { (isOK, createDone, message, error) -> Void in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.doneClicked = false
                if !message.isEmpty {
                    let alert = message.alertController()
                    alert.addOKAction()
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                        if createDone {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            })
                        }
                    })
                } else {
                    if isOK || createDone {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        })
                    }
                }
                
            }
        })
    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    func dismissKeyboard() {
        recoveryEmailField.resignFirstResponder()
    }
}


// MARK: - NSNotificationCenterKeyboardObserverProtocol
extension SignUpEmailViewController: NSNotificationCenterKeyboardObserverProtocol {
    func keyboardWillHideNotification(notification: NSNotification) {
        let keyboardInfo = notification.keyboardInfo
        scrollBottomPaddingConstraint.constant = 0.0
        self.configConstraint(false)
        UIView.animateWithDuration(keyboardInfo.duration, delay: 0, options: keyboardInfo.animationOption, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        let keyboardInfo = notification.keyboardInfo
        let info: NSDictionary = notification.userInfo!
        if let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            scrollBottomPaddingConstraint.constant = keyboardSize.height;
        }
        self.configConstraint(true)
        UIView.animateWithDuration(keyboardInfo.duration, delay: 0, options: keyboardInfo.animationOption, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
}