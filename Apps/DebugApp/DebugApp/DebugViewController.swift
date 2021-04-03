import UIKit
import MapboxMaps
import Turf

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

public class DebugViewController: UIViewController {

    internal var mapView: MapView!
    internal var runningAnimator: CameraAnimator?
    internal var offlineManager: OfflineManager?

    var tileStore: TileStore?

    var resourceOptions: ResourceOptions {
        guard let accessToken = AccountManager.shared.accessToken else {
            fatalError("Access token not set")
        }

        let resourceOptions = ResourceOptions(accessToken: accessToken)
        return resourceOptions
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions)
        mapView.update { (mapOptions) in
            mapOptions.location.puckType = .puck2D()
        }

        view.addSubview(mapView)

        /**
         The closure is called when style data has been loaded. This is called
         multiple times. Use the event data to determine what kind of style data
         has been loaded.
         
         When the type is `style` this event most closely matches
         `-[MGLMapViewDelegate mapView:didFinishLoadingStyle:]` in SDK versions
         prior to v10.
         */
        mapView.on(.styleDataLoaded) { (event) in
            guard let data = event.data as? [String: Any],
                  let type = data["type"] else {
                return
            }

            print("The map has finished loading style data of type = \(type)")
        }

        /**
         The closure is called during the initialization of the map view and
         after any `styleDataLoaded` events; it is called when the requested
         style has been fully loaded, including the style, specified sprite and
         source metadata.

         This event is the last opportunity to modify the layout or appearance
         of the current style before the map view is displayed to the user.
         Adding a layer at this time to the map may result in the layer being
         presented BEFORE the rest of the map has finished rendering.

         Changes to sources or layers of the current style do not cause this
         event to be emitted.
         */
        mapView.on(.styleLoaded) { (event) in
            print("The map has finished loading style ... Event = \(event)")
        }

        /**
         The closure is called whenever the map finishes loading and the map has
         rendered all visible tiles, either after the initial load OR after a
         style change has forced a reload.

         This is an ideal time to add any runtime styling or annotations to the
         map and ensures that these layers would only be shown after the map has
         been fully rendered.
         */
        mapView.on(.mapLoaded) { (event) in
            print("The map has finished loading... Event = \(event)")
        }

        /**
         The closure is called whenever the map has failed to load. This could
         be because of a variety of reasons, including a network connection
         failure or a failure to fetch the style from the server.

         You can use the associated error message to notify the user that map
         data is unavailable.
         */
        mapView.on(.mapLoadingError) { (event) in
            guard let data = event.data as? [String: Any],
                  let type = data["type"],
                  let message = data["message"] else {
                return
            }

            print("The map failed to load.. \(type) = \(message)")
        }


        offlineManager = OfflineManager(resourceOptions: mapView.__map.getResourceOptions())

        guard let offlineManager = offlineManager else {
            return
        }

/*
        // 1. Create style package with loadStylePack() call.
        let stylePackLoadOptions = StylePackLoadOptions(
            __glyphsRasterizationMode: NSNumber(value: GlyphsRasterizationMode.ideographsRasterizedLocally.rawValue), //NSNumber(value: GlyphsRasterizationMode.noGlyphsRasterizedLocally.rawValue),
            metadata: "Hello World")

        offlineManager.loadStylePack(forStyleURL: StyleURI.streets.url.absoluteString,
                                     loadOptions: stylePackLoadOptions) { (result) in
            guard let result = result,
                  result.isValue(),
                  let stylePack = result.value as? StylePackLoadProgress else {
                return
            }

            let loadingCompleted = (stylePack.completedResourceCount == stylePack.requiredResourceCount)
            print("Style pack loading complete = \(loadingCompleted)")
        }
*/

        // 2. Create an offline region with tiles for Streets and Satellite styles.
        let stylePackOptions = StylePackLoadOptions(
            __glyphsRasterizationMode: NSNumber(value: GlyphsRasterizationMode.allGlyphsRasterizedLocally.rawValue),
            metadata: nil)

        let streetsTilesetDescriptorOptions = TilesetDescriptorOptions(
            __styleURL: StyleURI.streets.url.absoluteString,
            minZoom: 0,
            maxZoom: 5,
            stylePack: stylePackOptions)

        let streetsDescriptor = offlineManager.createTilesetDescriptor(for: streetsTilesetDescriptorOptions)

//        let satelliteTilesetDescriptorOptions = TilesetDescriptorOptions(
//            __styleURL: "mapbox://mapbox.satellite-v2",
//            minZoom: 0,
//            maxZoom: 5,
//            stylePack: nil
//        )
//        let satelliteDescriptor = offlineManager.createTilesetDescriptor(for: satelliteTilesetDescriptorOptions)

        // 3. load offline region
        tileStore = TileStore.getInstance()

        let tileLoadOptions = TileLoadOptions(
            __criticalPriority: false,
            acceptExpired: true,
            networkRestriction: .none)

        let offlineRegionLoadOptions = OfflineRegionLoadOptions(
            __geometry: MBXGeometry(coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 10)),
            descriptors: [streetsDescriptor/*, satelliteDescriptor*/],
            metadata: nil,
            tileLoadOptions: tileLoadOptions,
            start: nil,//CLLocation(latitude: 10, longitude: 10),
            averageBytesPerSecond: nil,
            extraOptions: nil)

        tileStore?.loadOfflineRegion(forId: "my_region",
                                    loadOptions: offlineRegionLoadOptions) { (expected) in
            guard let expected = expected,
                  expected.isValue(),
                  let region = expected.value as? MapboxCommon.OfflineRegion else {
                return
            }

            DispatchQueue.main.async {
                let loadingCompleted = (region.completedResourceCount == region.requiredResourceCount)
                print("Offline region loading complete = \(loadingCompleted)")
            }
        }
    }
}
