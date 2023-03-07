//
//  homepagecontroller.swift
//  dynamicui
//
//  Created by Justyna Gręda on 20/02/2023.
//

import Foundation
import SwiftUI

class HomePageController: ObservableObject {
    @Published var uiComponents: [UIComponent] = []
    @Published var arbitraryArray = [Any]()
    
    func loadPage() {
        let response = readFile()
        response!.forEach { demoData in
            let uiComponent = parseToUiComponent(demoData: demoData)
            uiComponents.append(uiComponent)
            
        }
    }
    
    
    
}

func parseToUiComponent(demoData: DemoData) -> UIComponent {
    var uiComponent: UIComponent

    if demoData.type == "text" {
        uiComponent = TextComponent(uniqueId: demoData.uuid , uiModel: TextComponentUIModel(text: demoData.args["text"] ?? "", fontType: demoData.args["fontType"] ?? nil, fontColor: demoData.args["fontColor"] ?? nil))
    }else if demoData.type == "form_field"{
        @ObservedObject var model = TextModel()
        @State var nameText: String = ""
        uiComponent = FormFieldComponent(uniqueId: demoData.uuid , uiModel: FormFieldUIModel(hint: demoData.args["hint"] ?? "", text: $model.nametext, label: demoData.args["label"] ?? ""))
    }
    else if demoData.type == "date" {
        @ObservedObject var model = DateModel()
        let dateFormatter = DateFormatter()
        uiComponent = DatePickerComponent(uniqueId: demoData.uuid , uiModel: DatePickerUIModel(label: demoData.args["label"] ?? "", selection: $model.date))
    }
    else if demoData.type == "time" {
        @ObservedObject var model = TimeModel()
        uiComponent = TimePickerComponent(uniqueId: demoData.uuid , uiModel: TimePickerUIModel(label: demoData.args["label"] ?? "", selection: $model.time))
    }
    else if demoData.type == "picker" {
        @ObservedObject var model = SelectionModel()
        uiComponent = PickerComponent(uniqueId: demoData.uuid , uiModel: PickerUIModel(label: demoData.args["label"] ?? "", selection: $model.selectedOption, options: demoData.options!))
    }
    else if demoData.type == "checkbox" {
        @ObservedObject var model = isOnModel()
        uiComponent = CheckboxComponent(uniqueId: demoData.uuid, uiModel: CheckboxUIModel(label: demoData.args["label"] ?? "", isOn: $model.isOn))
    }
    else if demoData.type == "toggle" {
        @ObservedObject var model = ToggleModel()
        uiComponent = ToggleComponent(uniqueId: demoData.uuid, uiModel: ToggleUIModel(label: demoData.args["label"] ?? "", isOn: $model.isOn))
    }
    else if demoData.type == "filepicker" {
        @ObservedObject var model = isFileShowingModel()
        uiComponent = FilepickerComponent(uniqueId: demoData.uuid, uiModel: FilepickerUIModel(label: demoData.args["label"] ?? "", buttonText: demoData.args["buttonText"] ?? "", isShowing: $model.isShowing, buttonAction: buttonAction(isShowing: $model.isShowing)))
    }
    else {
        uiComponent = TextComponent(uniqueId: demoData.uuid , uiModel: TextComponentUIModel(text: "something went wrong", fontType: nil, fontColor: demoData.args["fontColor"] ?? nil))
    }
    
    return uiComponent
}

class TextModel: ObservableObject {
    @Published var nametext: String = ""
}

class DateModel : ObservableObject {
    @Published var date = Date()
}

class TimeModel : ObservableObject {
    @Published var time = Date()
}

class SelectionModel : ObservableObject {
    @Published var selectedOption: String = ".pl"
}

class isOnModel : ObservableObject {
    @Published var isOn: Bool = true
}

class ToggleModel : ObservableObject {
    @Published var isOn: Bool = true
}

class isFileShowingModel : ObservableObject {
    @Published var isShowing: Bool = false
}

func buttonAction(isShowing: Binding<Bool>) {
    isShowing.wrappedValue.toggle()
}

struct DemoData: Codable{
    let uuid: String
    let type: String
    let args: [String : String]
    let options: [String]?
}

func readFile() -> [DemoData]? {
    if let url = Bundle.main.url(forResource: "layout_file", withExtension: "json"),
       let data = try? Data(contentsOf: url) {
      let decoder = JSONDecoder()
        do{
            let jsonData = try decoder.decode([DemoData].self, from: data)
            return jsonData
        }catch{
            print(error)
        }
    }else{
        return nil
    }
    return nil
}


extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
