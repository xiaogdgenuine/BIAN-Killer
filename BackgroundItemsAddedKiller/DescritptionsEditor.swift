//
//  DescriptionsEditor.swift
//  BIAN Killer
//
//  Created by Yang Xu on 2023/3/13.
//

import Foundation
import SwiftUI

struct DescrptionsEditor:View {
  @State var descriptions = [String]()
  @State var selection:Int?
  @State var text = ""
  var body: some View {
    VStack {
      List(selection:$selection) {
        ForEach(descriptions.indices,id:\.self) { index in
          HStack {
            Text(descriptions[index])
            Spacer()
            Button {
              del(index: index)
            } label: {
              Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
            }
          }
        }
      }
      HStack {
        TextField("New notification description",text: $text)
          .textFieldStyle(.squareBorder)
        Button("Add"){
          add(description: text)
          text = ""
        }
      }
    }
      .padding(.all,10)
      .onAppear{
        descriptions = monitor.descriptions
    }
  }
  
  func del(index:Int){
    descriptions.remove(at: index)
    withAnimation() {
      monitor.descriptions = descriptions
    }
  }
  
  func add(description:String) {
    descriptions.append(description)
    withAnimation() {
      monitor.descriptions = descriptions
    }
  }
}

class DetailWindowController<RootView : View>: NSWindowController {
    convenience init(rootView: RootView) {
        let hostingController = NSHostingController(rootView: rootView.frame(width: 400, height: 500))
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 400, height: 500))
        self.init(window: window)
    }
}
