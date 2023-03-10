//
//  elements.swift
//  dynamicui
//
//  Created by Justyna Gręda on 20/02/2023.
//

import Foundation
import SwiftUI
import UIKit

protocol UIComponent {
    var uniqueId: String { get }
    func render() -> AnyView
}

extension View {
    func toAny() -> AnyView {
        return AnyView(self)
    }
}

extension String {
    func toBinaryFloatingPoint() -> any BinaryFloatingPoint {
        return self as! any BinaryFloatingPoint
    }
}

//allows to define a color using hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct TextComponent: UIComponent {
    var uniqueId: String
    let uiModel: TextComponentUIModel
    
    func render() -> AnyView {
        TextComponentView(uiModel: uiModel).toAny()
    }

}

struct TextComponentUIModel {
    let text: String
    let fontType: String?
    let fontColor: String?
}

struct TextComponentView: View {
    let uiModel: TextComponentUIModel
    var body: some View {
        Text(uiModel.text).font(uiModel.fontType == ".title" ? .title : .body).foregroundColor(Color.init(hex: uiModel.fontColor ?? "000000"))
    }
}

//Form field

struct FormFieldUIModel {
    let hint: String
    let text: Binding<String>
    let label: String?
}

struct FormFieldComponentView: View {
    let uiModel: FormFieldUIModel
    var body: some View {
        if uiModel.label != nil {
            HStack {
                Text(uiModel.label!)
                TextField(uiModel.hint, text: uiModel.text)
            }
        }else{
            TextField(uiModel.hint, text: uiModel.text)

        }
    }
}

struct FormFieldComponent: UIComponent {
    var uniqueId: String
    let uiModel: FormFieldUIModel
    
    func render() -> AnyView {
        FormFieldComponentView(uiModel: uiModel).toAny()
    }
}

//Date picker

struct DatePickerUIModel {
    let label: String
    let selection: Binding<Date>
}

struct DatePickerComponentView: View {
    let uiModel: DatePickerUIModel
    var body: some View {
        DatePicker(uiModel.label, selection: uiModel.selection, displayedComponents: .date)
    }
}

struct DatePickerComponent: UIComponent {
    var uniqueId: String
    let uiModel: DatePickerUIModel
    
    func render() -> AnyView {
        DatePickerComponentView(uiModel: uiModel).toAny()
    }
}

//Time picker

struct TimePickerUIModel {
    let label: String
    let selection: Binding<Date>
}

struct TimePickerComponentView: View {
    let uiModel: TimePickerUIModel
    var body: some View {
        DatePicker(uiModel.label, selection: uiModel.selection, displayedComponents: .hourAndMinute)
    }
}

struct TimePickerComponent: UIComponent {
    var uniqueId: String
    let uiModel: TimePickerUIModel
    
    func render() -> AnyView {
        TimePickerComponentView(uiModel: uiModel).toAny()
    }
}

//Multiple selection picker
struct PickerUIModel {
    let label: String?
    let selection: Binding<String>
    let options: Array<String>
}

struct PickerComponentView: View {
    let uiModel: PickerUIModel
    var body: some View {
        if uiModel.label != nil{
            HStack {
                Text(uiModel.label!)
                Picker(uiModel.label!, selection: uiModel.selection){
                    ForEach(0 ..< uiModel.options.count, id: \.self) { option in
                        Text(uiModel.options[option]).tag(option)
                    }
                }.pickerStyle(.segmented)
            }
        }else{
            Picker("", selection: uiModel.selection){
                ForEach(0 ..< uiModel.options.count, id: \.self) {
                    Text(self.uiModel.options[$0]).tag(uiModel.options[$0])
                }
            }
        }
    }
}

struct PickerComponent: UIComponent {
    var uniqueId: String
    let uiModel: PickerUIModel
    
    func render() -> AnyView {
        PickerComponentView(uiModel: uiModel).toAny()
    }
}

//Slider
struct SliderUIModel {
    let label: String?
    let value: Binding<String>
    let min: Int
    let max: Int
    let step: Int?
}

