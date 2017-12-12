// VerticalRatingView.swift
//
// Copyright (c) 2013 Alex Bofu
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

@IBDesignable
final class VerticalRatingView: UIView {
    
    fileprivate var emptyImageView = UIImageView()
    fileprivate var fullImageView = UIImageView()
    fileprivate var rateLabel: UILabel?
    fileprivate var imageContentMode: UIViewContentMode = .scaleAspectFit
    
    @IBInspectable open var floatRatings: Bool = false

    @IBInspectable open var isRateHidden: Bool = false
    
    @IBInspectable open var rateLabelBackgroundColor: UIColor = UIColor(red:0.71, green:0.57, blue:0.36, alpha:1.0)

    @IBInspectable open var editable: Bool = true
    
    @IBInspectable open var fullImage: UIImage? {
        didSet {
            fullImageView.image = fullImage?.withRenderingMode(.alwaysOriginal)
            fullImageView.contentMode = imageContentMode
            emptyImageView.image = fullImage?.withRenderingMode(.alwaysTemplate)
            emptyImageView.contentMode = imageContentMode
            emptyImageView.tintColor = .lightGray
            refresh()
        }
    }
    
    @IBInspectable open var minRating: Int  = 0 {
        didSet {
            rating = rating < Float(minRating) ? Float(minRating) : Float(maxRating)
            refresh()
        }
    }
    
    @IBInspectable open var maxRating: Int = 5 {
        didSet {
            rating = rating < Float(minRating) ? Float(minRating) : Float(maxRating)
            refresh()
        }
    }
    
    @IBInspectable open var rating: Float = 2.5 {
        didSet {
            if rating != oldValue {
                refresh()
            }
        }
    }
    
    //MARK: - memory management
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - private
    fileprivate func removeImageViews() {
        fullImageView.removeFromSuperview()
    }
    
    fileprivate func refresh() {
        if rating >= Float(maxRating) {
            fullImageView.layer.mask = nil
            fullImageView.isHidden = false
        } else if rating > Float(minRating) && rating < Float(maxRating) {
            let maskLayer = CALayer()
            maskLayer.frame = CGRect(x: 0, y: fullImageView.frame.height - (CGFloat(rating) / CGFloat(maxRating) * fullImageView.frame.height), width: fullImageView.frame.size.width, height: (CGFloat(rating) / CGFloat(maxRating)) * fullImageView.frame.size.height)
            maskLayer.backgroundColor = UIColor.black.cgColor
            fullImageView.layer.mask = maskLayer
            fullImageView.isHidden = false
        } else {
            fullImageView.layer.mask = nil;
            fullImageView.isHidden = true
        }
        
        if !isRateHidden && rateLabel != nil {
            if floatRatings {
                rateLabel!.text = "\(round(min(Float(maxRating), rating) * 10) / 10)"
            } else {
                rateLabel!.text = "\(Int(min(maxRating, Int(rating))))"
            }
        }
    }
    
    fileprivate func updateLocation(_ touch: UITouch) {
        guard editable else { return }
        
        let touchLocation = touch.location(in: self)
        var newRating: Float = 0
        
        newRating = Float(maxRating) - Float(touchLocation.y * CGFloat(maxRating) / self.frame.height)
        
        if floatRatings {
            rating = newRating < Float(minRating) ? Float(minRating) : newRating
        } else {
            let rounded: Double = Double(round(newRating * 10) / 10).truncatingRemainder(dividingBy: 1)
            
            if !(rounded < 0.5)  {
               newRating += 1
            }
            
            let newRatingInt = Int(newRating) < Int(minRating) ? Int(minRating) : Int(newRating)
            rating = Float(newRatingInt)
        }
        
        refresh()
    }
    
    fileprivate func addGrading() {
        if !isRateHidden {
            rateLabel = UILabel()
            rateLabel!.text = "\(round(rating * 10) / 10)"
            rateLabel!.textColor = .white
            rateLabel!.textAlignment = .center
            rateLabel!.backgroundColor = rateLabelBackgroundColor
            rateLabel!.clipsToBounds = true
            rateLabel!.frame = CGRect(x: self.frame.width / 2 - self.frame.width / 8, y: self.frame.height / 2 - self.frame.width / 16, width: self.frame.width / 4, height: self.frame.width / 4)
            rateLabel!.layer.cornerRadius = self.frame.width / 8
            rateLabel!.font = UIFont.boldSystemFont(ofSize: rateLabel!.bounds.size.width / 2 - 2)
            self.addSubview(rateLabel!)
        }
    }

    // MARK: - override methods
    override open func layoutSubviews() {
        super.layoutSubviews()
        emptyImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        fullImageView.frame = emptyImageView.frame
        
        addSubview(emptyImageView)
        addSubview(fullImageView)
        addGrading()
        refresh()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        updateLocation(touch)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        updateLocation(touch)
    }
}
