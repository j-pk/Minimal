//
//  DefaultSubredditsViewController.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/26/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class DefaultSubredditsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: UISearchActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(SubscribedCell.nib, forCellReuseIdentifier: SubscribedCell.identifier)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
}

extension DefaultSubredditsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DefaultSubreddit.allValues.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SubscribedHeaderView()
        headerView.headerLabel.text = "Minimal"
        return headerView.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubscribedCell.identifier, for: indexPath) as! SubscribedCell
        guard let defaultSubreddit = DefaultSubreddit(rawValue: indexPath.row) else { return cell }
        cell.titleLabel.text = defaultSubreddit.displayName
        cell.subtitleLabel.text = defaultSubreddit.publicDescription
        cell.subredditImageView.image = UIImage(named: defaultSubreddit.iconImage)
        return cell
    }
}

extension DefaultSubredditsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let defaultSubreddit = DefaultSubreddit(rawValue: indexPath.row) else { return }
        delegate?.didSelect(defaultSubreddit: defaultSubreddit)
        tabBarController?.tab(toViewController: MainViewController.self)
    }
}





