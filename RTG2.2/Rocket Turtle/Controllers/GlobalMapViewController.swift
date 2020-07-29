//
//  GlobalMapViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/17/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import Mapbox
import CoreMotion
//serves as the controller for the global map View
class GlobalMapViewController: UIViewController, MGLMapViewDelegate,CLLocationManagerDelegate {
    
    //classes global variables
    var mapView: MGLMapView!
    var manager = CLLocationManager()
    var motionManager = CMMotionManager()
    var styleurl = URL(string: "mapbox://styles/jackgrahm/ckcfrbkvh0eqx1iqh6sqfx7c4") //used to customize the style of the map
    var timer: Timer?
    var updateMapTimer: Timer?
    var arenaID = 0 //id used to identify the collection of data in the google database
    //ID 0 is the global Map
    let db = Firestore.firestore()
    var cameraBeenSet = false
    //    var postLocationInterval = 6.0 //the time interval in seconds before a user's updated location can be posted to firebase again
    //    //^change variable to determine the frequency of user location updates
    //    var pullMapUpdateInterval = 12.5 // the time interval in seconds before the updteMapTimer repeats its action of updating the map
    var startTime: Date? //instance variable used as the timestamp for the previous posted location update
    //only called first time the view Loads
    var userLocationsAnnotations : [String : userMapboxAnnotationStructure] = [:] //dictionary of user locations indexed by each user's username information held in structure to avoid domain conflict
    var userLocationsAnnotationsReferenceDictionary: [String: MGLPointAnnotation] = [:]
    var listener : ListenerRegistration?
    
    
    //outlets
    @IBOutlet weak var ToggleViewTypeButton: UIButton!
    @IBOutlet weak var viewTypeLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var toggleViewButtonBackground: UIImageView!
    @IBOutlet weak var refreshButtonBackground: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide the back button
        navigationItem.hidesBackButton=true
        //don't hide the navigation Bar
        self.navigationController?.navigationBar.isHidden=false
        
        //setup coremotion manager update interval for the gyroscope or deviceMotionManager
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        motionManager.deviceMotionUpdateInterval = 0.1 //set device motion update interval to match the update timer
        
        //setup the MGL mapview delegates and present the subview
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //watch effect on battery
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
        //setup the mapView
        mapView = MGLMapView(frame: view.bounds, styleURL: styleurl)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.maximumPitch = 85
        //mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        mapView.minimumZoomLevel = 18
        mapView.frame = view.frame
        mapView.compassView.isHidden = true 
        view.addSubview(mapView)
        view.addSubview(toggleViewButtonBackground)
        view.addSubview(ToggleViewTypeButton)
        view.addSubview(refreshButtonBackground)
        view.addSubview(refreshButton)
        
        //        view.addSubview(viewTypeLabel)
        
