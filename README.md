# A dynamic approach to UI generation - Swift

A properly written User Interface is what can make a service valuable. An ordinary customer wants to perform an action quickly, intuitively and easily. Therefore, the design of the UI can be a great challenge for the developers. Different users may come from various ecosystems or applications, where specific actions could have been performed in other way. There are always the "tech beginners" who need everything to be explained clearly, as they struggle to understand the inevitable technology. Moreover, the UI should be accessible for people with disabilities. All this forms a task for the UI/UX designers and code developers. A task without a single solution and an only one good way to solve. As there can be different approaches to UI creation, one of them is to do it dynamically, what will be further explained in this article, focusing on iOS operating system and Swift coding language.

## Why can dynamic UI be useful?
Why should a different approach to UI creation be used if SwiftUI or UIKit already have all that is needed? Let us consider a very basic example. There is a bookstore (of course no professional UI will be provided) which has a different discount for its customers based on the day of the week. For instance, Friday is a 10% discount for students day:


<img src="https://i.imgur.com/uqL0j2m.png" height="600">

BUT one time of the year, Friday is not an ordinary day for customers, it is Black Friday! Therefore the bookstore wants to offer different discounts and maybe a "buy more" User Interface. Let us just assume it wants a different text:

<img src="https://i.imgur.com/D5gvKyU.png" height="600">

So what should the code developer do? Create an entirely new version of the app just for this one day and distribute it to the customers, probably. And this is where the dynamic UI generation jumps in. What if the coder could simply change two lines in a `.json` file and enjoy the shopping spree? This approach to dynamic UI focuses on `.json` files describing SwiftUI widgets, stored on a server. The app can fetch the file and generate the UI based on the response. An obvious drawback of this solution is the requirement of the network connection. But as it probably would be adopted by more complex applications, the access to the Internet would not be much of an issue, as they mostly already require it.

**Important:** This example focuses on a `.json` files stored on the machine. It will be further expanded, granting a proper way of fetching the `.json` data for the app UI.



## Implementation
The implementation of a dynamic UI from JSON focuses on three areas:
- Fetching the data
- Creating a widget, depending on each of the data internal types
- Rendering them in a `View`

Everything starts with a `protocol` that allows the creation of a reusable, renderable UI component:

```swift=
protocol UIComponent {
    var uniqueId: String { get }
    func render() -> AnyView
}
```

The `uniqueId` is necessary to identify each of the components. The client is responsible for providing a unique identifier, as it is later used to distinguish between the components. The recommended `uniqueId` looks as follows:
`<component_name>-<any unique string>`
for instance:
`text-123456789`
Keep in mind that there cannot be any more text widgets with `123456789` string as the identifier part.

For each of the widgets, three `structs` are created. Let us consider a simple `Text` widget. First of all, a `TextComponentUIModel` is created. It consists of all the properties a `Text` widget might need to be rendered:

```swift=
struct TextComponentUIModel {
    let text: String
    let fontColor: String?
}
```

The `text` property is required, as the widget displays the text described by this property. The next attribute, `fontColor` is optional, it takes a hex String and applies the color to the text. More styling is also possible, the example focuses on a simple case.
Next, the View for the previously designed UIModel is constructed:

```swift=
struct TextComponentView: View {
    let uiModel: TextComponentUIModel
    var body: some View {
        Text(uiModel.text).foregroundColor(Color.init(hex: uiModel.fontColor ?? "000000"))
    }
}
```
The struct takes one parameter, a `TextComponentUIModel` and based on its properties creates an actual `Text` widget. For the text, it takes the `text` property of the UIModel and then applies the foregroundColor from the `fontColor` attribute. If it is not specified, the text remains black. The `Color.init` function will be described further in the article.

As a last step, the final compoment, a `TextComponent` is created. 

```swift=
struct TextComponent: UIComponent {
    var uniqueId: String
    let uiModel: TextComponentUIModel
    
    func render() -> AnyView {
        TextComponentView(uiModel: uiModel).toAny()
    }

}
```

As it conforms to the `UIComponent` protocol, all the fields described there are available for the `TextComponent`. Moreover, it takes a `UIModel` so that a proper widget can be rendered using the `render` function. What is important to mention here, `View` needs an extention, so that `AnyView` can be rendered:

```swift=
extension View {
    func toAny() -> AnyView {
        return AnyView(self)
    }
}
```

