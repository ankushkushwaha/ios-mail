//
//  SplashSignInSegue.swift
//  
//
//  Created by Yanfeng Zhang on 12/14/15.
//
//

class SplashSignInSegue: UIStoryboardSegue {

    override func perform() {
        let src = self.sourceViewController as! UIViewController
        let dst = self.destinationViewController as! UIViewController
        src.navigationController?.pushViewController(dst, animated:false)
    }
}