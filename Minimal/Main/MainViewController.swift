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
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    
    private var blockOperations: [BlockOperation] = []
    private var themeManager = ThemeManager()
    
    //NOTE: Sync happens when data is older than an hour, perhaps this can be configurable
    //Still need to figure this out and when to clear out old listings
    private var listingResultsController: NSFetchedResultsController<Listing> = {
        let fetchRequest = NSFetchRequest<Listing>(entityName: Listing.entityName)
        fetchRequest.predicate = NSPredicate(format: "mediaType != %@", ListingMediaType.none.rawValue as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "populatedDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController<Listing>(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.default.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    private let collectionViewLayout: CHTCollectionViewWaterfallLayout = {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        layout.columnCount = 2
        layout.headerHeight = 10
        layout.footerHeight = 10
        layout.sectionInset = UIEdgeInsets(top: 54, left: 10, bottom: 0, right: 10)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        } else {
            print("3D Touch Not Available")
        }
        
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.prefetchDataSource = self

        listingResultsController.delegate = self
        performFetch()
        guard let isEmpty = listingResultsController.fetchedObjects?.isEmpty, isEmpty else { return }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPlayerStateForViewControllerTransition(isReturning: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPlayerStateForViewControllerTransition(isReturning: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory Warning")
    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func performFetch() {
        do {
            try listingResultsController.performFetch()
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func requestListings() {
        CoreDataManager.default.purgeRecords(entity: Listing.typeName, completionHandler: { (error) in
            if let error = error {
                print(error)
            } else {
                guard let user = User.current() else { return }
                let request = ListingRequest(subreddit: user.lastViewedSubreddit ?? "",
                                             category: user.categoryString,
                                             timeframe: user.timeframeString)
                let _ = ListingManager(request: request, completionHandler: { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                })
            }
        })
    }
    
    @IBAction func didPressTitleButton(_ sender: UIButton) {
        
    }
    
    func setPlayerStateForViewControllerTransition(isReturning: Bool) {
        collectionView.visibleCells.flatMap({ $0 as? MainCell }).forEach { (cell) in
            if cell.playerView.player != nil {
                isReturning ? cell.playerView.play() : cell.playerView.pause()
            }
        }
    }
    
    func calculateSizeForItem(atIndexPath indexPath: IndexPath) -> CGSize {        
        let listing = self.listingResultsController.object(at: indexPath)
        if let image = Cache.shared[listing.request] {
            return image.size
        } else if let imageWidth = listing.width as? CGFloat, let imageHeight = listing.height as? CGFloat {
            return CGSize(width: imageWidth, height: imageHeight)
        } else {
            print("Default CGSize")
            return CGSize(width: 320, height: 240)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popOverControllerSegue" {
            guard let user = User.current() else { return }
            segue.destination.popoverPresentationController?.delegate = self
            let height: CGFloat = user.timeframeString != nil ? 100 : 60
            segue.destination.preferredContentSize = CGSize(width: self.view.frame.width, height: height)
            segue.destination.popoverPresentationController?.sourceRect = CGRect(x: (categoryButton.frame.width / 2), y: categoryButton.frame.maxY * 2, width: 0, height: 0)
            segue.destination.popoverPresentationController?.backgroundColor = themeManager.theme.secondaryColor
            segue.destination.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            if let popOverController = segue.destination as? CategoryPopoverViewController {
                popOverController.category = user.category
                popOverController.timeframe = user.timeframe
            }
        } else if segue.identifier == "commentsControllerSegue" {
            if let commentsViewController = segue.destination as? CommentsViewController {
                guard let cell = sender as? MainCell else { return }
                guard let indexPath = collectionView.indexPath(for: cell) else { return }
                let listing = self.listingResultsController.object(at: indexPath)
                commentsViewController.hidesBottomBarWhenPushed = true 
                commentsViewController.listing = listing
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listingResultsController.fetchedObjects?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as! MainCell
        
        let listing = self.listingResultsController.object(at: indexPath)
        cell.configureCell(forListing: listing)

        return cell
    }
}

// MARK: UICollectionViewDataSourcePrefetching
extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map({ self.listingResultsController.object(at: $0).request })
        let preheater = Preheater(manager: Manager.shared)
        preheater.startPreheating(with: urls)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let preheater = Preheater(manager: Manager.shared)
        preheater.stopPreheating()
    }
}

// MARK: CHTCollectionViewDelegateWaterfallLayout
extension MainViewController: CHTCollectionViewDelegateWaterfallLayout {
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return calculateSizeForItem(atIndexPath: indexPath)
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
            //print("Insert Object: \(String(describing: newIndexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self, let newIndexPath = newIndexPath {
                        this.collectionView.insertItems(at: [newIndexPath])
                    }
                })
            )
        case .update:
            //print("Update Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self, let indexPath = indexPath {
                        this.collectionView.reloadItems(at: [indexPath])
                    }
                })
            )
        case .move:
            //print("Move Object: \(String(describing: indexPath))")
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
            //print("Delete Object: \(String(describing: indexPath))")
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

// MARK: UIViewControllerPreviewingDelegate
// Peek & Pop
extension MainViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = collectionView.indexPathForItem(at: location), let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            previewingContext.sourceRect = attributes.frame
            let listing = self.listingResultsController.object(at: indexPath)
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
        return detailViewController
    }
}

// MARK: UIPopoverPresentationControllerDelegate
// Category & Timeframe
extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard let categoryPopOverViewController = popoverPresentationController.presentedViewController as? CategoryPopoverViewController else { return }
        categoryButton.setTitle(categoryPopOverViewController.category.titleValue, for: .normal)
        categoryButton.sizeToFit()
        //NOTE: HMM
        CoreDataManager.default.performBackgroundTask { (moc) in
            do {
                guard let user = User.current() else { return }
                user.categoryString = categoryPopOverViewController.category.rawValue
                user.timeframeString = categoryPopOverViewController.timeframe?.rawValue
                
                if moc.hasChanges {
                    try moc.save()
                }
            } catch let error {
                print("Failed to save category: \(error)")
            }
        }
        requestListings()
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
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            guard let lastViewedListing = listingResultsController.fetchedObjects?.last else { return }
            guard let user = User.current() else { return }
            let blockOperation = BlockOperation {
                let request = ListingRequest(subreddit: user.lastViewedSubreddit ?? "",
                                             category: user.categoryString,
                                             timeframe: user.timeframeString,
                                             after: lastViewedListing.after ?? "",
                                             limit: 25,
                                             requestType: .paginate)
                
                ListingManager(request: request, completionHandler: { (error) in
                    if let error = error {
                        print(error)
                    }
                })
            }
            let queue = OperationQueue()
            queue.addOperation(blockOperation)
        }
    }
}
