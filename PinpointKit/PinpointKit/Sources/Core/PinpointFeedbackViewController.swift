//
//  PinpointFeedbackViewController.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import UIKit
import PhotosUI

/// A `UITableViewController` that conforms to `PinpointFeedbackCollector` in order to display an interface that allows the user to see, change, and send feedback.
public final class PinpointFeedbackViewController: UITableViewController {
    
    // MARK: - InterfaceCustomizable
    
    public var interfaceCustomization: InterfaceCustomization? {
        didSet {
            guard isViewLoaded else { return }
            
            updateInterfaceCustomization()
        }
    }
    
    // MARK: - LogSupporting
    
    public var logViewer: LogViewer?
    public var logCollector: LogCollector?
    public var editor: Editor?
    var callback:((String) -> Void)?
    var selectedCategoryIndex = 0 {
        didSet {
            updateDataSource()
        }
    }
    var descriptionText:String = ""
    {
        didSet {
            updateDataSource()
        }
    }
    // MARK: - PinpointFeedbackCollector
    
    public weak var feedbackDelegate: PinpointFeedbackCollectorDelegate?
    public var feedbackConfiguration: PinpointFeedbackConfiguration?
    
    // MARK: - PinpointFeedbackViewController
    
    /// The screenshot the feedback describes.
    public var screenshot: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            updateDataSource()
        }
    }
    
    /// The annotated screenshot the feedback describes.
    var annotatedScreenshot: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            updateDataSource()
        }
    }
    
    private var dataSource: PinpointFeedbackTableViewDataSource? {
        didSet {
            guard isViewLoaded else { return }
            tableView.dataSource = dataSource
        }
    }
    
    fileprivate var userEnabledLogCollection = true {
        didSet {
            updateDataSource()
        }
    }
    
    public required init() {
        super.init(style: .grouped)
    }
    
    @available(*, unavailable)
    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return .default }
        let appearance = interfaceCustomization.appearance
        return appearance.statusBarStyle
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        
        // Helps to prevent extra spacing from appearing at the top of the table.
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: .leastNormalMagnitude))
        tableView.sectionHeaderHeight = .leastNormalMagnitude
        
        editor?.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateInterfaceCustomization()
    }
    
    // MARK: - PinpointFeedbackViewController
    
    private func updateDataSource() {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return }
        let screenshotToDisplay = annotatedScreenshot ?? screenshot
        callback =  {[weak self] text in
            self?.descriptionText = text
        }
        dataSource = PinpointFeedbackTableViewDataSource(interfaceCustomization: interfaceCustomization, screenshot: screenshotToDisplay, logSupporting: self, userEnabledLogCollection: userEnabledLogCollection, delegate: self, selectedCategoryIndex: self.selectedCategoryIndex, descriptionText: descriptionText,callback:callback)
    }
    
    private func updateInterfaceCustomization() {
        guard let interfaceCustomization = interfaceCustomization else { assertionFailure(); return }
        let interfaceText = interfaceCustomization.interfaceText
        let appearance = interfaceCustomization.appearance

        title = interfaceText.feedbackCollectorTitle
        navigationController?.navigationBar.titleTextAttributes = [
            .font: appearance.navigationTitleFont,
            .foregroundColor: appearance.navigationTitleColor
        ]
        
        let sendBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackSendButtonTitle, style: .done, target: self, action: #selector(PinpointFeedbackViewController.sendButtonTapped))
        sendBarButtonItem.setTitleTextAttributesForAllStates([.font: appearance.feedbackSendButtonFont])
        navigationItem.rightBarButtonItem = sendBarButtonItem
        
        let backBarButtonItem = UIBarButtonItem(title: interfaceText.feedbackBackButtonTitle, style: .plain, target: nil, action: nil)
        backBarButtonItem.setTitleTextAttributesForAllStates([.font: appearance.feedbackBackButtonFont])
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let cancelBarButtonItem: UIBarButtonItem
        let cancelAction = #selector(PinpointFeedbackViewController.cancelButtonTapped)
        if let cancelButtonTitle = interfaceText.feedbackCancelButtonTitle {
            cancelBarButtonItem = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: cancelAction)
        } else {
            cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancelAction)
        }
        
        cancelBarButtonItem.setTitleTextAttributesForAllStates([.font: appearance.feedbackCancelButtonFont])
        
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = cancelBarButtonItem
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        view.tintColor = appearance.tintColor
        updateDataSource()
    }
    
    @objc private func sendButtonTapped() {
        
        guard let feedbackConfiguration = feedbackConfiguration else {
            assertionFailure("You must set `feedbackConfiguration` before attempting to send feedback.")
            return
        }
        
        let logs = userEnabledLogCollection ? logCollector?.retrieveLogs() : nil
        
        let feedback: PinpointFeedback?
        let category = PinpointFeedbackTableViewDataSource.categories[selectedCategoryIndex]
        let description = ""
        if let screenshot = annotatedScreenshot {
            feedback = PinpointFeedback(screenshot: .annotated(image: screenshot), logs: logs, configuration: feedbackConfiguration, description: descriptionText, category: category)
        } else if let screenshot = screenshot {
            feedback = PinpointFeedback(screenshot: .original(image: screenshot), logs: logs, configuration: feedbackConfiguration, description: descriptionText, category: category)
        } else {
            feedback = nil
        }
        
        guard let feedbackToSend = feedback else { return assertionFailure("We must have either a screenshot or an edited screenshot!") }
        
        feedbackDelegate?.feedbackCollector(self, didCollect: feedbackToSend)
    }
    
    @objc private func cancelButtonTapped() {
        guard presentingViewController != nil else {
            assertionFailure("Attempting to dismiss `PinpointFeedbackViewController` in unexpected presentation context.")
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PinpointFeedbackCollector

extension PinpointFeedbackViewController: PinpointFeedbackCollector {
    public func collectPinpointFeedback(with screenshot: UIImage?, from viewController: UIViewController) {
        self.screenshot = screenshot
        annotatedScreenshot = nil
        viewController.showDetailViewController(self, sender: viewController)
    }
}

// MARK: - EditorDelegate

extension PinpointFeedbackViewController: EditorDelegate {
    public func editorWillDismiss(_ editor: Editor, with screenshot: UIImage) {
        annotatedScreenshot = screenshot
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate

extension PinpointFeedbackViewController {
    public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let logCollector = logCollector else {
            assertionFailure("No log collector exists.")
            return
        }
        
        logViewer?.viewLog(in: logCollector, from: self)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.selectedCategoryIndex = indexPath.row
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
        userEnabledLogCollection = !userEnabledLogCollection
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // Only leave space under the last section.
        if section == tableView.numberOfSections - 1 {
            return tableView.sectionFooterHeight
        }
        
        return .leastNormalMagnitude
    }
}

// MARK: - PinpointFeedbackTableViewDataSourceDelegate

extension PinpointFeedbackViewController: PinpointFeedbackTableViewDataSourceDelegate {
    
    func feedbackTableViewDataSource(feedbackTableViewDataSource: PinpointFeedbackTableViewDataSource, didTapScreenshot screenshot: UIImage) {
        guard let editor = editor else { return }
        guard let screenshotToEdit = self.screenshot else { return }
        
        editor.screenshot = screenshotToEdit
        
        let editImageViewController = NavigationController(rootViewController: editor.viewController)
        editImageViewController.view.tintColor = interfaceCustomization?.appearance.tintColor
        editImageViewController.navigationBar.backgroundColor = UIColor.white
        editImageViewController.modalPresentationStyle = feedbackConfiguration?.presentationStyle ?? .fullScreen
        present(editImageViewController, animated: true, completion: nil)
    }
    
    @available(iOS 14, *)
    func feedbackTableViewDataSourceDidRequestScreenshot(feedbackTableViewDataSource: PinpointFeedbackTableViewDataSource) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        
        let pickerController = PHPickerViewController(configuration: configuration)
        pickerController.delegate = self
        viewController.present(pickerController, animated: true, completion: nil)
    }
}

@available(iOS 14, *)
extension PinpointFeedbackViewController: PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let result = results.first else {
            picker.presentingViewController?.dismiss(animated: true)
            return
        }
        
        result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { image, _ in
            OperationQueue.main.addOperation {
                defer {
                    picker.presentingViewController?.dismiss(animated: true)
                }
                
                guard let image = image as? UIImage else { return }
                self.screenshot = image
                
                self.tableView.reloadData()
            }
        })
    }
}