Similar steps can be performed to create more SwiftUI widgets so that they can be generated straight from a `.json` file.
Now, when the `TextComponent` can be created, it is time to focus on rendering an actual `View`. It will not be described how to collect the data from url. 
First of all, the page controller is created, which is used to gather all the generated `UIComponent` instances and allowing the `View` to load.

```swift=
class HomePageController: ObservableObject {
    @Published var uiComponents: [UIComponent] = []
    
    func loadPage() {
        let response = readFile()
        response!.forEach { demoData in
            let uiComponent = parseToUiComponent(demoData: demoData)
            uiComponents.append(uiComponent)   
        }
    }    
}
```

The `demoData` name genesis will be discussed in the JSON creation part of the article. As also mentioned, the `readFile` function will not be discussed. The page controller class, conforming to the `ObservableObject` protocol consists of a `@Published` variable, which is an array of all the UIComponents read from `.json` file. For each of them, or rather for each of the response parts an actual component is created and appended to the array. Let us have a look at the `parseToUiComponent` function, where all the magic takes place:

```swift=
func parseToUiComponent(demoData: DemoData) -> UIComponent {
    var uiComponent: UIComponent
    if demoData.type == "text" {
        uiComponent = TextComponent(uniqueId: demoData.uuid , uiModel: TextComponentUIModel(text: demoData.args["text"] ?? "", fontColor: demoData.args["fontColor"] ?? nil))
    } else {
        uiComponent = TextComponent(uniqueId: demoData.uuid , uiModel: TextComponentUIModel(text: "something went wrong with \(demoData.uuid)", fontColor: demoData.args["fontColor"] ?? nil))
    }
    return uiComponent
}
```

The function takes as a parameter a `DemoData` class instance. It is a helper class used to decode the `.json` file. 

```swift=
struct DemoData: Codable{
    let uuid: String
    let type: String
    let args: [String : String]
    let options: [String]?
}
```

It conforms to the Codable protocol, so that the data from `.json` file can be decoded to a `DemoData` instance. Therefore, each instance contains of a `uuid`, providing a `uniqueId` for the `TextComponent`, `type` allowing to create the right `UIComponent`, `args`, which describe some properties of widgets, like text or font color of a `Text` view. The `options` argument is optional, it is designed to allow selecting values with pickers. 
Going back to the `parseToUiComponent` function, depending on a `type` of `DemoData`, a proper component is chosen to append to components table. Here, focusing on the `TextComponent`, an instance of `TextComponent` is created, with a new uiModel, taking all the args from `DemoData` structure. It is returned from the function and appended to the published array of UIComponents. 

When the `.json` is done parsing, it is time to render the `View`. In the `ContentView` file, a few things are modified:

```swift=
struct ContentView: View {
    @ObservedObject var controller: HomePageController
    
    var body: some View {
        ScrollView{
            VStack {
                ForEach(controller.uiComponents, id: \.uniqueId) { uiComponent in
                    uiComponent.render()
                }
            }
            .padding()
        }
        .onAppear(perform: {
            self.controller.loadPage()
        })
    }

}
```

The struct requires a `HomePageController` instance to have an access to the array of UIComponents. When the view appears on the screen, the function `loadPage()` of the controller is called to gather all the components from the `.json` file. For each of them, the function `render()` is called to render a widget in the VStack.
In order for the preview to work, it has to be given an instance of `HomePageController`:

```swift=
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(controller: HomePageController())
    }
}
```

Finally, in the app file, the instance of `HomePageController` is created and passed to the `ContentView`:

```swift=
import SwiftUI

@main
struct dynamicuiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(controller: HomePageController())
        }
    }
}
```

And that's it! All the steps to dynamically generate a `Text` widget have been covered. What is left is a creation of a proper `.json` file, described in the next part of the article.

## JSON creation
The `.json` format has been chosen as a layout template due to its simplicity, popularity and rather small file size. With a few modifications (probably mostly when it comes to file parsing), a `.yaml` file would serve a good purpose. 
The `.json` file that has been used in the example has the following structure:

```json=
[
   {
      "type":"text",
      "args":{
         "text":"Today's discount is:",
         "fontColor":"000000"
      },
      "uuid":"text-123456789"
   },
   {
      "type":"text",
      "args":{
         "text":"SPECIAL BLACK FRIDAY DISCOUNT!",
         "fontColor":"ff0000"
      },
      "uuid":"text-123456799"
   }
]
```

