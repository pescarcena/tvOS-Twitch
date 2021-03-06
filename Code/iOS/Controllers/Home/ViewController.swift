// Copyright (c) 2015 Benoit Layer
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import ReactiveCocoa
import DataSource

class ViewController: UIViewController {
	
	private let cellIdentifierGame = "GameCellIdentifier"
	private var cellSpacing: CGFloat = 10.0
	private let numberOfCellsInARow = 2
	private var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var loadingStateView: LoadingStateView!
	
	let gameListViewModel = GamesList.ViewModelType(.GamesTop(page: 0), transform: GamesList.gameToViewModel)
	let collectionDataSource = CollectionViewDataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.whiteColor()
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .Vertical
		let inset = cellSpacing
		let gameCellWidth = (self.view.bounds.maxX - inset * 2.0 - cellSpacing) / 2.0
		layout.itemSize = CGSize(width: gameCellWidth, height: gameCellWidth/Constants.gameImageRatio)
		layout.sectionInset = UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
		layout.minimumInteritemSpacing = cellSpacing
		layout.minimumLineSpacing = cellSpacing
		
		
		collectionDataSource.reuseIdentifierForItem = { _, item in
			if let item = item as? ReuseIdentifierProvider {
				return item.reuseIdentifier
			}
			fatalError()
		}
		collectionDataSource.dataSource.innerDataSource.value = gameListViewModel.dataSource
		collectionDataSource.collectionView = collectionView
		collectionView.dataSource = collectionDataSource
		
		collectionView.registerNib(GameCell.nib, forCellWithReuseIdentifier: GameCell.identifier)
		collectionView.registerNib(LoadMoreCell.nib, forCellWithReuseIdentifier: LoadMoreCell.identifier)
		collectionView.collectionViewLayout = layout
		collectionView.delegate = self
		
		loadingStateView.loadingState <~ gameListViewModel.paginator.loadingState
		loadingStateView.isEmpty <~ gameListViewModel.viewModels.producer.map { $0.isEmpty }
		loadingStateView.retry = { [weak self] in self?.gameListViewModel.loadMore() }
	}
}

extension ViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		if collectionDataSource.dataSource.itemAtIndexPath(indexPath) is LoadMoreCellItem {
			gameListViewModel.loadMore()
		}
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		if let _ = collectionDataSource.dataSource.itemAtIndexPath(indexPath) as? GameCellViewModel {
		}
	}
}

