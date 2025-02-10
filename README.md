# PanZoomable

This library implements a view modifier that lets you pan and zoom arbitrary SwiftUI views.

## Usage:

```swift
import SwiftUI
import PanZoomable

struct ContentView: View {

    // You can use this object to externally adjust pan/zoom parameters
    // (e.g. to reset the view)
    @State private var dragZoomState = DragZoomState()

    var body: some View {
        MyView()
            .panZoomable(state: $dragZoomState)
    }
}

```

### Contributions are welcome!

