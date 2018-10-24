//
//  CommentsViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/17/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import SafariServices

class CommentsViewController: UIViewController {
    @IBOutlet weak var bottomMenuBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionView: ActionView!
    
    var listing: Listing?
    var database: Database? {
        didSet {
            guard let database = database, let listing = listing else { return }
            commentsModel = CommentsModel(database: database, listing: listing)
        }
    }
    var commentsModel: CommentsModel?
    weak var delegate: SubredditSelectionProtocol?
    var themeManager = ThemeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //in addition to passing the listing, perhaps just pass the image to instead of setting it to do
        //calculations on sectionHeaderHeight
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        
        view.backgroundColor = themeManager.theme.primaryColor
        bottomMenuBar.backgroundColor = themeManager.theme.primaryColor
        tableView.backgroundColor = themeManager.theme.primaryColor
        actionView.delegate = self
        actionView.listing = listing
        actionView.database = database
        actionView.commentButton.isHidden = true
        actionView.pageDownButton.isHidden = false
        
        commentsModel?.requestComments() {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageViewControllerSegue" {
            if let destination = segue.destination as? ImageViewController {
                guard let listing = listing else { return }
                destination.request = listing.request
            }
        }
    }
}


extension CommentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let model = commentsModel else { return 1 }
        return model.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = commentsModel else { return 1 }
        return model.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        let nodes = commentsModel?.nodes[indexPath.section]
        
        switch indexPath.row {
        case 0:
            cell.configure(for: nodes?.value)
        default:
            cell.configure(for: nodes?.children[indexPath.row - 1].value)
        }
        
        return cell
    }
}

extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        switch section {
        case 0:
            if let listing = listing {
                cell.configureCell(forListing: listing)
                cell.annotationView.delegate = self
                cell.presentationView.delegate = self
            }
            return cell.contentView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 400
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}

extension CommentsViewController: UIViewTappableDelegate {
    func didTapView(sender: UITapGestureRecognizer, data: [String: Any?]) {
        if let view = sender.view, let label = view as? UILabel {
            guard let database = database, let prefixedSubreddit = label.text else { return }
            delegate?.didSelect(prefixedSubreddit: prefixedSubreddit, context: database.viewContext)
            navigationController?.popViewController(animated: true)
        } else if !data.filter({ $0.key == "image" }).isEmpty {
            performSegue(withIdentifier: "imageViewControllerSegue", sender: self)
        } else if let url = data["url"] as? URL {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.preferredBarTintColor = themeManager.theme.primaryColor
            safariViewController.preferredControlTintColor = themeManager.theme.secondaryColor
            safariViewController.delegate = self
            present(safariViewController, animated: true)
        }
    }
}

extension CommentsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

extension CommentsViewController: ActionViewDelegate {
    func didSelectMoreButton(sender: UIButton, controller: UIAlertController) {
        present(controller, animated: true, completion: nil)
    }
    
    func didSelectPageDownButton(sender: UIButton, listing: Listing?) {
        //
    }
    
    func didSelectCommentButton(sender: UIButton, listing: Listing?) {
        //
    }
}
