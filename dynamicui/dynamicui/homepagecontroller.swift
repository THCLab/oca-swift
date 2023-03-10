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
    print(demoData.type)
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
        model.selectedOption = "cat"
        uiComponent = PickerComponent(uniqueId: demoData.uuid , uiModel: PickerUIModel(label: demoData.args["label"] ?? "", selection: $model.selectedOption, options: ["cat", "dog"])) //demoData.options!))
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
        @ObservedObject var model = FilePickerModel()
        uiComponent = FilepickerComponent(uniqueId: demoData.uuid, uiModel: FilepickerUIModel(label: demoData.args["label"] ?? "", buttonText: demoData.args["buttonText"] ?? "", selectedFile: $model.file, selectedFileName: $model.fileName))
    }
    else if demoData.type == "slider" {
        @ObservedObject var model = SliderModel()
        uiComponent = SliderComponent(uniqueId: demoData.uuid, uiModel: SliderUIModel(label: demoData.args["label"] ?? nil, value: $model.value, min: demoData.args["min"]?.toDouble() ?? 0, max: demoData.args["max"]?.toDouble() ?? 100, step: demoData.args["step"]?.toDouble() ?? nil))
    }
    
    else {
        uiComponent = TextComponent(uniqueId: demoData.uuid , uiModel: TextComponentUIModel(text: "something went wrong with \(demoData.uuid)", fontType: nil, fontColor: demoData.args["fontColor"] ?? nil))
    }
    
    return uiComponent
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
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
    @Published var selectedOption: String = ""
}

class isOnModel : ObservableObject {
    @Published var isOn: Bool = true
}

class ToggleModel : ObservableObject {
    @Published var isOn: Bool = true
}
class SliderModel : ObservableObject {
    @Published var value: Double = 0
}

class FilePickerModel : ObservableObject {
    @Published var file: Data? = nil
    @Published var fileName: String? = ""
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
        print(data)
      let decoder = JSONDecoder()
        do{
            let jsonData = try decoder.decode([DemoData].self, from: data)
            print(jsonData)
            return jsonData
        }catch{
            print(error)
        }
    }else{
        return nil
    }
    return nil
}

func jsonFromURL() async -> [DemoData]? {
    let url = URL(string: "https://api.jsonbin.io/v3/b/640778c0c0e7653a0583fa43/latest")
    do {
        let (data, _) = try await URLSession.shared.data(from: url!)
        let decoder = JSONDecoder()
          do{
              let jsonData = try decoder.decode([DemoData].self, from: data)
              return jsonData
          }catch{
              print(error)
          }

        // more code to come
    } catch {
        print("Invalid data")
    }
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

