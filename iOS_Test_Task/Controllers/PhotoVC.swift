//
//  PhotoVC.swift
//  iOS_Test_Task
//
//  Created by Дмитрий Балантаев on 30.06.2022.
//

import UIKit
class PhotoVC: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    var selectedImage: Int = 0
    var images = [UIImage]()
    var sourceURL: String = ""
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentMode = .scaleAspectFit
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.backgroundColor = .black
        sv.minimumZoomScale = 1
        sv.maximumZoomScale = 6
        return sv
    }()
    
    private let img: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let countlbl: UILabel = {
       let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let closeBtn: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "close")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        return button
    }()

    private let sourceBtn: UIButton = {
        let btn = UIButton(type: .custom)
        let image = UIImage(named: "globe")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(openWebView), for: .touchUpInside)
        return btn
    }()
    
    @objc func closeBtnTapped(){
        self.dismissView()
    }
    
    @objc func openWebView() {
        pushView(viewController: WebViewVC())
        WebViewVC().loadRequest(urlString: sourceURL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        scrollView.delegate = self
        
        setupGesture()
        setupView()
        setupconstraint()
        loadImage()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setupGesture(){
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnScrollView(recognizer:)))
        singleTapGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapOnScrollView(recognizer:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
        
        let rightSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeFrom(recognizer:)))
        let leftSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeFrom(recognizer:)))
        
        rightSwipe.direction = .right
        leftSwipe.direction = .left
        
        scrollView.addGestureRecognizer(rightSwipe)
        scrollView.addGestureRecognizer(leftSwipe)
    }

    func setupView(){
        view.addSubview(scrollView)
        scrollView.addSubview(img)
        view.addSubview(countlbl)
        view.addSubview(closeBtn)
        view.addSubview(sourceBtn)
    }
    
    func setupconstraint(){
        scrollView.frame = view.bounds
        img.frame = scrollView.bounds

        countlbl.frame = CGRect(x: 20, y: view.frame.height - 50, width: view.frame.width - 40, height: 21)
        sourceBtn.frame = CGRect(x: 20, y: view.frame.height - 100, width: 25, height: 25)
        closeBtn.frame = CGRect(x: 20, y: (self.navigationController?.navigationBar.frame.size.height)!, width: 25, height: 25)
    }
    
    func loadImage(){
        img.image = images[selectedImage]
        countlbl.text = String(format: "%ld / %ld", selectedImage + 1, images.count)
    }
    
    @objc func handleSingleTapOnScrollView(recognizer: UITapGestureRecognizer){
        if closeBtn.isHidden {
            closeBtn.isHidden = false
            countlbl.isHidden = false
            sourceBtn.isHidden = false
        }else{
            closeBtn.isHidden = true
            countlbl.isHidden = true
            sourceBtn.isHidden = true
        }
    }
    
    @objc func handleDoubleTapOnScrollView(recognizer: UITapGestureRecognizer){
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
            closeBtn.isHidden = true
            countlbl.isHidden = true
            sourceBtn.isHidden = true
        } else {
            scrollView.setZoomScale(1, animated: true)
            closeBtn.isHidden = false
            countlbl.isHidden = false
            sourceBtn.isHidden = false
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = img.frame.size.height / scale
        zoomRect.size.width  = img.frame.size.width  / scale
        let newCenter = img.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    @objc func handleSwipeFrom(recognizer: UISwipeGestureRecognizer){
        let direction: UISwipeGestureRecognizer.Direction = recognizer.direction
        
        switch (direction) {
        case UISwipeGestureRecognizer.Direction.right:
            self.selectedImage -= 1
            
        case UISwipeGestureRecognizer.Direction.left:
            self.selectedImage += 1
        
        default:
            break
        }
        self.selectedImage = (self.selectedImage < 0) ? (self.images.count - 1):
            self.selectedImage % self.images.count
        
        loadImage()
        
    }
    
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer){
        print(recognizer)
        recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
        recognizer.scale = 1
        img.contentMode = .scaleAspectFit
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = img.image {
                let ratioW = img.frame.width / image.size.width
                let ratioH = img.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW:ratioH
                let newWidth = image.size.width*ratio
                let newHeight = image.size.height*ratio
                
                let left = 0.5 * (newWidth * scrollView.zoomScale > img.frame.width ? (newWidth - img.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > img.frame.height ? (newHeight - img.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
}
