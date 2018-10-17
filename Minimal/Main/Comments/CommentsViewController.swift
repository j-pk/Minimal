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
    var database: Database?
    weak var delegate: SubredditSelectionProtocol?
    var themeManager = ThemeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //in addition to passing the listing, perhaps just pass the image to instead of setting it to do
        //calculations on sectionHeaderHeight
        tableView.sectionHeaderHeight = 400
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension

        view.backgroundColor = themeManager.theme.primaryColor
        bottomMenuBar.backgroundColor = themeManager.theme.primaryColor
        tableView.backgroundColor = themeManager.theme.primaryColor
        actionView.delegate = self
        actionView.listing = listing
        actionView.database = database
        actionView.commentButton.isHidden = true
        actionView.pageDownButton.isHidden = false
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
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
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
                cell.annotationView.delegate = self
                cell.presentationView.delegate = self
            }
            return cell.contentView
        default:
            return nil
        }
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
