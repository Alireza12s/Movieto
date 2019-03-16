import Foundation

class QueryItems: Codable,Hashable{
    static func == (lhs: QueryItems, rhs: QueryItems) -> Bool {
        return lhs.text == rhs.text
    }
    
    
    var text: String = ""
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.text)
    }
    
    
}
