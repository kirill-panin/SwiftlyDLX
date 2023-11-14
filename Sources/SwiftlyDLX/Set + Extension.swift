extension Set where Element : Hashable {
    static func += (left: inout Set<Element>, right: Element) {
        left.insert(right)
    }

    static func -= (left: inout Set<Element>, right: Element) {
        left.remove(right)
    }

    static func += (left: inout Set<Element>, right: Set<Element>) {
        right.forEach { left.insert($0) }
    }

    static func -= (left: inout Set<Element>, right: Set<Element>) {
        right.forEach { left.remove($0) }
    }
}