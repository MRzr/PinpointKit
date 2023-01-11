//
//  PinpointFeedbackNavigationController.swift
//  PinpointKit
//
//  Created by Matthew Bischoff on 2/19/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit

/// A `UINavigationController` subclass that has a `PinpointFeedbackViewController` as its root view controller. Use this class as a `PinpointFeedbackCollector`.
public final class PinpointFeedbackNavigationController: UINavigationController, PinpointFeedbackCollector {
    
    // MARK: - InterfaceCustomizable
    
    public var interfaceCustomization: InterfaceCustomization? {
        get {
            return feedbackViewController.interfaceCustomization
        }
        set {
            feedbackViewController.interfaceCustomization = newValue
            view.tintColor = interfaceCustomization?.appearance.tintColor
        }
    }
    
    // MARK: - LogSupporting
    
    public var logViewer: LogViewer? {
        get {
            return feedbackViewController.logViewer
        }
        set {
            feedbackViewController.logViewer = newValue
        }
    }
    
    public var logCollector: LogCollector? {
        get {
            return feedbackViewController.logCollector
        }
        set {
            feedbackViewController.logCollector = newValue
        }
    }
    
    // MARK: - PinpointFeedbackCollector
    
    public var editor: Editor? {
        get {
            return feedbackViewController.editor
        }
        set {
            feedbackViewController.editor = newValue
        }
    }
    
    public var feedbackConfiguration: PinpointFeedbackConfiguration? {
        get {
            return feedbackViewController.feedbackConfiguration
        }
        set {
            feedbackViewController.feedbackConfiguration = newValue
        }
    }
    
    public var feedbackDelegate: PinpointFeedbackCollectorDelegate? {
        get {
            return feedbackViewController.feedbackDelegate
        }
        set {
            feedbackViewController.feedbackDelegate = newValue
        }
    }
    
    // MARK: - PinpointFeedbackNavigationController

    /// The root view controller used to collect feedback.
    let feedbackViewController: PinpointFeedbackViewController
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        feedbackViewController = PinpointFeedbackViewController()
        
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
     
        commonInitialization()
    }
    
    public convenience init() {
        self.init(navigationBarClass: nil, toolbarClass: nil)
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        feedbackViewController = PinpointFeedbackViewController()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    override init(rootViewController: UIViewController) {
        fatalError("init(rootViewController:) is not supported. Use init() or init(navigationBarClass:, toolbarClass:)")
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PinpointFeedbackNavigationController
    
    private func commonInitialization() {
        viewControllers = [feedbackViewController]
    }

    // MARK: - PinpointFeedbackCollector
    
    public func collectPinpointFeedback(with screenshot: UIImage?, from viewController: UIViewController) {
        guard presentingViewController == nil else {
            NSLog("Unable to present PinpointFeedbackNavigationController because it is already being presented")
            return
        }
        
        feedbackViewController.screenshot = screenshot
        feedbackViewController.annotatedScreenshot = screenshot
        self.modalPresentationStyle = feedbackConfiguration?.presentationStyle ?? .fullScreen
        viewController.present(self, animated: true, completion: nil)
    }

    // MARK: - UINavigationController

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