//struct SliderComponentView : View {
//    let uiModel: SliderUIModel
////    @ObservedObject var setInformationVM: SetSliderValue
////    let elapsedTime = Binding(
////        get: { Double(setInformationVM.sliderValue) },
////        set: { setInformationVM.sliderValue = Int($0) } // Or other custom logic
////            )
//    var body: some View {
//        if uiModel.label != nil{
//            HStack {
//                Text(uiModel.label!)
//                Slider(value: uiModel.value, in: String(uiModel.min)...String(uiModel.max))
//            }
//        }else{
//
//        }
//    }
//}
//
//struct SliderComponent: UIComponent {
//    var uniqueId: String
//    let uiModel: SliderUIModel
//
//    func render() -> AnyView {
//        SliderComponentView(uiModel: uiModel).toAny()
//    }
//}

//Checkbox button
struct CheckboxUIModel {
    let label: String
    let isOn: Binding<Bool>
}

struct CheckboxComponentView: View {
    let uiModel: CheckboxUIModel
    var body: some View {
        Toggle(uiModel.label, isOn: uiModel.isOn)
            .toggleStyle(CheckboxStyle())
    }
}

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .font(.system(size: 20, weight: .regular, design: .default))
                configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }

    }
}

struct CheckboxComponent: UIComponent {
    var uniqueId: String
    let uiModel: CheckboxUIModel
    
    func render() -> AnyView {
        CheckboxComponentView(uiModel: uiModel).toAny()
    }
}

//Toggle button
struct ToggleUIModel {
    let label: String
    let isOn: Binding<Bool>
}

struct ToggleComponentView: View {
    let uiModel: ToggleUIModel
    var body: some View {
        Toggle(uiModel.label, isOn: uiModel.isOn)
    }
}
struct ToggleComponent: UIComponent {
    var uniqueId: String
    let uiModel: ToggleUIModel
    
    func render() -> AnyView {
        ToggleComponentView(uiModel: uiModel).toAny()
    }
}

//File Picker
struct FilepickerUIModel {
    let label: String?
    let buttonText: String
    var selectedFile: Binding<Data?>
    var selectedFileName: Binding<String?>
}

enum PickerType: Identifiable {
    case cameraRoll, files
    
    var id: Int {
        hashValue
    }
}

struct FilepickerComponentView: View {
    let uiModel: FilepickerUIModel
    @State private var pickerType: PickerType? = .files
    @State var isSheetPresenting = false
    
    var body: some View {
        if uiModel.label != nil {
            if uiModel.selectedFileName.wrappedValue != nil {
                VStack {
                    HStack {
                        Text(uiModel.label!)
                        Spacer()
                        Button(uiModel.buttonText) {
                            isSheetPresenting.toggle()
                        }.sheet(isPresented: $isSheetPresenting, content: {
                            DocumentPicker(file: uiModel.selectedFile, fileName: uiModel.selectedFileName)
                        })
                    }
                    HStack {
                        Text(uiModel.selectedFileName.wrappedValue!)
                    }
                }
            }else{
                HStack {
                    Text(uiModel.label!)
                    Spacer()
                    Button(uiModel.buttonText) {
                        isSheetPresenting.toggle()
                    }.sheet(isPresented: $isSheetPresenting, content: {
                        DocumentPicker(file: uiModel.selectedFile, fileName: uiModel.selectedFileName)
                    })
                }
            }
        }else{
            if uiModel.selectedFile != nil {
                VStack {
                    Button(uiModel.buttonText) {
                        isSheetPresenting.toggle()
                    }.sheet(isPresented: $isSheetPresenting, content: {
                        DocumentPicker(file: uiModel.selectedFile, fileName: uiModel.selectedFileName)
                    })
                    HStack {
                        Text(uiModel.selectedFileName.wrappedValue ?? "")
                    }
                }
            }else{
                Button(uiModel.buttonText) {
                    isSheetPresenting.toggle()
                }.sheet(isPresented: $isSheetPresenting, content: {
                    DocumentPicker(file: uiModel.selectedFile, fileName: uiModel.selectedFileName)
                })
            }
        }
    }
}
struct FilepickerComponent: UIComponent {
    var uniqueId: String
    let uiModel: FilepickerUIModel
    
    func render() -> AnyView {
        FilepickerComponentView(uiModel: uiModel).toAny()
    }
}


