extension Set where Element : Hashable {
    static func += (left: inout Set<Element>, right: Element) {
        left.insert(right)
    }

    static func -= (left: inout Set<Element>, right: Element) {
        left.remove(right)
    }
}