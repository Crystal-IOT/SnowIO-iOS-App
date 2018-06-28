//
//  ClusetAnnotationView.swift
//  Snow IO
//
//  Created by Steven F. on 11/06/2018.
//  Copyright © 2018 Steven F. All rights reserved.
//

import MapKit


// MARK : The annotation view representing multiple annotations in a clustered annotation.
class ClusterAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// - Tag: CustomCluster
    override var annotation: MKAnnotation? {
        didSet {
            if let cluster = annotation as? MKClusterAnnotation {
                let totalElements = cluster.memberAnnotations.count
                
                if countElem(annotationType: .beacon) > 0 {
                    let interestCount = countElem(annotationType: .interest)
                    image = drawRatioFromToElement(fromCount: interestCount, toCount: totalElements, .interest, .beacon)
                }
                else {
                    if countElem(annotationType: .station) > 0 {
                        let userCount = countElem(annotationType: .user)
                        image = drawRatioFromToElement(fromCount: userCount, toCount: totalElements, .user, .station)
                    }
                    else if countElem(annotationType: .interest) > 0 {
                        image = drawCount(count: totalElements, annotationType: .interest)
                    }
                    else if countElem(annotationType: .beacon) > 0 {
                        image = drawCount(count: totalElements, annotationType: .beacon)
                    }
                    else {
                        image = drawCount(count: totalElements, annotationType: .user)
                    }
                }
            }
        }
    }
    
    private func drawRatioFromToElement(fromCount: Int, toCount: Int, _ annotationFraction: basicAnnotationType, _ annotationWhole: basicAnnotationType) -> UIImage {
        return drawRatio(fromCount,
                         to: toCount,
                         fractionColor: annotationFraction.markerTintColor,
                         wholeColor: annotationWhole.markerTintColor)
    }
    
    private func drawCount(count: Int, annotationType: basicAnnotationType) -> UIImage {
        return drawRatio(0, to: count, fractionColor: nil, wholeColor: annotationType.markerTintColor)
    }
    
    private func drawRatio(_ fraction: Int, to whole: Int, fractionColor: UIColor?, wholeColor: UIColor?) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        return renderer.image { _ in
            // Fill full circle with wholeColor
            wholeColor?.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
            
            // Fill pie with fractionColor
            fractionColor?.setFill()
            let piePath = UIBezierPath()
            piePath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                           startAngle: 0, endAngle: (CGFloat.pi * 2.0 * CGFloat(fraction)) / CGFloat(whole),
                           clockwise: true)
            piePath.addLine(to: CGPoint(x: 20, y: 20))
            piePath.close()
            piePath.fill()
            
            // Fill inner circle with white color
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()
            
            // Finally draw count text vertically and horizontally centered
            let attributes = [ NSAttributedStringKey.foregroundColor: UIColor.black,
                               NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)]
            let text = "\(whole)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 20 - size.width / 2, y: 20 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
    
    private func countElem(annotationType type: basicAnnotationType) -> Int {
        guard let cluster = annotation as? MKClusterAnnotation else { return 0 }
        
        return cluster.memberAnnotations.filter { member -> Bool in
            guard let viewAnnotation = member as? basicAnnotation else {
                fatalError("Found unexpected annotation type")
            }
            return viewAnnotation.type == type
        }.count
    }
}
