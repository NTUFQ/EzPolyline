//
//  ViewController.swift
//  PolylineDrawer
//
//  Created by NTUFQ on 12/6/16.
//  Copyright © 2016 NTUFQ. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var coordinateDisplay: UILabel!
    var currentCoordinate: CLLocationCoordinate2D!
    var polylinePoints = [CLLocationCoordinate2D]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var coordinateStringDisplay: UITextView!
    @IBOutlet weak var centerAimView: UIView!
    
    @IBAction func cancelPoint() {
        if !polylinePoints.isEmpty {
            //remove the last pin

            if let cancelledAnnotation = mapView.annotations.filter({$0.coordinate.latitude == polylinePoints.last!.latitude && $0.coordinate.longitude == polylinePoints.last!.longitude}).first {
                mapView.removeAnnotation(cancelledAnnotation)
            }
            
            
            //update the polyline point list and erase the last line
            polylinePoints.removeLast()
            mapView.removeOverlays(mapView.overlays)
            mapView.add(MKPolyline(coordinates: polylinePoints, count: polylinePoints.count))
            
            //update the string display
            coordinateStringDisplay.text = coordinateToString(coordinateList: polylinePoints)
            if coordinateStringDisplay.contentSize.height > coordinateStringDisplay.frame.height {
                let range = NSMakeRange(coordinateStringDisplay.text.characters.count - 1, 0)
                coordinateStringDisplay.scrollRangeToVisible(range)
            }
            
            
        }
    }

    @IBAction func setPoint() {
        // add a new polyline point
        polylinePoints.append(currentCoordinate)
        mapView.removeOverlays(mapView.overlays)
        mapView.add(MKPolyline(coordinates: polylinePoints, count: polylinePoints.count))
        
        //update the string display
        coordinateStringDisplay.text = coordinateToString(coordinateList: polylinePoints)
        if coordinateStringDisplay.contentSize.height > coordinateStringDisplay.frame.height {
            let range = NSMakeRange(coordinateStringDisplay.text.characters.count - 1, 0)
            coordinateStringDisplay.scrollRangeToVisible(range)
        }
        
        //add a new pin
        let newAnnotation = redDotAnnotation(coordinate: currentCoordinate)
        mapView.addAnnotation(newAnnotation)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //draw the center aim
        drawCenter()
        
        //initial coordinate label
        currentCoordinate = mapView.centerCoordinate
        coordinateDisplay.text = "{\(String(format: "%.6f", currentCoordinate.latitude)), \(String(format: "%.6f",currentCoordinate.longitude))}"
        
        //initial the coordinate string
        coordinateStringDisplay.text = coordinateToString(coordinateList: polylinePoints)
    }
    
    // update the coordinate label when the center aim moves
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentCoordinate = mapView.centerCoordinate
        coordinateDisplay.text = "{\(String(format: "%.6f",currentCoordinate.latitude)), \(String(format: "%.6f",currentCoordinate.latitude))}"
    }
    
    // draw polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = UIColor.red
            polylineRender.lineWidth = 4.0
            return polylineRender
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = false
            annotationView.image = UIImage(named: "Oval")
        }
        return annotationView
    }
    
    //draw the center aim with UIBezierPath
    func drawCenter(){
        let horizontalLinePath = UIBezierPath(rect: CGRect(x: 0, y: view.center.y, width: view.frame.width, height: 0))
        let horizontalLineLayer = CAShapeLayer()
        horizontalLineLayer.path = horizontalLinePath.cgPath
        horizontalLineLayer.strokeColor = UIColor.red.cgColor
        horizontalLineLayer.lineWidth = 1.0
        mapView.layer.addSublayer(horizontalLineLayer)
        
        let verticalLinePath = UIBezierPath(rect: CGRect(x: view.center.x, y: 0, width: 0, height: view.frame.height))
        let verticalLineLayer = CAShapeLayer()
        verticalLineLayer.path = verticalLinePath.cgPath
        verticalLineLayer.strokeColor = UIColor.red.cgColor
        verticalLineLayer.lineWidth = 1.0
        mapView.layer.addSublayer(verticalLineLayer)
    }
    
    //convert the coordinate list to a tuple string
    func coordinateToString(coordinateList: [CLLocationCoordinate2D]) -> String{
        var coordinateString = "let coordinateList = ( "
        for coordinate in coordinateList{
            coordinateString += "\n(\(coordinate.latitude),\(coordinate.longitude))"
        }
        coordinateString += ")"
        return coordinateString
    }
}

//a subclass of MKAnnotation
class redDotAnnotation: NSObject, MKAnnotation{
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
