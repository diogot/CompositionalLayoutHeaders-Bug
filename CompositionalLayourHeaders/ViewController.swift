//
//  ViewController.swift
//  CompositionalLayourHeaders
//
//  Created by Diogo Tridapalli on 11/05/21.
//

import UIKit

final class ViewController: UIViewController {

    private lazy var collectionViewController = CollectionViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        let redView = UIView()
        redView.backgroundColor = .orange
        redView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(redView)


        let collectionView: UIView = collectionViewController.view
        addChild(collectionViewController)
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            redView.topAnchor.constraint(equalTo: view.topAnchor),
            redView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            redView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            redView.heightAnchor.constraint(equalToConstant: 576),
            collectionView.topAnchor.constraint(equalTo: redView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionViewController.didMove(toParent: self)
    }

}