The file is an array that consists of objects (here, two of them). Each of the object has a `type` (for the `Text` widget it is `text`), `uuid`, a previously described unique string identifying the component which will be useful soon, when collecting the values of form fields and `args`. Args are different for each component and provide necessary or optional (for instance styling) properties to each widget. Just 18 lines of a `.json` file give the developer a chance to dynamically update the User Interface.


## Available widgets
This research has been conducted mostly due to the need for dynamic generating of forms. Therefore the available widgets conform to what is described as [form components](https://quasar.dev/vue-components/input).

### `form`
A simple text form field created for a text input. Consists of an optional label, which when provided is added as a text before the field. Hint is necessary, as without both the label and the hint the field would be ambiguous. 

- Visual presentation
![](https://i.imgur.com/Xa4ZfGo.png)

- Example of a JSON
```json=
{
    "type" : "form_field",
    "args" : {
        "text" : "name",
        "hint" : "Enter name",
        "label" : "Name: "
    },
    "uuid" : "form-123456789"
}
```

- Data structure
```swift=
struct FormFieldUIModel {
    let hint: String
    let text: Binding<String>
    let label: String?
}
```

### `date`
A date picker, allows the user to choose a date from the calendar. It is later returned as a String in a `yyyy-MM-dd` format. Label is also required to provide better understanding of the picker and placed on the left-hand side.

- Visual presentation
![](https://i.imgur.com/iQvg92d.png)

- Example of a JSON
```json=
{
    "type" : "date",
    "args" : {
        "label" : "Birth date"
    },
    "uuid" : "date-123456789"
}
```
- Data structure
```swift=
struct DatePickerUIModel {
    let label: String
    let selection: Binding<Date>
}
```

### `time`
A time picker, allows the user to choose time from the clock. It is later returned as a String in a `HH:mm` format. Label is also required to provide better understanding of the picker and placed on the left-hand side.
- Visual presentation
- Example of a JSON
```json=
{
    "type" : "time",
    "args" : {
        "label" : "Arrival Time",
        "selection" : "e"
    },
    "uuid" : "time-123456789"
}
```
- Data structure
```swift=
struct TimePickerUIModel {
    let label: String
    let selection: Binding<Date>
}
```

### `toggle`
Allows the user to choose between two states. Returns a string, "true" or "false". Requires a label to provide better understanding of the button.

- Visual presentation
![](https://i.imgur.com/ejuE18h.png)

- Example of a JSON
```json=
{
    "type" : "toggle",
    "args" : {
        "label" : "Toggle me"
    },
    "uuid" : "toggle-123456789"
}
```
- Data structure
```swift=
struct ToggleUIModel {
    let label: String
    let isOn: Binding<Bool>
}
```

### `filepicker`
Allows the user to pick a file by displaying a standard iOS specific picker. The label is optional, as the picker button may contain enough information for the user. 

- Visual presentation
![](https://i.imgur.com/3HunfQl.png)

- Example of a JSON
```json=
{
    "type" : "filepicker",
    "args" : {
        "label" : "Choose file",
        "buttonText" : "Click here"
    },
    "uuid" : "filepicker-123456789"
}
```
- Data structure
```swift=
struct FilepickerUIModel {
    let label: String?
    let buttonText: String
    var selectedFile: Binding<Data?>
    var selectedFileName: Binding<String?>
}
```
### `picker`
Allows the user to pick one of the predefined values and returns it after submitting as a string. Label is optional.

- Visual presentation
![](https://i.imgur.com/prb37NU.png)

- Example of a JSON
```json=
{
    "type" : "picker",
    "args" : {
        "label" : "Pick answer"
    },
    "options" : [
        "yes",
        "no"
    ],
    "uuid" : "picker-123456799"
}
```
- Data structure
```swift=
struct PickerUIModel {
    let label: String?
    let selection: Binding<String>
    let options: Array<String>
}
```

### `slider`
Allows the user to select one value from the predefined ones, with a specific step. Minimum and maximum value of the slider are obligatory values, but step is optional and set to 1 on default. Label is also not required. The value after submitting is returned as a string. 

- Visual presentation
![](https://i.imgur.com/V1XalhJ.png)

- Example of a JSON
```json=
{
    "type" : "slider",
    "args" : {
        "label" : "Choose value: ",
        "min" : "0",
        "max" : "10",
        "step" : "0.5"

    },
    "uuid" : "slider-123456789"
}
```
- Data structure
```swift=
struct SliderUIModel {
    let label: String?
    let value: Binding<Double>
    let min: Double
    let max: Double
    let step: Double?
}
```

## Collecting the data
As mentioned in the previous section, the code has been written in order to dynamically generate the form. Therefore, it was necessary to collect the input data after submitting them by the user. It is done in the `ContentView` file using a function `collectValue()`:

```swift=
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
    } 
    return value
}
```

The function takes a UIComponent as a parameter and defines the component type based on the first part of the `uniqueId` string (thus, it is important for the `uniqueId` to follow the rules described here). If the component type is `form`, meaning it is a simple text form field, its input text has to be recovered. The component is casted to `FormFieldComponent` and its text (actually the wrapped value of the text, as the text variable is a binding) is recovered. Getting the value from the `DatePicker` looks very similar, only it requires providing a date format. This allows further formatting and development of this project, for instance letting the user specify a date format. 
The `collectValue` function returns a value from the component as a String. The `ContentView` has to be adjusted to return all the values. Therefore, two new variables have been created:

```swift=
@State var values: [String] = []
@State private var isDisabledSubmit = false
```

The `values` array collects all the values from the `collectValue` function. The `isDisabledSubmit` decides if the submit button should be disabled (after user submits the data it should not be changed).
As a last step, the `Button` widget is added to the `VStack`:
```swift=
Button(action: {
    for component in controller.uiComponents {
        var value = collectValue(component: component)
        if(value != nil) {
            values.append(collectValue(component: component)!)
        }
    }
    print(values)
    isDisabledSubmit = true
}) {
    Text("SUBMIT")
}
.disabled(isDisabledSubmit)
```

Starting from the bottom, the `.disabled` property of the button is based on the previously created variable, `isDisabledSubmit`. Then, the content of the button is created, here it is just a simple text saying "SUBMIT". The action of the button highly depends on the controller and the `values` array. For each of the UIComponents gathered by the controller, the `collectValue` is called and its result, if not null, is appended to the `values` array. It can be furtherly developed, as now the array is just being printed. Last but not least, the button is disabled by changing the value of `isDisabledSubmit`. 

## Additional features and issues
### Widget styling
When discussing the `Text` widget, it was mentioned that the user can choose the font color, providing a proper hex string in the `.json`. However, the string to `Color` conversion is not available natively. Instead, an extension to the `Color` had to be adopted:
```swift=
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
```

[This](https://stackoverflow.com/questions/56874133/use-hex-color-in-swiftui) StackOverflow question helped provide a way to change the font color based on the hex string.

### Picker and slider UI not updating
There is an issue that even though both picker and slider widgets allow the user to choose their desired value and display all the possible options, the UI does not update - the chosen value is not visible. However, when the data is submitted, the proper value is returned. This means the problem is related to user interface only and should be solved having this in mind. 
There is a similar issue with the `filepicker` - The file is returned properly as its hex value, but the UI does not show its name.


## Summary
Dynamic generation of User Interface can be really helpful. This unusual, fresh approach to UI building from `.json` allows developers to change the appearance of an application without the necessity to distribute a new version of the app. It might be beneficial for the users as well, as their application interface can be up to date without the urge to download more and more updates. Furthermore, this project proves that with a few lines of Swift code, UI generation can come down to a lightweight `.json` file with a reusable structure, what can sometimes make the job faster, simpler or even automatic after coding some scripts. One of the drawbacks of dynamic UI generation can be, as mentioned earlier, the obligation of constant network connection, as without it the view will not be generated. However, most of the bigger apps that might need aa actively changing User Interface already require the network connection.

## References
This project would never happen without the [Build a Server-Driven UI Using UI Components in SwiftUI](https://betterprogramming.pub/build-a-server-driven-ui-using-ui-components-in-swiftui-466ecca97290) tutorial. The Implementation part is mostly just what this article speaks of.
Some parts of the concept come from [Backend Driven Development - iOS](https://medium.com/movile-tech/backend-driven-development-ios-d1c726f2913b) article.
The file picker implementation comes from [this](https://www.youtube.com/watch?v=CcRk6Xew-iY) YouTube video.
