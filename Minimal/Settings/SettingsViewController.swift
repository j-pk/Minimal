//
//  ViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices
import MessageUI

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var authSession: SFAuthenticationSession?
    var themeManager = ThemeManager()
    var database: Database?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        
        view.backgroundColor = themeManager.theme.primaryColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Settings"
    }
    
    //MARK: TableView Helper Methods
    func configure(cell: LabelBaseCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(forInsetValue: .none)
        cell.selectionImage = .arrow
        switch SettingsTableViewSections(indexPath: indexPath) {
        case .theme?:
            switch SettingsTableViewSections.ThemeSection(indexPath: indexPath) {
            case .userInterface?:
                cell.titleLabel.text = "Theme"
            case .fontStyle?:
                cell.titleLabel.text = "Font"
            default:
                cell.titleLabel.text = "Display"
            }
        case .app?:
            cell.selectionImage = .none
            switch SettingsTableViewSections.AppSection(indexPath: indexPath) {
            case .rate?:
                cell.titleLabel.text = "Rate Minimal"
            case .share?:
                cell.titleLabel.text = "Share Minimal"
            default:
                cell.titleLabel.text = "Send Feeback"
            }
        default:
            break
        }
    }
    
    func configure(cell: AuthenticateCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(forInsetValue: .none)
        if let defaults = Defaults.retrieve(), defaults.accessToken != nil {
            cell.authenticateLabel.text = "Disconnect from Reddit"
        } else {
            cell.authenticateLabel.text = "Connect to Reddit"
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    private enum SettingsTableViewSections: Int {
        case theme
        case app
        case authenticate
        
        init?(indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)
        }
        
        enum ThemeSection: Int {
            case userInterface
            case fontStyle
            case display
            
            init?(indexPath: IndexPath) {
                self.init(rawValue: indexPath.row)
            }
        }
        
        enum AppSection: Int {
            case rate
            case share
            case feedback
            
            init?(indexPath: IndexPath) {
                self.init(rawValue: indexPath.row)
            }
        }
        
        static let allValues = [theme, app, authenticate]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsTableViewSections.allValues.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SettingsTableViewSections(rawValue: section)! {
        case .authenticate:
            return 1
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SettingsTableViewSections(indexPath: indexPath) {
        case .authenticate?:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AuthenticateCell", for: indexPath) as! AuthenticateCell
            configure(cell: cell, forRowAt: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelBaseCell", for: indexPath) as! LabelBaseCell
            configure(cell: cell, forRowAt: indexPath)
            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SettingsTableViewSections(indexPath: indexPath) {
        case .app?:
            switch SettingsTableViewSections.AppSection(indexPath: indexPath) {
            case .rate?:
                posLog(message: "Rate")
                presentStoreReviewController()
            case .share?:
                posLog(message: "Share")
                presentShareOptions()
            case .feedback?:
                posLog(message: "Feedback")
                presentFeedbackEmail()
            default:
                break
            }
        case .authenticate?:
            if var defaults = Defaults.retrieve(), defaults.accessToken != nil {
                defaults.accessToken = nil
                defaults.store()
                self.tableView.reloadData()
            } else {
                let networkManager = NetworkManager()
                authSession = networkManager.requestAuthentication(completionHandler: { [weak self] (url, error) in
                    networkManager.results = (url: url, error: error)
                    self?.tableView.reloadData()
                })
                posLog(message: "Starting SFAuthenticationSession")
                authSession?.start()
            }
        case .theme?:
            switch SettingsTableViewSections.ThemeSection(indexPath: indexPath) {
            case .userInterface?:
                let themeViewController: ThemeViewController = UIViewController.make(storyboard: .settings)
                navigationController?.pushViewController(themeViewController, animated: true)
            case .fontStyle?:
                let fontViewController: FontViewController = UIViewController.make(storyboard: .settings)
                navigationController?.pushViewController(fontViewController, animated: true)
            case .display?:
                let displayViewController: DisplayViewController = UIViewController.make(storyboard: .settings)
                navigationController?.pushViewController(displayViewController, animated: true)
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: Stackable
extension SettingsViewController: Stackable {
    func set(database: DatabaseEngine) {
        self.database = database
    }
}

extension SettingsViewController {
    private func presentStoreReviewController() {
        // If the count has not yet been stored, this will return 0
        guard var defaults = Defaults.retrieve() else { return }
        defaults.rateCount += 1
        defaults.store()
        
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }
        
        if defaults.rateCount < 4 && currentVersion != defaults.lastVersionPromptedForReview {
            DispatchQueue.main.async { [navigationController] in
                if navigationController?.topViewController is SettingsViewController {
                    SKStoreReviewController.requestReview()
                }
            }
        } else {
            // Looks like you reviewed this app version or submitted multiple reviews already. Thanks and please consider submitting a review on the next update
        }
    }
    
    private func presentShareOptions() {
        if let url = URL(string: "https://itunes.apple.com/app/id<App ID Here>?mt=8") {
            let shareText = "Minimal for Reddit app"
            let viewController = UIActivityViewController(activityItems: [shareText, url], applicationActivities: nil)
            present(viewController, animated: true)
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    private func presentFeedbackEmail() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else { return }
        let body =
        """
        <p>Feedback</p>
        
        Miminal for Reddit App<br>
        version: \(version)<br>
        build: \(build)<br>
        """
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["minimalApp@gmail.com"])
            mail.setSubject("Miminal \(version)")
            mail.setMessageBody(body, isHTML: true)
            
            present(mail, animated: true)
        } else {
            posLog(message: "Mail is not configured on this device")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

