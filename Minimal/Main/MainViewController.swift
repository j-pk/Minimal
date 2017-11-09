//
//  MainViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class MainViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    fileprivate var blockOperations: [BlockOperation] = []
    
    //NOTE: Sync happens when data is older than an hour, perhaps this can be configurable
    //Still need to figure this out as far when to clear out old listings
    fileprivate var listingResultsController: NSFetchedResultsController<Listing> = {
        let fetchRequest = NSFetchRequest<Listing>(entityName: Listing.entityName)
        fetchRequest.predicate = NSPredicate(format: "isImage == true && populatedDate <= %@", Date().add(hours: 1) as CVarArg)
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
        layout.sectionInset = UIEdgeInsets(top: 44, left: 10, bottom: 0, right: 10)
        return layout
    }()
    var isPaginating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //SDImageCache.shared().config.shouldCacheImagesInMemory = false
        //SDImageCache.shared().config.shouldDecompressImages = false
        
        registerForPreviewing(with: self, sourceView: collectionView)
        
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = collectionViewLayout
        
        listingResultsController.delegate = self
        collectionView.prefetchDataSource = self
        performFetch()
    }
    
    override func didReceiveMemoryWarning() {
        SDImageCache.shared().clearMemory()
    }
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func performFetch() {
        do {
            try self.listingResultsController.performFetch()
            if self.listingResultsController.fetchedObjects?.count == 0 && self.isPaginating == false {
                SyncManager.default.syncListing(forUrlData: URLData(subreddit: nil, after: nil, limit: nil, category: nil), completionHandler: { error in
                    if let error = error {
                        print(error)
                    }
                })
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
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
        cell.layer.cornerRadius = 4.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let listingsCount = self.listingResultsController.fetchedObjects?.count else { return }
        guard indexPath.item == listingsCount - 1 && isPaginating == false else { return }
        isPaginating = true
        let listing = self.listingResultsController.object(at: indexPath)
        let urlData = URLData(subreddit: nil, after: listing.after, limit: 15, category: nil)
        SyncManager.default.syncListing(forUrlData: urlData, completionHandler: { error in
            if let error = error {
                print(error)
            } else {
                self.isPaginating = false
            }
        })
    }
}

extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map({ self.listingResultsController.object(at: $0).url.flatMap { URL(string: $0) }!  })
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        SDWebImagePrefetcher.shared().cancelPrefetching()
    }
}

extension MainViewController: CHTCollectionViewDelegateWaterfallLayout {
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let listing = self.listingResultsController.object(at: indexPath as IndexPath)
        guard let image = SDImageCache.shared().imageFromCache(forKey: listing.url) else { return CGSize.zero }
        
        return image.size
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
            let viewController = prepareCommitViewController(url: listing.url)
            return viewController
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true, completion: nil)
    }
    
    private func prepareCommitViewController(url: String?) -> UIViewController {
        let detailViewController = DetailViewController()
        detailViewController.preferredContentSize = CGSize(width: 0, height: 460)
        detailViewController.url = url
        return detailViewController
    }
}
