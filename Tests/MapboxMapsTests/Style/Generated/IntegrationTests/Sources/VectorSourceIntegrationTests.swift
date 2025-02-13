// This file is generated.

import XCTest
import Turf
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

class VectorSourceIntegrationTests: MapViewIntegrationTestCase {
    
    func testAdditionAndRemovalOfSource() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added VectorSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved VectorSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        style.uri = .streets

        didFinishLoadingStyle = { _ in
            var source = VectorSource()
            source.url = String.testSourceValue()
            source.tiles = [String].testSourceValue()
            source.bounds = [Double].testSourceValue()
            source.scheme = Scheme.testSourceValue()
            source.minzoom = Double.testSourceValue()
            source.maxzoom = Double.testSourceValue()
            source.attribution = String.testSourceValue()
            source.volatile = Bool.testSourceValue()
            source.prefetchZoomDelta = Double.testSourceValue()
            source.minimumTileUpdateInterval = Double.testSourceValue()
            source.maxOverscaleFactorForParentTiles = Double.testSourceValue()
            
            // Add the source
            do {
                try style.addSource(source, id: "test-source")
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add VectorSource because of error: \(error)")
            }

            // Retrieve the source
            do {
                _ = try style.source(withId: "test-source") as VectorSource
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve VectorSource because of error: \(error)")
            }
        }

        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}
// End of generated file