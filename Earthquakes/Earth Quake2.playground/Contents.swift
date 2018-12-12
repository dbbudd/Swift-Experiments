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

var myCoor:[[Double]] = []
var myPlace:[String] = []
var myAnnotations:[MKPointAnnotation] = []

func fetchEarthQuakeInfo(completion: @escaping (EarthQuakeInfo?) -> Void) {
    let baseURL = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson"
    let url = URL(string: baseURL)!
    
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        
        //print(String(data: data!, encoding: .utf8)!)
        let jsonDecoder = JSONDecoder()
        if let data = data,
            let earthQuakeInfo = try? jsonDecoder.decode(EarthQuakeInfo.self, from: data) {
            completion(earthQuakeInfo)
            
            for i in earthQuakeInfo.features{
                myCoor.append(i.geometry.coordinates)
                myPlace.append(i.properties.place)
            }
            
            let c = Int(myCoor.count) - 1
            for i in 0...c{
                let annotation = MKPointAnnotation()
                let location = CLLocationCoordinate2DMake(Double(myCoor[i][0]), Double(myCoor[i][1]))
                annotation.coordinate = location
                annotation.title = myPlace[i]
                
                myAnnotations.append(annotation)
                print(myPlace[i] + " - " + String(myCoor[i][0]) + ", " + String(myCoor[i][1]))
            }
            print(myAnnotations.count)
            //mapView.addAnnotations(myAnnotations)
            
        } else {
            print("Either no data was returned, or data was not properly decoded.")
            completion(nil)
        }
    }
    task.resume()
}

fetchEarthQuakeInfo { (fetchedInfo) in
    //print(fetchedInfo!)
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

//These annotations arn't working even though the count is 12 in the function but 0 outside.
//map seems to be executing before data is fetched
mapView.addAnnotations(myAnnotations)
print(myAnnotations.count)

//This one works but others don't
let annotation = MKPointAnnotation()
let location = CLLocationCoordinate2D(latitude: -8.693793, longitude: 115.162216)
annotation.coordinate = location
annotation.title = "test"

mapView.addAnnotation(annotation)

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = mapView


