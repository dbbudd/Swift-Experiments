import UIKit
import MapKit
import PlaygroundSupport

struct EarthQuakeInfo: Codable {
    let type: String
    let metadata: MetaData
    let features: [Features]
    
    enum CodingKeys: String, CodingKey {
        case type
        case metadata
        case features
    }
}

struct MetaData: Codable {
    let generated: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case generated
        case title
    }
}

struct Features: Codable {
    let type: String
    let properties: FeaturesProperties
    let geometry: FeaturesGeometry
    
    enum CodingKeys: String, CodingKey {
        case type
        case properties
        case geometry
    }
}

struct FeaturesProperties: Codable {
    let mag: Double
    let place: String
    
    enum CodingKeys: String, CodingKey {
        case mag
        case place
    }
}

struct FeaturesGeometry: Codable {
    let type: String
    let coordinates: [Double]
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}

func fetchEarthQuakeInfo(completion: @escaping (EarthQuakeInfo?) -> Void) {
    let baseURL = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson"
    let url = URL(string: baseURL)!
    
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        
        //print(String(data: data!, encoding: .utf8)!)
        let jsonDecoder = JSONDecoder()
        if let data = data,
            let earthQuakeInfo = try? jsonDecoder.decode(EarthQuakeInfo.self, from: data) {
            print(earthQuakeInfo)
            completion(earthQuakeInfo)
            //We'll convert this into an extension so that at any time we can reuse and convert EarthQuakeInfo struct into a bunch of annotations.
//
            // your looping over the features putting them into an array only to loop over that array again why not just create the MKPoint ANnotations here? also a danger of assigning the wrong label to the wrong coordinate
//            for i in earthQuakeInfo.features{
//                myCoor.append(i.geometry.coordinates)
//                myPlace.append(i.properties.place)
//            }
//
//            let c = Int(myCoor.count) - 1
//            for i in 0...c{
//                let annotation = MKPointAnnotation()
//                let location = CLLocationCoordinate2DMake(Double(myCoor[i][0]), Double(myCoor[i][1]))
//                annotation.coordinate = location
//                annotation.title = myPlace[i]
//
//                myAnnotations.append(annotation)
//                print(myPlace[i] + " - " + String(myCoor[i][0]) + ", " + String(myCoor[i][1]))
//            }
//            print(myAnnotations.count)
            // Don't access the mapView here it was calling before the mapview had even been created because its a playground its letting you access it but it shouldn't well done xcode
            //mapView.addAnnotations(myAnnotations)
            
        } else {
            print("Either no data was returned, or data was not properly decoded.")
        }
    }
    task.resume()
}


extension EarthQuakeInfo {
    // Don't access any varablees outside the scope inside an extension bad stuff will happen
    var asAnnotations: [MKPointAnnotation] {
        print(self)
        var annotations = [MKPointAnnotation]()
        for i in self.features {
            //before we were using [i][0] and [i][1] we're going to use a shortcut of .first these are extensions on an array that are given to you helpers sort of thing not nessarry in this case but just showing you theres also .last which will get the last item in an array
            if let latitude = i.geometry.coordinates.first {
                //We're doing this inside the if let because if we don't have proper coorindates then we don't want to add a marker with bad coordinates we'll want to skip it (defensive)
                let annotation = MKPointAnnotation()
                let location = CLLocationCoordinate2DMake(latitude, Double(i.geometry.coordinates[1]))
                annotation.coordinate = location
                annotation.title = i.properties.place
                annotations.append(annotation)
            }
        }
        return annotations
    }
}
// create a MKMapView
let mapView = MKMapView(frame: CGRect(x:0, y:0, width:800, height:800))

// Define a region for our map view
var mapRegion = MKCoordinateRegion()

mapRegion.center = CLLocationCoordinate2D(latitude: -8.693793, longitude: 115.162216)
mapRegion.span.latitudeDelta = 0.02
mapRegion.span.longitudeDelta = 0.02

mapView.setRegion(mapRegion, animated: true)
mapView.mapType = .standard

let camera = MKMapCamera(lookingAtCenter: mapRegion.center, fromDistance: 20000000, pitch: 30, heading: 0)

mapView.camera = camera

//This one works but others don't
let annotation = MKPointAnnotation()
let location = CLLocationCoordinate2D(latitude: -8.693793, longitude: 115.162216)
annotation.coordinate = location
annotation.title = "test"

mapView.addAnnotation(annotation)

fetchEarthQuakeInfo { (fetchedInfo) in
    if let fetchedInfo = fetchedInfo {
        print(fetchedInfo)
        print(fetchedInfo.asAnnotations)
        // Doing ui work always needs to be done on the main thread
        DispatchQueue.main.async {
            // We could do whats commented below but apple has provided another method to add an array of annotations
//            for anno in fetchedInfo.asAnnotations {
//                mapView.addAnnotation(anno)
//            }
            mapView.addAnnotations(fetchedInfo.asAnnotations)
        }
        // Here we are "opening up" the the optional fetched info that we are returning in our closure
        // you'll notice now if you access fetchedinfo its no longer optional (dont need to use !)
//
    } else {
        print("Fetch Failed")
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = mapView



