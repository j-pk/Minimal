//
//  MainViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import CoreData
import Nuke

class MainViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    
    private var blockOperations: [BlockOperation] = []
    private let themeManager = ThemeManager()
    private var database: DatabaseEngine?
    private var subredditString: String?
    private var listingResultsController: NSFetchedResultsController<Listing>!
    private var model: MainModel?
    private var displayOption: DisplayOptions!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        } else {
            posLog(message: "3D Touch Not Available", category: MainViewController.typeName)
        }
        
        // NUKE
        ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
        
        if let defaults = Defaults.retrieve() {
            displayOption = DisplayOptions(rawValue: defaults.displayOption)
        }
        
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = displayOption.layout
        collectionView.prefetchDataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        let refreshYAxis = headerView.frame.height - view.safeAreaLayoutGuide.layoutFrame.size.height
        refreshControl.bounds = CGRect(x: refreshControl.bounds.origin.x, y: refreshYAxis, width: refreshControl.bounds.size.width, height: refreshControl.bounds.size.height)
        collectionView.refreshControl = refreshControl
        
        performFetch()
        
        if let searchViewController = tabBarController?.fetch(viewController: SearchViewController.self) {
            searchViewController.delegate = self
        }
        
        headerView.addShadow()
        model?.fetchLastViewedSubredditData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPlayerStateForViewControllerTransition(isReturning: true)

        if let defaults = Defaults.retrieve(), displayOption != DisplayOptions(rawValue: defaults.displayOption) {
            displayOption = DisplayOptions(rawValue: defaults.displayOption)
            UIView.performWithoutAnimation {
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.collectionViewLayout = displayOption.layout
            }
        }
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPlayerStateForViewControllerTransition(isReturning: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.shared.removeAll()
        posLog(message: "Memory Warning", category: MainViewController.typeName)
    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    @IBAction func didPressCategoryButton(_ sender: UIButton) {
        model?.buildControllerForCategoryAndTimeframe()
    }
    
    @IBAction func didPressTitleButton(_ sender: UIButton) {
        model?.buildControllerForRecentlyViewedSubreddits()
    }
    
    func performFetch() {
        do {
            try listingResultsController.performFetch()
        } catch let error {
            posLog(error: error)
        }
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        model?.requestListings()
        sender.endRefreshing()
    }
    
    func setPlayerStateForViewControllerTransition(isReturning: Bool) {
        collectionView.visibleCells.compactMap({ $0 as? MediaCascadeCell }).forEach { (cell) in
            if cell.playerView.player != nil {
                isReturning ? cell.playerView.play() : cell.playerView.pause()
            }
        }
    }
    
    func calculateSizeForItem(atIndexPath indexPath: IndexPath) -> CGSize {        
        let listing = self.listingResultsController.object(at: indexPath)
        if let image = ImageCache.shared[listing.request] {
            return image.size
        } else if let imageWidth = listing.width as? CGFloat, let imageHeight = listing.height as? CGFloat {
            return CGSize(width: imageWidth, height: imageHeight)
        } else {
            posLog(message: "Default CGSize", category: MainViewController.typeName)
            return CGSize(width: 320, height: 240)
        }
    }
    
    func configureAnnotationForItem(atIndexPath indexPath: IndexPath) -> String? {
        let listing = self.listingResultsController.object(at: indexPath)
        let annotations = [listing.title, listing.subredditNamePrefixed, listing.author, String(listing.score)].compactMap({ $0 }).joined(separator: "\n")
        return annotations
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "commentsControllerSegue" {
            if let commentsViewController = segue.destination as? CommentsViewController {
                guard let cell = sender as? UICollectionViewCell else { return }
                guard let indexPath = collectionView.indexPath(for: cell) else { return }
                let listing = self.listingResultsController.object(at: indexPath)
                commentsViewController.hidesBottomBarWhenPushed = true
                commentsViewController.listing = listing
                commentsViewController.database = database
                commentsViewController.delegate = self
            }
        }
    }
    
    func transitionToCommentsViewController(with segue: UIStoryboardSegue) { }
}

// MARK: Stackable
extension MainViewController: Stackable {
    func set(database: DatabaseEngine) {
        self.database = database       
        
        let fetchRequest = NSFetchRequest<Listing>(entityName: Listing.entityName)
        fetchRequest.predicate = NSPredicate(format: "mediaType != %@", ListingMediaType.none.rawValue as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "populatedDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController<Listing>(fetchRequest: fetchRequest, managedObjectContext: database.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        listingResultsController = fetchedResultsController
        
        model = MainModel(database: database, delegate: self)
    }
}

extension MainViewController: MainListingDelegate {
    func presentCategotyAndTime(with controller: UIAlertController) {
        present(controller, animated: true, completion: nil)
    }
    
    func presentRecentViewedSubreddits(with controller: UIAlertController) {
        present(controller, animated: true, completion: nil)
    }
    
    func lastViewedSubreddit(data: (subreddit: String, categoryAndTimeFrame: String)) {
        titleButton.setTitle(data.subreddit, for: UIControl.State())
        categoryButton.setTitle(data.categoryAndTimeFrame, for: UIControl.State())
    }
    
    func updateViewWithRequestedListings(for subreddit: String, with categoryAndTimeFrame: String) {
        DispatchQueue.main.async {
            self.titleButton.setTitle(subreddit, for: UIControl.State())
            self.categoryButton.setTitle(categoryAndTimeFrame, for: UIControl.State())
            self.categoryButton.sizeToFit()
            self.collectionView.reloadData()
        }
    }
}

// MARK: UISearchActionDelegate
extension MainViewController: SubredditSelectionProtocol {
    func didSelect(subreddit: Subreddit) {
        model?.updateUserAndListings(forSubreddit: subreddit, subredditId: nil, category: .hot, timeFrame: nil)
    }
    
