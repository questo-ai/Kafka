import UIKit

struct Token {
    var vector: CIVector
    var idx: Int
    var string: String
}

enum Move {
    case SHIFT
    case RIGHT
    case LEFT
}

// TODO: use collection protocols
class DefaultList {
    var defaultValue: Int
    var list: [Int] = []
    init(defaultValue: Int? = nil) {
        self.defaultValue = defaultValue!
    }

    func getitem(index: Int) -> Int{
        if (index > self.list.count) {
            return self.defaultValue
        } else {
            return list[index]
        }
    }
    
    func append(value: Int) {
        self.list.append(value)
    }
}

class Parse {
    var n: Int
    var heads: [Int] = []
    var labels: [Int] = []
    var lefts: [DefaultList] = []
    var rights: [DefaultList] = []
    
    
    init(n: Int) {
        self.n = n
        for _ in 0...n+1 {
            self.lefts.append(DefaultList(defaultValue: 0))
            self.rights.append(DefaultList(defaultValue: 0))
        }
    }
    
    
    func add(head: Int, child: Int, label: Int? = nil) {
        self.heads[child] = head
        self.labels[child] = label!
        if (child < head) {
            self.lefts[head].append(value: child)
        } else {
            self.rights[head].append(value: child)
        }
    }
}


class Parser {
    var stack = [1]
    var parse: Parse?
    init() {
     
    }
    
    func parse(words: [String]) {
        let n = words.count
        self.parse = Parse(n: n)
        var i = 2
        while i+1 < n {
            
        }
    }
    
    func transition(move: Move, i: Int, stack: [Int], parse: Parse) -> Int {
        if (move == Move.SHIFT) {
            self.stack.append(i)
            return i + 1
        } else if (move == Move.RIGHT) {
            parse.add(head: self.stack[-2], child: self.stack.removeLast())
            return i
        } else if (move == Move.LEFT) {
            parse.add(head: i, child: self.stack.removeLast())
            return i
        } else {
            return 0
        }
    }
}