        //create a timer that updates the heading of the map to allign with the users heading useing the setDirection mapbox function
        if timer == nil || timer?.isValid == false {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(matchUser), userInfo: nil, repeats: true)
        }
        //        updateMapTimer = Timer.scheduledTimer(timeInterval: pullMapUpdateInterval, target: self, selector: #selector(pullMapUpdate), userInfo: nil, repeats: true)
        
    }
    
    //unhide the navigation Bar When the view appears, Regaurdless of last state
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cameraBeenSet = false
        navigationItem.hidesBackButton=true
        self.navigationController?.navigationBar.isHidden=false
        
        //resume updating user location
        manager.startUpdatingLocation()
        manager.distanceFilter = 4.0
        
        
        //setup coremotion manager update interval for the gyroscope or deviceMotionManager
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        motionManager.deviceMotionUpdateInterval = 0.1 //set device motion update interval to match the update timer
        
        //setup the MGL mapview delegates and present the subview
        mapView.userTrackingMode = .followWithHeading
        mapView.showsUserHeadingIndicator = true
        
        //start the update matchUserTimer again
        //start needed timers again
        //prevent double starting of timers as if u double start then u'll loose the pointer to the first timer and never be able to stop it/invalidate it
        if timer == nil || timer?.isValid == false {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(matchUser), userInfo: nil, repeats: true)
            ToggleViewTypeButton.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
            mapView.minimumZoomLevel = 18
            
        }
        //        if updateMapTimer == nil || updateMapTimer?.isValid == false {
        //            updateMapTimer = Timer.scheduledTimer(timeInterval: pullMapUpdateInterval, target: self, selector: #selector(pullMapUpdate), userInfo: nil, repeats: true)
        //        }
        //setup snapshot listener to listen for location updates
        listener = db.collection(K.Fstore.GlobalArenaID).addSnapshotListener { (querySnapshot, error) in
            if let e = error{
                print(e.localizedDescription)
                return
            }
            if let snapShotDocuments = querySnapshot?.documents{
                for doc in snapShotDocuments{
                    let data = doc.data()
                    if let username = data[K.Fstore.userUserName] as? String , let doubleLatitude = data[K.Fstore.latitudeField] as? Double , let doubleLongitude = data [K.Fstore.longitudeField] as? Double{
                        
                        let temp = userMapboxAnnotationStructure(latitude: doubleLatitude, longitude: doubleLongitude, title: username, subtitle: username)
                        //add this structure to the global structure array
                        self.userLocationsAnnotations[username] = temp
                    }
                }
            }
            self.updateMapViewAnnotations()
        }
    }
    
    
    
    
    //function called by refresh button to pull map annotation data
    @objc func pullMapUpdate(){
        //the pullMapUpdate timer repeats every pullMapUpdateInterval seconds therefore no need to control frequency of updates inside this function
        //        print("pullMapUpdate Called at \(NSTimeIntervalSince1970) ")
        db.collection( K.Fstore.GlobalArenaID ).getDocuments { (querySnapshot, error) in
            if let e = error{
                print("\(e.localizedDescription)")
                return
            }
            else{
                if let snapShotDocuments = querySnapshot?.documents {
                    //                    print("documents pulled = \(snapShotDocuments.count)")
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        if let username = data[K.Fstore.userUserName] as? String , let doubleLatitude = data[K.Fstore.latitudeField] as? Double , let doubleLongitude = data [K.Fstore.longitudeField] as? Double{
                            //print the updated data from google Firebase
                            //                            print("Recieved from firebase - User: \(username) latitude:\(doubleLatitude) Longitude: \(doubleLongitude)")
                            
                            //create the annotation structure to be loaded into the global structure array of user locationAnnotations info
                            let temp = userMapboxAnnotationStructure(latitude: doubleLatitude, longitude: doubleLongitude, title: username, subtitle: username)
                            //add this structure to the global structure array
                            self.userLocationsAnnotations[username] = temp
                        }
                        
                    }
                    self.updateMapViewAnnotations()
                    
                }
            }
            
        }
        
    }
    
    //make sure device stops requesting location info after leaving the global Mapview
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //stop requesting user location and updating location
        motionManager.stopDeviceMotionUpdates()
        manager.stopUpdatingLocation()
        //invalidate the timers
        timer?.invalidate()
        updateMapTimer?.invalidate()
        //remove the snapshot listener when the view isn't being used
        listener?.remove()
        
    }
    
    //action outlets
    @IBAction func toggleViewTypeButtonPressed(_ sender: UIButton) {
        //toggle the viewing mode of the user if user is in matchUser() mode then invalidate the timer
        if timer?.isValid == true {
            timer?.invalidate()
            //change the image to be not following user
            sender.setImage(UIImage(systemName: "location.north.line"), for: .normal)
            //allow wider zoom
            mapView.minimumZoomLevel = 10
        }else{
            //restart the matchUser() process
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(matchUser), userInfo: nil, repeats: true)
            sender.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
            //go back to restricted zoom level
            mapView.minimumZoomLevel = 18
        }
        
    }
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        pullMapUpdate()
        //        locationManager(manager, didUpdateLocations: ma)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let userName = nativeUserInfo.username , let latitude = mapView.userLocation?.location?.coordinate.latitude , let longitude = mapView.userLocation?.location?.coordinate.longitude {
            //cast the longitude and latitude into doubles so they can be stored in firebase
            let doubleLatitude = Double(latitude)
            let doubleLongitude = Double(longitude)
            db.collection(K.Fstore.GlobalArenaID).document(nativeUserInfo.username!).setData([K.Fstore.userUserName: userName , K.Fstore.latitudeField : doubleLatitude , K.Fstore.longitudeField : doubleLongitude , K.Fstore.documentTypeField : K.Fstore.documentType_User])
            print("Following Sent to Firebase- \(K.Fstore.userUserName) = \(nativeUserInfo.username!) , \(K.Fstore.latitudeField) = \(doubleLatitude) , \(K.Fstore.longitudeField) = \(doubleLongitude), \(K.Fstore.documentTypeField) = \(K.Fstore.documentType_User)")
        }
        
        //past Implementation -
        //the following code has become obscelete since a timer is not needed to send a location update after establishing the distance filter at 10m so only significant location changes will post the user's updated location, allows us to use snapshot listeners to listen for location updates
        //        print("location manager sends location update ")
        //
        //
        //        //used to post user location Updates to firebase every POSTLOCATIONINTERVAL minimum
        //        //get the timestamp of the last location
        //        guard let loc = locations.last else{
        //            return
        //        }
        //        let time = loc.timestamp
        //        print("at time \(time)")
        //        //initialize the starttime and return if its the first moment
        //        guard let startTime = startTime else{
        //            self.startTime = time //save the time of the first location
        //            return //don't have a second location yet therefore return
        //        }
        //        let elapsed = time.timeIntervalSince(startTime)
        //
        //        if elapsed > postLocationInterval{
        ////            print("uploading updated location to the server at \(time)")
        //            if let userName = nativeUserInfo.username , let latitude = mapView.userLocation?.location?.coordinate.latitude , let longitude = mapView.userLocation?.location?.coordinate.longitude {
        //                //cast the longitude and latitude into doubles so they can be stored in firebase
        //                let doubleLatitude = Double(latitude)
        //                let doubleLongitude = Double(longitude)
        //                db.collection(K.Fstore.GlobalArenaID).document(nativeUserInfo.username!).setData([K.Fstore.userUserName: userName , K.Fstore.latitudeField : doubleLatitude , K.Fstore.longitudeField : doubleLongitude ])
        ////                print("Following Sent to Firebase- \(K.Fstore.userUserName) = \(nativeUserInfo.username!) , \(K.Fstore.latitudeField) = \(doubleLatitude) , \(K.Fstore.longitudeField) = \(doubleLongitude)")
        //            }
        //            self.startTime = time
        //        }
    }
    
    //function called by a scheduled timer to allign the camera with the user's camera
    @objc func matchUser(){
        if let heading = mapView.userLocation!.heading?.trueHeading{
            mapView.setDirection(heading,animated: true)
            if let userLocation = mapView.userLocation?.location {
                mapView.setCenter(userLocation.coordinate, animated: true)
                //use the deviceMotion pitch to transform into map camera pitch
                if var userPitch = motionManager.deviceMotion?.attitude.pitch{
                    //convert userPitch to degrees
                    userPitch = (userPitch * 180) / .pi
                    //                    print("camera pitch set to \(userPitch)")
                    let userCamera = MGLMapCamera(lookingAtCenter: userLocation.coordinate, acrossDistance: mapView.camera.viewingDistance , pitch: CGFloat(userPitch), heading: heading)
                    mapView.setCamera(userCamera, animated: cameraBeenSet)//camera.pitch = CGFloat(userPitch)
                    cameraBeenSet = true
                }
                
            }
        }
        
    }
    
    
    
    func updateMapViewAnnotations(){
        
        for structure in userLocationsAnnotations{
            //if the title is the current user's username then don't include that annotation
//            if structure.value.title == nativeUserInfo.username{
//                continue
//            }
            
            let newAnnotation = MGLPointAnnotation()
            newAnnotation.coordinate = CLLocationCoordinate2D(latitude: structure.value.latitude, longitude: structure.value.longitude)
            newAnnotation.title = structure.value.title
            newAnnotation.subtitle = structure.value.subtitle
            if userLocationsAnnotationsReferenceDictionary[structure.key] != nil{
                //remove the reference from the anotation
                mapView.removeAnnotation(self.userLocationsAnnotationsReferenceDictionary[structure.key]!)
                
            }
            userLocationsAnnotationsReferenceDictionary[structure.key] = newAnnotation
            mapView.addAnnotation(newAnnotation)
        }
    }
    
    //MARK:- delegate methods for the MGLMapViewDelegate
    
    // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
            
            // Set the annotation view’s background color to a value determined by its longitude.
//            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = #colorLiteral(red: 0.2412029505, green: 0.5847942829, blue: 0.7717464566, alpha: 1)
//                UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

//
// MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? bounds.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
    }
}