    func didSelect(defaultSubreddit: DefaultSubreddit) {
        model?.updateUserAndListings(forSubreddit: nil, subredditId: "\(defaultSubreddit.rawValue)", category: .hot, timeFrame: nil)
    }
}

extension MainViewController: UIViewTappableDelegate {
    func didTapView(sender: UITapGestureRecognizer, data: [String: Any?]) {
        if let subredditId = data["subredditId"] as? String  {
            model?.updateUserAndListings(forSubreddit: nil, subredditId: subredditId, category: .hot, timeFrame: nil)
        }
    }
}

extension MainViewController: ActionViewDelegate {
    func didSelectMoreButton(sender: UIButton, controller: UIAlertController) {
        present(controller, animated: true, completion: nil)
    }
    
    func didSelectCommentButton(sender: UIButton, listing: Listing?) {
        guard let listing = listing else { return }
        let commentsViewController: CommentsViewController = UIViewController.make(storyboard: .main)
        commentsViewController.hidesBottomBarWhenPushed = true
        commentsViewController.listing = listing
        commentsViewController.database = database
        commentsViewController.delegate = self
        navigationController?.pushViewController(commentsViewController, animated: true)
    }
}

// MARK: UIViewControllerPreviewingDelegate
// Peek & Pop
extension MainViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = collectionView.indexPathForItem(at: location), let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            previewingContext.sourceRect = attributes.frame
            let listing = listingResultsController.object(at: indexPath)
            let viewController = prepareCommitViewController(listing: listing)
            return viewController
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        NotificationCenter.default.post(name: .isPopped, object: nil)
        present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    private func prepareCommitViewController(listing: Listing?) -> UIViewController {
        let detailViewController: DetailViewController = UIViewController.make(storyboard: .main)
        detailViewController.preferredContentSize = CGSize(width: 0, height: 460)
        detailViewController.listing = listing
        detailViewController.database = database
        detailViewController.delegate = self
        return detailViewController
    }
}

// MARK: UIScrollViewDelegate
extension MainViewController: UIScrollViewDelegate {
    // Header View
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if velocity < 0 {
            headerViewTopConstraint.priority = UILayoutPriority(999)
            UIView.animate(withDuration: 0.3, animations: {
                self.headerStackView.alpha = 0.0
                self.view.layoutIfNeeded()
            })
        } else if velocity > 0 {
            headerViewTopConstraint.priority = UILayoutPriority(997)
            UIView.animate(withDuration: 0.3, animations: {
                self.headerStackView.alpha = 1.0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y + 150 >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            guard let lastViewedListing = listingResultsController.fetchedObjects?.last else { return }
            model?.paginate(forLastViewedListing: lastViewedListing)
        }
    }
}

// MARK: UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listingResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let listing = listingResultsController.object(at: indexPath)
        switch displayOption {
        case .standard?:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCompactCell.identifier, for: indexPath) as! MediaCompactCell
            cell.configureCell(forListing: listing, with: model)
            cell.actionView.delegate = self
            cell.delegate = self
            return cell
            
        case .card?:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaAnnotatedCell.identifier, for: indexPath) as! MediaAnnotatedCell
            cell.configureCell(forListing: listing, with: model)
            cell.annotationView.delegate = self
            cell.actionView.delegate = self
            return cell
            
        case .gallery?:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCascadeCell.identifier, for: indexPath) as! MediaCascadeCell
            cell.configureCell(forListing: listing, with: model)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: CHTCollectionViewDelegateWaterfallLayout
extension MainViewController: CHTCollectionViewDelegateWaterfallLayout {
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if displayOption == .card || displayOption == .gallery {
            return calculateSizeForItem(atIndexPath: indexPath)
        } else {
            let listing = listingResultsController.object(at: indexPath)
            guard let title = listing.title else { return CGSize.zero}
            let textview = UITextView()
            
            textview.text = title
            textview.font = UIFont.systemFont(ofSize: 12)
            
            let actualsize = textview.sizeThatFits(CGSize(width: collectionView.frame.size.width - 85, height: CGFloat.greatestFiniteMagnitude))
            
            return CGSize(width: collectionView.frame.size.width - 10, height: actualsize.height + 90)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, annotationForItemAtIndexPath indexPath: IndexPath) -> String? {
        return displayOption == .card ? configureAnnotationForItem(atIndexPath: indexPath) : nil
    }
}

// MARK: UICollectionViewDataSourcePrefetching
extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map({ listingResultsController.object(at: $0).request })
        let preheater = ImagePreheater(pipeline: ImagePipeline.shared, maxConcurrentRequestCount: 5)
        preheater.startPreheating(with: urls)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let preheater = ImagePreheater(pipeline: ImagePipeline.shared, maxConcurrentRequestCount: 5)
        preheater.stopPreheating()
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension MainViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.numberOfItems(inSection: 0)
        self.collectionView.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            //posLog(message: "Insert Object: \(String(describing: newIndexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self, let newIndexPath = newIndexPath {
                        this.collectionView.insertItems(at: [newIndexPath])
                    }
                })
            )
        case .update:
            //posLog(message: "Update Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self, let indexPath = indexPath {
                        this.collectionView.reloadItems(at: [indexPath])
                    }
                })
            )
        case .move:
            //posLog(message: "Move Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self, let indexPath = indexPath, let newIndexPath = newIndexPath {
                        if indexPath != newIndexPath {
                            this.collectionView.moveItem(at: indexPath, to: newIndexPath)
                        }
                    }
                })
            )
        case .delete:
            //posLog(message: "Delete Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self, let indexPath = indexPath {
                        this.collectionView.deleteItems(at: [indexPath])
                    }
                })
            )
        }
    }
}

