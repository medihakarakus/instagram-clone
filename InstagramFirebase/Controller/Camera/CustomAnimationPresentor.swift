//
//  CustomAnimationPresentor.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 29.03.23.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from) else { return } //fromView: HomeController
        guard let toView = transitionContext.view(forKey: .to) else { return } //toView: CameraController
        containerView.addSubview(toView)
        
        let startingFrame = CGRect(x: -toView.frame.height, y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startingFrame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        } completion: { _ in
            transitionContext.completeTransition(true)
        }

        
        
        
    }
}
