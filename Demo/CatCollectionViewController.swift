//
//  CatCollectionViewController.swift
//  Demo
//
//  Created by Peter Pan on 2022/2/16.
//  Copyright © 2022 SHIH-YING PAN. All rights reserved.
//

import UIKit
import Kingfisher

class CatCollectionViewController: UICollectionViewController {
    
    var orangeCatIds = [String]()
    var hatCatIds = [String]()
    var catSections = [[String]]()
    let pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = generateLayout()
        fetchCats()
        
    }
    
    func addDataForInfiniteScroll() {
        guard !orangeCatIds.isEmpty else { return }
        let firstId = orangeCatIds.first!
        let lastId = orangeCatIds.last!
        orangeCatIds.insert(lastId, at: 0)
        orangeCatIds.append(firstId)
        
        
    }
    
    func fetchCats() {
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [self] in
            orangeCatIds = [
                "595f280f557291a9750ebfb7",
                "595f2809557291a9750ebf31",
                "595f2810557291a9750ebfd7"
            ]
            hatCatIds = [
                "6010b5cb47d128001b7bbb7c",
                "595f280e557291a9750ebfa6",
                "595f2809557291a9750ebf35"
            ]
            addDataForInfiniteScroll()
            catSections = [orangeCatIds, hatCatIds]
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
            addPageControl()

        }
    }
    
    func addPageControl() {
        guard let layoutAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) else { return }
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.layer.zPosition = 1
        pageControl.numberOfPages = orangeCatIds.count - 2
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .orange
        collectionView.addSubview(pageControl)
        pageControl.centerXAnchor.constraint(equalTo: collectionView.frameLayoutGuide.centerXAnchor).isActive = true
        let constant = layoutAttributes.frame.maxY
        pageControl.bottomAnchor.constraint(equalTo: collectionView.contentLayoutGuide.topAnchor, constant: constant).isActive = true
        pageControl.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
    }
    
    @objc func changePage(_ sender: UIPageControl) {
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage+1, section: 0), at: .left, animated: true)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        
        UICollectionViewCompositionalLayout { [unowned self] section, environment in
            if section == 0 {
                return horizontalScrollLayoutSection
            } else {
                return verticalScrollLayoutSection
            }
        }
    }
    
    var horizontalScrollLayoutSection: NSCollectionLayoutSection {
        let sectionMargin = 15.0
        let itemInset = 5.0
        let pageWidth = collectionView.bounds.width - sectionMargin * 2
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemInset, bottom: 0, trailing: itemInset)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(pageWidth), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        section.visibleItemsInvalidationHandler = { [unowned self] visibleItems, point, environment in
            if var page = Int(exactly: (point.x + sectionMargin) / pageWidth) {
                let maxIndex = orangeCatIds.indices.max()!
                if page == maxIndex {
                    page = 1
                } else if page == 0 {
                    page = maxIndex - 1
                }
                let realPage = page - 1
                if pageControl.currentPage != realPage {
                    pageControl.currentPage = realPage
                    collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .left, animated: false)
                }
            }
        }
        return section
    }
       
    var verticalScrollLayoutSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return catSections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catSections[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatCollectionViewCell.reuseIdentifier, for: indexPath) as! CatCollectionViewCell
        let catId = catSections[indexPath.section][indexPath.item]
        let url = URL(string: "https://cataas.com/cat/\(catId)")
        cell.imageView.kf.setImage(with: url)
        return cell
    }
    
    
}
