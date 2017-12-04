//
//  ViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LabelBaseCell.self, forCellReuseIdentifier: "LabelBaseCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
}

extension SettingsViewController: UITableViewDataSource {
    private enum SettingsTableViewSections: Int {
        case theme
        case app
        case authenticate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SettingsTableViewSections(rawValue: indexPath.section)! {
        case .authenticate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AuthenticateCell", for: indexPath) as! AuthenticateCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelBaseCell", for: indexPath) as! LabelBaseCell
            cell.titleLabel.text = "Blah"
            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
