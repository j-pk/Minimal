//
//  DisplayViewController.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 1/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var themeManager = ThemeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = "Display"
        view.backgroundColor = themeManager.theme.primaryColor
    }
}

extension DisplayViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DisplayOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DisplayCell.identifier, for: indexPath) as! DisplayCell
        cell.displayLabel.text = DisplayOptions.allCases[indexPath.row].title
        cell.displayImageView.image = DisplayOptions.allCases[indexPath.row].image
        if let defaults = Defaults.retrieve() {
            cell.checkmark.isHidden = DisplayOptions.allCases[indexPath.row] != DisplayOptions(rawValue: defaults.displayOption)
        }
        return cell
    }
    
}

extension DisplayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? DisplayCell {
            cell.checkmark.isHidden = false
            let deselectedCells = tableView.visibleCells.compactMap({ $0 as? DisplayCell }).filter({ $0 != cell })
            deselectedCells.forEach({ $0.checkmark.isHidden = true })
            themeManager.display = DisplayOptions.allCases[indexPath.row]
        }
    }
}

