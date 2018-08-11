//
//  ThemeViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/16/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var themeManager = ThemeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)

        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.title = "Theme"
        view.backgroundColor = themeManager.theme.primaryColor
    }
    
    func configure(cell: ThemeCell, forRowAt indexPath: IndexPath) {
        let theme = Theme.allValues[indexPath.section]
        cell.checkmark.isHidden = themeManager.theme != theme
        cell.themeColorPrimary.backgroundColor = theme.primaryColor
        cell.themeColorSecondary.backgroundColor = theme.secondaryColor
        cell.themeColorBackground.backgroundColor = theme.backgroundColor
        cell.themeColorSelection.backgroundColor = theme.selectionColor
        cell.themeColorTint.backgroundColor = theme.tintColor
        cell.checkmark.tintColor = theme.selectionColor
    }
}

extension ThemeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Theme.allValues[section].titleValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as! ThemeCell
        configure(cell: cell, forRowAt: indexPath)
        return cell
    }
}

extension ThemeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? ThemeCell {
            let theme = Theme.allValues[indexPath.section]
            if themeManager.theme != theme {
                themeManager.theme = theme
                tabBarController?.tabBar.barStyle = theme.barStyle
                reloadViews()
                cell.checkmark.isHidden = false
                let deselectedCells = tableView.visibleCells.compactMap({ $0 as? ThemeCell }).filter({ $0 != cell })
                deselectedCells.forEach({ $0.checkmark.isHidden = true })
            }
        }
    }
}
