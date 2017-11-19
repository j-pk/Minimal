//
//  CommentsViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/17/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {    
    @IBOutlet weak var tableView: UITableView!
    var listing: Listing?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderHeight = 350
        tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
    }
}


extension CommentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let _ = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        return UITableViewCell()
    }
}

extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        switch section {
        case 0:
            if let listing = listing {
                cell.configureCell(forListing: listing)
            }
            return cell.contentView
        default:
            return nil
        }
    }
}
