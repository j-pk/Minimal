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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewStatusCover: UIView!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    
    fileprivate var blockOperations: [BlockOperation] = []
    
    //NOTE: Sync happens when data is older than an hour, perhaps this can be configurable
    //Still need to figure this out and when to clear out old listings
    fileprivate var listingResultsController: NSFetchedResultsController<Listing> = {
        let fetchRequest = NSFetchRequest<Listing>(entityName: Listing.entityName)
        fetchRequest.predicate = NSPredicate(format: "mediaType != %@", ListingMediaType.none.rawValue as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "populatedDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController<Listing>(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.default.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    let collectionViewLayout: CHTCollectionViewWaterfallLayout = {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        layout.columnCount = 2
        layout.headerHeight = 10
        layout.footerHeight = 10
        layout.sectionInset = UIEdgeInsets(top: 54, left: 10, bottom: 0, right: 10)
        return layout
    }()
    var isPaginating: Bool = false
    
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
        
        self.headerView.backgroundColor = ThemeManager.default.primaryTheme
        self.headerViewStatusCover.backgroundColor = ThemeManager.default.primaryTheme
        
        listingResultsController.delegate = self
        performFetch()
        guard let isEmpty = listingResultsController.fetchedObjects?.isEmpty, isEmpty else { return }
        reloadCollectionView(forListing: nil)
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
    
    func reloadCollectionView(forListing listing: Listing?) {
        if let _ = listing {
            
        } else {
    
        }
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
            return CGSize(width: 200, height: 400)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popOverControllerSegue" {
            segue.destination.popoverPresentationController?.delegate = self
            segue.destination.preferredContentSize = CGSize(width: self.view.frame.width, height: 60)
            segue.destination.popoverPresentationController?.sourceRect = CGRect(x: 5, y: categoryButton.frame.maxY, width:0, height: 0)
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

extension MainViewController: CHTCollectionViewDelegateWaterfallLayout {
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return calculateSizeForItem(atIndexPath: indexPath)
    }
}

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
        let detailViewController: DetailViewController = UIViewController.make()
        detailViewController.preferredContentSize = CGSize(width: 0, height: 460)
        detailViewController.listing = listing
        return detailViewController
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard let categoryPopOverViewController = popoverPresentationController.presentedViewController as? CategoryPopoverViewController else { return }
        categoryButton.setTitle(categoryPopOverViewController.category.titleValue, for: .normal)
        categoryButton.sizeToFit()
        print(categoryPopOverViewController.category)
        //print(categoryPopOverViewController.timeFrame)
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if velocity < 0 {
            self.headerViewTopConstraint.priority = UILayoutPriority(999)
            UIView.animate(withDuration: 0.3, animations: {
                self.headerView.alpha = 0.0
                self.headerViewStatusCover.alpha = 0.0
                self.view.layoutIfNeeded()
            })
        } else if velocity > 0 {
            self.headerViewTopConstraint.priority = UILayoutPriority(997)
            UIView.animate(withDuration: 0.3, animations: {
                self.headerView.alpha = 1.0
                self.headerViewStatusCover.alpha = 1.0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            guard let lastViewedListing = self.listingResultsController.fetchedObjects?.last else { return }
            let blockOperation = BlockOperation {
                SyncManager.default.syncListingsPage(prefix: "", category: nil, timeframe: nil, after: lastViewedListing.after ?? "", completionHandler: { (error) in
                })
            }
            let queue = OperationQueue()
            queue.addOperation(blockOperation)
        }
    }
}
