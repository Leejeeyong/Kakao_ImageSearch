//
//  ViewController.swift
//  KakaoImageSearchDemo
//
//  Created by JeeYong LEE on 2021/11/05.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchResultHelperView: UIStackView!
    @IBOutlet var btnPreviousPage: UIButton!
    @IBOutlet var btnNextPage: UIButton!
    @IBOutlet var lblCurrentPage: UILabel!
    @IBOutlet var svSearchBar: UIStackView!
    
    var apiReulstDocument: NSArray = []
    var searchOption = SearchOption()
    var isEndPage: Bool = false
    var isHideSearchHelperView: Bool = false
    var isNoSearch: Bool = false

    var isNext: Bool = false
    
    enum Mode {
        case view
        case select
    }
    var collectionViewMode: Mode = .view {
        didSet {
            switch collectionViewMode {
            case .view:
                collectionView.allowsMultipleSelection = false
                break
                
            case .select:
                collectionView.allowsMultipleSelection = true
                break
            }
        }
    }
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
    
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        collectionView.collectionViewLayout = layout
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.searchResultHelperView.constraints[0].constant = 0
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        viewWillAppear(false)
        
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .left {
            if !isEndPage {
                isNext = true
                searchOption.page += 1
                search()
            } else {
                print("마지막 페이지")
            }
            
        } else if gesture.direction == .right {
            if searchOption.page > 1 {
                isNext = false
                searchOption.page -= 1
                search()
            } else {
                print("첫번째 페이지")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailImage":
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.document = apiReulstDocument[sender as! Int] as! NSDictionary
            break
        default:
            print("no way")
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // 컬렉션뷰 상하 제스처
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isHideSearchHelperView && scrollView.contentOffset.y >= 30 {
            isHideSearchHelperView.toggle()
            hideSearchHelperView(isHideSearchHelperView)
        } else if isHideSearchHelperView && scrollView.contentOffset.y < 30 {
            isHideSearchHelperView.toggle()
            hideSearchHelperView(isHideSearchHelperView)
        }
    }
    
    func hideSearchHelperView(_ isHide: Bool) {
        self.searchResultHelperView.layoutIfNeeded() // force any pending operations to finish
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let height: CGFloat = isHide ? 0 : 40
            self.searchResultHelperView.constraints[0].constant = height
            self.searchResultHelperView.layoutIfNeeded()
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query: String = searchBar.searchTextField.text!
        
        searchOption.query = query
        searchOption.page = 1
        self.view.endEditing(true)
        search()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if isNoSearch {
            return
        }
    }
    
    func search() {
        // 검색 키워드 앞뒤 공백 트림
        searchOption.query = searchOption.query.trimmingCharacters(in: .whitespacesAndNewlines)
        //        searchBar.searchTextField.text = searchOption.query
        
        let apiRequest = APIResquest()
        
        apiRequest.sendRequest(searchOption) { responseObject, error in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "error")
                return
            }

            self.apiReulstDocument = responseObject.value(forKeyPath: "documents")! as! NSArray
            
            self.isEndPage = responseObject.value(forKeyPath: "meta.is_end")! as! Int == 0 ? false : true
            
            DispatchQueue.main.async {

                self.lblCurrentPage.text = String( self.searchOption.page) + " 페이지"

                if self.isEndPage || self.searchOption.page >= 50 {
                    // 다음 페이지 버튼 비활성화
                    self.btnNextPage.isEnabled = false
                } else {
                    self.btnNextPage.isEnabled = true
                }
                
                if self.searchOption.page <= 1 {
                    // 이전 페이지 버튼 비활성화
                    self.btnPreviousPage.isEnabled = false
                } else {
                    self.btnPreviousPage.isEnabled =  true
                }

                var side: CATransitionSubtype = CATransitionSubtype.fromRight
                if self.isNext {
                    side = CATransitionSubtype.fromRight
                } else {
                    side = CATransitionSubtype.fromLeft
                }
                
                self.collectionView.layer.add(self.swipeTransitionToLeftSide(side), forKey: nil)
                
                
                self.collectionView.reloadData()
                
                // search result helper view extend
                self.view.layoutIfNeeded() // force any pending operations to finish
                
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    
                    self.searchResultHelperView.constraints[0].constant = 40
                    
                    self.view.layoutIfNeeded()
                })
                
                if !self.isNoSearch {
                    self.isNoSearch.toggle()
                }
            }
        }
    }
    
    func swipeTransitionToLeftSide(_ side: CATransitionSubtype) -> CATransition {
        let transition = CATransition()
        transition.startProgress = 0.0
        transition.endProgress = 1.0
        transition.type = CATransitionType.push
        transition.subtype = side
        transition.duration = 0.3
        
        return transition
    }
    
    @IBAction func btnPreviousPage(_ sender: UIButton) {
        isNext = false
        searchOption.page -= 1
        search()
    }
    
    @IBAction func btnNextPage(_ sender: UIButton) {
        isNext = true
        searchOption.page += 1
        search()
    }

}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionViewMode {
        case .view:
            collectionView.deselectItem(at: indexPath, animated: true)
            performSegue(withIdentifier: "detailImage", sender: indexPath[1])
            break
        default:
            break
        }
    }

}


extension MainViewController: UICollectionViewDataSource {
    
    // 컬렉션뷰 갱신마다 컬렉션뷰 셀의 개수 지정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(apiReulstDocument.count != 0){
            return searchOption.size
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.configure(with: (apiReulstDocument[indexPath[1]] as! NSDictionary).value(forKey: "thumbnail_url") as! String)
        
        return cell;
    }
    
}


extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
}

struct SearchOption {
    var size: Int
    var sort: String
    var page: Int
    var query: String
    
    init() {
        size = 30
        sort = "accuracy"
        page = 1
        query = ""
    }
}

