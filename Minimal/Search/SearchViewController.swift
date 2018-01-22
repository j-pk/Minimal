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
    
    let searchController = UISearchController(searchResultsController: nil)
    let themeManager = ThemeManager()
    
    override func viewDidLoad() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        configure(searchBar: searchController.searchBar)
        searchBarContainerView.addSubview(searchController.searchBar)
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configure(searchBar: searchController.searchBar)
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
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
        //
    }
}
