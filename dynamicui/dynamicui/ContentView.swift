//
//  ContentView.swift
//  dynamicui
//
//  Created by Justyna Gręda on 20/02/2023.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject var controller: HomePageController
    @State private var showingAlert = false
    @State var values: [String] = []
    @ObservedObject var viewModel = ListModel()
    @State private var isDisabledSubmit = false
    
    var body: some View {
        ScrollView{
            VStack {
                ForEach(controller.uiComponents, id: \.uniqueId) { uiComponent in
                    uiComponent.render()
                }
                Button(action: {
                    for component in controller.uiComponents {
                        var value = collectValue(component: component)
                        if(value != nil) {
                            values.append(collectValue(component: component)!)
                        }
                    }
//                    values = submitData(uiComponents: controller.uiComponents)
                    print(values)
                    isDisabledSubmit = true
                }) {
                    Text("SUBMIT")
                }
                .disabled(isDisabledSubmit)
                List(values, id: \.self) { value in
                    Text(value)
                }
            }
            .padding()
        }
        .onAppear(perform: {
            self.controller.loadPage()
        })
    }

}

//func submitData(uiComponents: [UIComponent]) -> [String] {
//    var values: [String] = []
//    for component in uiComponents {
//        var value = collectValue(component: component)
//        if(value != nil) {
//            values.append(collectValue(component: component)!)
//        }
//    }
//    return values
//}

func collectValue(component: UIComponent) -> String? {
    var componentType: String = component.uniqueId.substring(to: component.uniqueId.firstIndex(of: "-")!)
    var value: String?
    if componentType == "form" {
        var formComponent = component as! FormFieldComponent
        value = formComponent.uiModel.text.wrappedValue
    } else if componentType == "date" {
        var dateComponent = component as! DatePickerComponent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        value = dateFormatter.string(from: dateComponent.uiModel.selection.wrappedValue)
    } else if componentType == "time" {
        var timeComponent = component as! TimePickerComponent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        value = dateFormatter.string(from: timeComponent.uiModel.selection.wrappedValue)
    } else if componentType == "picker" {
        var pickerComponent = component as! PickerComponent
        value = pickerComponent.uiModel.selection.wrappedValue
    } else if componentType == "checkbox" {
        var checkboxComponent = component as! CheckboxComponent
        value = String(checkboxComponent.uiModel.isOn.wrappedValue)
    }
    return value
}



class ListModel : ObservableObject {
    @Published var values = []
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(controller: HomePageController())
    }
}

                 
