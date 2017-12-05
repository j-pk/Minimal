//
//  ViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var authSession: SFAuthenticationSession?
    weak var delegate: AuthenticationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LabelBaseCell.self, forCellReuseIdentifier: "LabelBaseCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = ThemeManager.default.primaryTheme
    }
    
    //MARK: TableView Helper Methods
    func configureHeader(InSection section: Int) -> UIView {
        let headerView = UIView()
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = ThemeManager.default.primaryTheme
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(bottomLineView)
        
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]-0-|",
                                                                  options: NSLayoutFormatOptions.alignAllLeading,
                                                                  metrics: nil,
                                                                  views: ["bottomLineView": bottomLineView]))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bottomLineView]-0-|",
                                                                  options: NSLayoutFormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["bottomLineView": bottomLineView]))
        return headerView
    }
    
    func configure(cell: LabelBaseCell, forRowAt indexPath: IndexPath) {
        cell.setSeparatorInset(forInsetValue: .none)
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
            switch SettingsTableViewSections.App(indexPath: indexPath) {
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
        cell.setSeparatorInset(forInsetValue: .zero)
        //if no access token, or expired session
        cell.authenticateLabel.text = "Login to Reddit"
        //else "Logout 
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
            case unknown
            
            init?(indexPath: IndexPath) {
                self.init(rawValue: indexPath.row)
            }
        }
        
        enum App: Int {
            case rate
            case share
            case feedback
            
            init?(indexPath: IndexPath) {
                self.init(rawValue: indexPath.row)
            }
        }
        
        static let allValues: [SettingsTableViewSections] = [theme, app, authenticate]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsTableViewSections.allValues.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SettingsTableViewSections.authenticate.rawValue == section ? configureHeader(InSection: section) : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
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
        case .authenticate?:
            self.delegate = APIManager.default
            authSession = APIManager.default.authenticate(completionHandler: { (url, error) in
                self.delegate?.authenticated(results: (url, error))
            })
            print("Starting SFAuthenticationSession...")
            authSession?.start()
        default:
            break
        }
        
    }
}

