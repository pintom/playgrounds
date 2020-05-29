//: [Previous](@previous)

import AppKit
import PlaygroundSupport
import SwiftUI

struct TextView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSTextView {
        return NSTextView()
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
		// nsView.isEditable = false
		nsView.string = text
    }
}

struct ContentView: View {
	@State var text = " this is text"
	
	var body: some View {
		Group{
			TextView(text: $text).frame(width: 200, height: 20)
			Divider().background(Color.green)
			Text("SwiftUI in a Playground thdth nthnd!")
			
		}
		
	}
}

let viewController = NSHostingController(rootView: ContentView())


PlaygroundPage.current.liveView = viewController





//: [Next](@next)
