//
//  SearchViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/1/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import CoreData


class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    let searchController = UISearchController(searchResultsController: nil)
    let themeManager = ThemeManager()
    
    private var searchResultsController: NSFetchedResultsController<Subreddit> = {
        let fetchRequest = NSFetchRequest<Subreddit>(entityName: Subreddit.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController<Subreddit>(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.default.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        searchResultsController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        configure(searchBar: searchController.searchBar)
        searchBarContainerView.addSubview(searchController.searchBar)
        definesPresentationContext = true
        
        performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configure(searchBar: searchController.searchBar)
    }
    
    func performFetch(withPredicate predicate: NSPredicate? = nil) {
        // TODO: Determine user preference for over18
        let over18: Bool = false
        let defaultSearchPredicate = NSPredicate(format: "allowImages == true OR allowVideoGifs == true")
        let over18Predicate = NSPredicate(format: "over18 == %@", over18 as CVarArg)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [defaultSearchPredicate, over18Predicate])
        searchResultsController.fetchRequest.predicate = predicate ?? compoundPredicate
        
        do {
            try searchResultsController.performFetch()
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func configure(searchBar: UISearchBar) {
        searchBar.placeholder = "Search Subreddits"
        searchBar.setTextColor(color: themeManager.theme.titleTextColor)
        searchBar.setTextFieldColor(color: .clear)
        searchBar.setPlaceholderTextColor(color: themeManager.theme.subtitleTextColor)
        searchBar.setSearchImageColor(color: themeManager.theme.tintColor)
        searchBar.setTextFieldClearButtonColor(color: themeManager.theme.tintColor)
        searchBar.searchBarStyle = .minimal
    }
}
    
extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let subreddit = searchResultsController.object(at: indexPath)
        cell.setView(forSubreddit: subreddit)
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
}


extension SearchViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .fade)
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
        default:
            break
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let deleteIndexPath = indexPath {
                tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
            break
        case .insert:
            if let insertPath = newIndexPath {
                tableView.beginUpdates()
                self.tableView.insertRows(at: [insertPath], with: UITableViewRowAnimation.fade)
                tableView.endUpdates()
            }
            break
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        
        if searchString.isEmpty {
            performFetch()
            tableView.reloadData()
        } else {
            performFetch(withPredicate: NSPredicate(format: "displayName CONTAINS[cd] %@", searchString))
            tableView.reloadData()
        }
    }
}
