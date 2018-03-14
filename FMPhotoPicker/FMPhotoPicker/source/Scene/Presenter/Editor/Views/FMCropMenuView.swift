//
//  FMCropMenuView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

enum FMCropControl {
    case reset
    case rotate
}

class FMCropMenuView: UIView {
    private let collectionView: UICollectionView
    private let menuItems: [FMCropMenuItem]
    private let cropItems: [FMCroppable]
    
    public var didSelectCrop: (FMCroppable) -> Void = { _ in }
    public var didReceiveCropControl: (FMCropControl) -> Void = { _ in }
    
    private var selectedCrop: FMCroppable? {
        didSet {
            if let selectedCrop = selectedCrop {
                didSelectCrop(selectedCrop)
            }
        }
    }
    
    init(appliedCrop: FMCroppable?) {
        selectedCrop = appliedCrop
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 90)
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cropItems = [FMCrop.ratioSquare, FMCrop.ratio4x3, FMCrop.ratio16x9, FMCrop.ratioCustom, FMCrop.ratioOrigin]
        menuItems = [.cropReset, .cropRotation]
        
        super.init(frame: .zero)
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        collectionView.register(FMCropCell.classForCoder(), forCellWithReuseIdentifier: FMCropCell.reussId)
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        
//        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        
        backgroundColor = .red
    }
    
    func insert(toView parentView: UIView) {
        parentView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 90).isActive = true
        leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FMCropMenuView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return menuItems.count }
        if section == 1 { return cropItems.count }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FMCropCell.reussId, for: indexPath) as? FMCropCell
            else { return UICollectionViewCell() }
        
        if indexPath.section == 0 {
            // menu items
            cell.name.text = menuItems[indexPath.row].rawValue
            cell.imageView.image = menuItems[indexPath.row].icon()
        } else if indexPath.section == 1 {
            // crop items
            let cropItem = cropItems[indexPath.row]
            cell.name.text = cropItem.name()
            cell.imageView.image = cropItem.icon()
            
            if selectedCrop?.name() == cropItem.name() {
                cell.setSelected()
            }
        }
        
        return cell
    }
}
extension FMCropMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                didReceiveCropControl(.reset)
                selectedCrop = kDefaultCropName
                collectionView.reloadData()
            } else if indexPath.row == 1 {
                didReceiveCropControl(.rotate)
            }
        } else if indexPath.section == 1 {
            if let cell = collectionView.cellForItem(at: indexPath) as? FMCropCell {
                let prevCropItem = selectedCrop
                selectedCrop = cropItems[indexPath.row]
                cell.setSelected()
                
                if let prevCropItem = prevCropItem,
                    let prevRow = cropItems.index(where: { $0.name() == prevCropItem.name() }) {
                    collectionView.reloadItems(at: [IndexPath(row: prevRow, section: 1)])
                }
            }
        }
    }
}
