//
//  CollectionViewController.swift
//  CompositionalLayourHeaders
//
//  Created by Diogo Tridapalli on 11/05/21.
//

import UIKit

final class CollectionViewController: UICollectionViewController {
    private lazy var dataSource = makeDataSource(collectionView: collectionView)

    init() {
        super.init(collectionViewLayout: makeLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = .init(top: 60, left: 0, bottom: 60, right: 0)
        collectionView.contentInsetAdjustmentBehavior = .never

        apply(title: nil, items: 20)
    }

    private func apply(title: String?, items: Int, twoSections: Bool = false) {
        let section = Section(title: title, items: Array(0...items-1).map(Item.init))
        var snapshot = Snapshot()
        snapshot.appendSections([section])
        snapshot.appendItems(section.items, toSection: section)
        if twoSections {
            let section2 = Section(title: title, items: Array(items-1...2*items-1).map(Item.init))
            snapshot.appendSections([section2])
            snapshot.appendItems(section2.items, toSection: section2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.dataSource.apply(snapshot)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let items = collectionView.numberOfItems(inSection: 0)
        guard items >= 10, items < 30, collectionView.numberOfSections == 1 else {
            return
        }
        if indexPath.item == items - 1 {
            let next = items + 10
            apply(title: nil, items: next)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            apply(title: nil, items: 20)
        case 1:
            apply(title: "Some title", items: 30)
        case 2:
            apply(title: "Other title", items: 20, twoSections: true)
        default:
            break
        }
    }
}

struct Section: Hashable {
    let title: String?
    let items: [Item]
}

struct Item: Hashable {
    let number: Int
}

typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
private func makeDataSource(collectionView: UICollectionView) -> DataSource {
    collectionView.register(Cell.self, forCellWithReuseIdentifier: cellType)
    collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: supplementaryType, withReuseIdentifier: supplementaryType)
    let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType, for: indexPath) as! Cell
        cell.label.text = String(item.number)
        return cell
    }
    dataSource.supplementaryViewProvider = { [weak dataSource] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) in
        let titleView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: supplementaryType, for: indexPath) as! TitleSupplementaryView
        guard let sections = dataSource?.snapshot().sectionIdentifiers, let title = sections[indexPath.section].title else {
            titleView.layoutMargins = .zero
            titleView.label.text = nil
            return titleView
        }

        titleView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        titleView.label.text = title
        return titleView
    }

    return dataSource
}

private let itemSpacing: CGFloat = 48
private let supplementaryType = "title"
private let cellType = "cell"
private func makeLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .estimated(330)) // 320 is the limit to ok, .absolute don't make difference
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
    group.interItemSpacing = .fixed(itemSpacing)

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = itemSpacing
    section.contentInsets = .init(top: 0, leading: itemSpacing, bottom: 0, trailing: itemSpacing)
    let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .estimated(44))
    section.boundarySupplementaryItems.append(
        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: titleSize, elementKind: supplementaryType,
                                                    alignment: .top, absoluteOffset: .zero)
    )
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.contentInsetsReference = .none
    configuration.interSectionSpacing = itemSpacing

    return UICollectionViewCompositionalLayout(section: section, configuration: configuration)
}

typealias Cell = CommonCell
final class CommonCell: UICollectionViewCell {
    let label = UILabel()
    let image = UIView()

    private var focusedConstraints = [NSLayoutConstraint]()
    private var unfocusedConstraints = [NSLayoutConstraint]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
        image.backgroundColor = .blue
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        image.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 9 / 16),
            image.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            label.centerYAnchor.constraint(equalTo: image.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: image.centerXAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            image.backgroundColor = .red
        } else {
            image.backgroundColor = .blue
        }
    }
}

final class TitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
