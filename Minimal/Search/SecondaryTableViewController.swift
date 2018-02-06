//
//  SecondaryTableViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 2/6/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit


class SecondaryTableViewController: UITableViewController {
    
    @IBOutlet weak var homeCell: UITableViewCell!
    @IBOutlet weak var popularCell: UITableViewCell!
    @IBOutlet weak var allCell: UITableViewCell!
    @IBOutlet weak var randomCell: UITableViewCell!
    
    private enum SecondaryLinkOptions: Int {
        case home
        case popular
        case all
        case random
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45.0
        let cells = [homeCell, popularCell, allCell, randomCell]
        cells.flatMap({ $0 }).forEach({ $0.setSeparatorInset(forInsetValue: .zero) })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let linkSelected = SecondaryLinkOptions(rawValue: indexPath.row) else { return }
        switch linkSelected {
        case .home:
            print("home")
        case .popular:
            print("popular")
        case .all:
            print("all")
        case .random:
            print("random")
        }
    }
}
