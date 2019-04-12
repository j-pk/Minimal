//
//  SubscribedViewController.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/23/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit
import CoreData
import Nuke

class SubscribedViewController: UIViewController {
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var database: Database?
    private var subscribedResultsController: NSFetchedResultsController<Subreddit>!
    weak var delegate: SubredditSelectionProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SubscribedCell.nib, forCellReuseIdentifier: SubscribedCell.identifier)
        guard let database = database else { return }
        
        let fetchRequest = NSFetchRequest<Subreddit>(entityName: Subreddit.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isSubscribed == true")
        subscribedResultsController = NSFetchedResultsController<Subreddit>(fetchRequest: fetchRequest, managedObjectContext: database.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        subscribedResultsController.delegate = self

        performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let defaults = Defaults.retrieve(), defaults.accessToken != nil, let database = database {
//            let request = SubredditRequest(requestType: .getSubscribed())
//            SubscribedManager(request: request, database: database, completionHandler: { (error) in
//                if let error = error {
//                    posLog(error: error)
//                } else {
//                    posLog(message: "Sucessfully Got Subscribed")
//                }
//            })
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    func performFetch() {
        do {
            try subscribedResultsController.performFetch()
        } catch let error {
            posLog(error: error, category: SubscribedViewController.typeName)
        }
    }
}

// MARK: UITableViewDelegate
extension SubscribedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subreddit = subscribedResultsController.object(at: indexPath)
        delegate?.didSelect(subreddit: subreddit)
        tabBarController?.tab(toViewController: MainViewController.self)
    }
}

// MARK: UITableViewDataSource
extension SubscribedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return subscribedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = subscribedResultsController.sections
        return sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let isSubscribed = subscribedResultsController.fetchedObjects?.isEmpty, !isSubscribed else { return nil }
        let headerView = SubscribedHeaderView()
        headerView.headerLabel.text = "Subscribed"
        return headerView.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubscribedCell.identifier, for: indexPath) as! SubscribedCell
        let object = subscribedResultsController.object(at: indexPath)
        cell.titleLabel.text = object.displayName
        cell.subtitleLabel.text = object.publicDescription
        if let urlString = object.iconImage, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: cell.subredditImageView)
        }
        return cell
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension SubscribedViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
