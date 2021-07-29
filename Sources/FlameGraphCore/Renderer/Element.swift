import Foundation



public class Element {
    public var name: String = ""
    public var content: String = ""
    public var attrs: [String :String] = [:]
    public var subElements:[Element] = [] 
    public var text:String = ""
    
    
    init(name:String, content:String = "", attrs:[String:String] = [:],subElements:[Element] = []) {
        self.name = name
        self.content = content
        self.attrs = attrs
        self.subElements = subElements
        self.text = "<\(self.name) \(attrsText(self.attrs))>\(self.content)\(subText())</\(self.name)> \n"
        
    }
    
    
    public func attrsText(_ attrs:[String:String]) -> String {
        var text = ""
        if attrs.keys.count > 0 {
            for (key,value) in attrs {
                text += " \(key)=\"\(value)\""
            }
        }
        return text
    }
    
    private func subText() -> String {
        var text = ""
        for sub in self.subElements {
            text.append(sub.text)
        }
        return text
    }
}


public class EmptyElement:Element {
    
    init(name:String, attrs:[String:String]) {
        super.init(name: name, content: "", attrs: attrs, subElements: [])
        self.name = name
        self.attrs = attrs
        self.text = "<\(name) \(attrsText(attrs))/> \n"
    }
}
