//
//  SearchViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/1/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import CoreData

/// UISearchActionDelegate
///
/// Action from a search result returns the selected subreddit
protocol UISearchActionDelegate: class {
    func didSelect(subreddit: Subreddit)
    func didSelect(defaultSubreddit: DefaultSubreddit)
}

class SearchViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var subscribedTableView: UITableView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let themeManager = ThemeManager()
    private var searchResultsController: NSFetchedResultsController<Subreddit>!
    weak var delegate: UISearchActionDelegate?
    var database: Database?

    fileprivate var searchSegment: SearchSegment {
        get {
            guard let segment = SearchSegment(rawValue: segmentController.selectedSegmentIndex) else { return .subreddits }
            return segment
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true

        searchResultsController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true

        configure(searchBar: searchController.searchBar)
        searchBarContainerView.addSubview(searchController.searchBar)
        searchBarView.addShadow()
        
        performFetch(withPredicate: searchSegment.predicate)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.keyboardDismissMode = .onDrag
        subscribedTableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configure(searchBar: searchController.searchBar)
    }
    
    func performFetch(withPredicate predicate: NSPredicate, sortDescriptors descriptors: [NSSortDescriptor]? = nil) {
        // TODO: Determine user preference for over18
        let over18: Bool = false
        let over18Predicate = NSPredicate(format: "over18 == %@", over18 as CVarArg)
        let isSubscribedPredicate = NSPredicate(format: "isSubscribed == true")
        let isDefault = NSPredicate(format: "isDefault == false")
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, over18Predicate, isDefault])
        
        searchResultsController.fetchRequest.predicate = !tableView.isHidden ? compoundPredicate : isSubscribedPredicate
        searchResultsController.fetchRequest.sortDescriptors = descriptors ?? [NSSortDescriptor(key: "displayName", ascending: true)]
        
        do {
            try searchResultsController.performFetch()
        } catch let error {
            posLog(error: error, category: SearchViewController.typeName)
        }
    }
    
    func configure(searchBar: UISearchBar) {
        searchBar.placeholder = searchSegment.placeholder
        searchBar.setTextColor(color: themeManager.theme.titleTextColor)
        searchBar.setTextFieldColor(color: .clear)
        searchBar.setPlaceholderTextColor(color: themeManager.theme.subtitleTextColor)
        searchBar.setSearchImageColor(color: themeManager.theme.tintColor)
        searchBar.setTextFieldClearButtonColor(color: themeManager.theme.tintColor)
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
    }
    
    @IBAction func didSelectSegment(_ sender: UISegmentedControl) {
        let descriptors = searchSegment == .recent ? [NSSortDescriptor(key: "lastViewed", ascending: false)] : nil
        searchController.searchBar.placeholder = searchSegment.placeholder
        performFetch(withPredicate: searchSegment.predicate, sortDescriptors: descriptors)
        tableView.reloadData()
    }
    
    func resetSearch() {
        searchController.isActive = false
        // Animates subscribe tableView and hides tableView
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
            self.tableView.isHidden = true
            self.subscribedTableView.isHidden = false
            self.segmentController.isHidden = true
            self.searchBarContainerViewHeightConstraint.priority = UILayoutPriority(rawValue: 999)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return searchResultsController.sections?.count ?? 1
        } else {
            guard let objects = searchResultsController.fetchedObjects, objects.count > 0 else { return 1 }
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            let sections = searchResultsController.sections
            return sections?[section].numberOfObjects ?? 0
        } else {
            return section == 0 ? DefaultSubreddit.allValues.count : searchResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard tableView == self.tableView && searchSegment == .subreddits else { return 0 }
        let currentCollation = UILocalizedIndexedCollation.current()
        return currentCollation.section(forSectionIndexTitle: index)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard tableView == self.tableView && searchSegment == .subreddits else { return nil }
        let currentCollation = UILocalizedIndexedCollation.current()
        return currentCollation.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView == self.subscribedTableView else { return 0.0 }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView == self.subscribedTableView else { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribedHeaderCell") as! SubscribedHeaderCell
        cell.headerLabel.text = section == 0 ? "Minimal" : "Subscribed"
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView && !self.tableView.isHidden {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
            let subreddit = searchResultsController.object(at: indexPath)
            cell.setView(forSubreddit: subreddit)
            return cell
        } else {
            if tableView == self.subscribedTableView && indexPath.section == 0 {
                let cell = self.subscribedTableView.dequeueReusableCell(withIdentifier: "SubscribedCell", for: indexPath) as! SubscribedCell
                guard let defaultSubreddit = DefaultSubreddit(rawValue: indexPath.row) else { return cell }
                cell.titleLabel.text = defaultSubreddit.displayName
                cell.subtitleLabel.text = defaultSubreddit.publicDescription
                cell.subredditImageView?.image = UIImage(named: defaultSubreddit.iconImage)
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
                return cell
            }
        }
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let subreddit = searchResultsController.object(at: indexPath)
            delegate?.didSelect(subreddit: subreddit)
            tabBarController?.tab(toViewController: MainViewController.self)
        } else if tableView == self.subscribedTableView && indexPath.section == 0 {
            guard let selectedLink = DefaultSubreddit(rawValue: indexPath.row) else { return }
            delegate?.didSelect(defaultSubreddit: selectedLink)
            tabBarController?.tab(toViewController: MainViewController.self)
        }
        resetSearch()
    }
}

// MARK: SearchSegment Enum
private extension SearchViewController {
    enum SearchSegment: Int {
        case subreddits
        case recent
        
        var placeholder: String {
            switch self {
            case .subreddits: return "Search Subreddits"
            case .recent: return "Search Recent"
            }
        }
    }
}

// MARK: SearchSegment Predicate
private extension SearchViewController.SearchSegment {
    var predicate: NSPredicate {
        switch self {
        case .subreddits:
            return NSPredicate(format: "allowImages == true OR allowVideoGifs == true")
        case .recent:
            return NSPredicate(format: "lastViewed < %@ AND lastViewed > %@", Date() as NSDate, Date().subtract(days: 14) as NSDate)
        }
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension SearchViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }

        if searchString.isEmpty {
            performFetch(withPredicate: searchSegment.predicate)
            tableView.reloadData()
        } else {
            performFetch(withPredicate: NSPredicate(format: "displayName CONTAINS[cd] %@", searchString))
            tableView.reloadData()
        }
    }
}

// MARK: Stackable
extension SearchViewController: Stackable {
    func set(database: DatabaseEngine) {
        self.database = database
        
        let fetchRequest = NSFetchRequest<Subreddit>(entityName: Subreddit.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
        searchResultsController = NSFetchedResultsController<Subreddit>(fetchRequest: fetchRequest, managedObjectContext: database.viewContext, sectionNameKeyPath: "displayName", cacheName: nil)
    }
}

// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Animates tableView to the foreground with a drop down spring
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseIn, animations: {
            self.tableView.isHidden = false
            self.subscribedTableView.isHidden = true
            self.searchBarContainerViewHeightConstraint.priority = UILayoutPriority(rawValue: 997)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        // Animates segment controller fade in
        segmentController.alpha = 0.0
        segmentController.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.segmentController.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearch()
    }
}
