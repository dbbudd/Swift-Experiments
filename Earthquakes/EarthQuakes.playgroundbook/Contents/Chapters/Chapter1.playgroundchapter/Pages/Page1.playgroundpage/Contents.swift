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
        
        let jsonDecoder = JSONDecoder()
        if let data = data,
            let earthQuakeInfo = try? jsonDecoder.decode(EarthQuakeInfo.self, from: data) {
            print(earthQuakeInfo)
            completion(earthQuakeInfo)
        } else {
            print("Either no data was returned, or data was not properly decoded.")
        }
    }
    task.resume()
}


extension EarthQuakeInfo {
    var asAnnotations: [MKPointAnnotation] {
        print(self)
        var annotations = [MKPointAnnotation]()
        for i in self.features {
            
            if let _ = i.geometry.coordinates.first {
                let annotation = MKPointAnnotation()
                let location = CLLocationCoordinate2DMake(Double(i.geometry.coordinates[1]), Double(i.geometry.coordinates[0]))
                print(location)
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
mapView.mapType = .hybridFlyover

let camera = MKMapCamera(lookingAtCenter: mapRegion.center, fromDistance: 20000000, pitch: 30, heading: 0)

mapView.camera = camera

fetchEarthQuakeInfo { (fetchedInfo) in
    if let fetchedInfo = fetchedInfo {
        print(fetchedInfo)
        print(fetchedInfo.asAnnotations)
        
        DispatchQueue.main.async {
            mapView.addAnnotations(fetchedInfo.asAnnotations)
        }
        
    } else {
        print("Fetch Failed")
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = mapView
