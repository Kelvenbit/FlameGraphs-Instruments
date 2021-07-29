import Foundation

public class CallGraphNode {
    var symbol: Symbol
    var subNodes: [CallGraphNode] = []
    var parentNode: CallGraphNode?
    var x:Float = 0.0
    var width:Float = 0.0
    
    init(symbol: Symbol) {
        self.symbol = symbol
    }
}

extension CallGraphNode {
    
    
    var maxDepth: Int {
        var result = symbol.depthLevel
        for node in subNodes {
            result = max(node.maxDepth, result)
        }
        return result
    }
    
    
    func startX(uw:Float) -> Float {
        
        var x:Float = 0
        let parent_x = self.parentNode?.x ?? 10
        
        if let sameLevelNodes = self.parentNode?.subNodes {
            for node in sameLevelNodes {
                if node.symbol == self.symbol {
                    break
                }
                x += node.width
            }
        }
        
        return x + parent_x
        
    }
}
