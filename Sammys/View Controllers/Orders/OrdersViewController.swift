//
//  OrdersViewController.swift
//  Sammys
//
//  Created by Natanel Niazoff on 4/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class OrdersViewController: UIViewController {
//    var viewModel: OrdersViewModel!
//
//    // MARK: - IBOutlets
//    @IBOutlet var collectionView: UICollectionView!
//    @IBOutlet var activityIndicatorView: NVActivityIndicatorView! {
//        didSet {
//            activityIndicatorView.color = UIColor(named: "Mocha")!
//        }
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        title = "My Orders"
//
//        viewModel = OrdersViewModel(contextBounds: view.bounds)
//        activityIndicatorView.startAnimating()
//        viewModel.setData {
//            self.collectionView.reloadData()
//            self.activityIndicatorView.stopAnimating()
//        }
//    }
}

//extension OrdersViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return viewModel.numberOfSections
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel.numberOfRows
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let model = viewModel.cellViewModel(forRow: indexPath.row)
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier, for: indexPath)
//        model.commands[.configuration]?.perform(parameters: CommandParameters(cell: cell))
//        return cell
//    }
//}
//
//extension OrdersViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return viewModel.cellViewModel(forRow: indexPath.row).size
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        navigationController?.pushViewController(viewModel.orderViewController(for: indexPath), animated: true)
//    }
//}
//
//extension OrdersViewController: Storyboardable {
//    typealias ViewController = OrdersViewController
//}
