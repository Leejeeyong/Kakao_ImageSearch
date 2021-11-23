//
//  DetailViewController.swift
//  KakaoImageSearchDemo
//
//  Created by JeeYong LEE on 2021/11/05.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {

    var document: NSDictionary = [:]
    var url: String = ""
    var imageUrl: String = ""
    var isHideImage: Bool = false
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var sitenameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWillDisappear(true)
        
        print(document)
        
        // 이미지 세팅
        setImage()
        
        if let siteName : String = self.document.value(forKeyPath: "display_sitename") as? String {
            sitenameLabel.text = "Sitename : " + siteName
        }
        if let dateTime : String = self.document.value(forKeyPath: "datetime") as? String {
            datetimeLabel.text = "DateTime : " + dateTime
        }

    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           navigationController?.setNavigationBarHidden(false, animated: animated)
       }
    
    func setImage() {
        imageView.downloaded(from: document.value(forKeyPath: "image_url") as! String)
    }
    
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }

