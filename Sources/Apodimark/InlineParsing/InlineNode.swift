//
//  InlineNode.swift
//  Apodimark
//

public enum ReferenceKind {
    case normal, unwrapped

    var textWidth: Int {
        switch self {
        case .normal   : return 1
        case .unwrapped: return 2
        }
    }
}

enum InlineNodeKind <View: BidirectionalCollection> where
    View.SubSequence: BidirectionalCollection,
    View.SubSequence.Iterator.Element == View.Iterator.Element
{
    indirect case reference(ReferenceKind, title: Range<View.Index>, definition: ReferenceDefinition)
    case code(Int)
    case emphasis(Int)
    case text
    case softbreak
    case hardbreak
}

struct InlineNode <View: BidirectionalCollection> where
    View.SubSequence: BidirectionalCollection,
    View.SubSequence.Iterator.Element == View.Iterator.Element
{

    let kind: InlineNodeKind<View>
    let (start, end): (View.Index, View.Index)

    func contentRange(inView view: View) -> Range<View.Index> {
        switch kind {

        case .reference(_, let title, _):
            return title

        case .code(let l), .emphasis(let l):
            return view.index(start, offsetBy: View.IndexDistance(l.toIntMax())) ..< view.index(end, offsetBy: View.IndexDistance(-l.toIntMax()))

        default:
            return start ..< end
        }
    }

    var children: LinkedList<InlineNode> = []

    init(kind: InlineNodeKind<View>, start: View.Index, end: View.Index) {
        (self.kind, self.start, self.end) = (kind, start, end)
    }
}

/*
 This is only used to efficiently sort an array of InlineNode. For reasons I can’t understand, 
 sorting an array an InlineNode with a closure like `nodes.sort { $0.start < $1.start }` is less efficient
 than making InlineNode conform to Comparabe and use `nodes.sort()`.
 */
extension InlineNode: Comparable {
    static func <  (lhs: InlineNode, rhs: InlineNode) -> Bool { return lhs.start <  rhs.start }
    static func <= (lhs: InlineNode, rhs: InlineNode) -> Bool { return lhs.start <= rhs.start }
    static func == (lhs: InlineNode, rhs: InlineNode) -> Bool { return lhs.start == rhs.start }
    static func >  (lhs: InlineNode, rhs: InlineNode) -> Bool { return lhs.start >  rhs.start }
    static func >= (lhs: InlineNode, rhs: InlineNode) -> Bool { return lhs.start >= rhs.start }
}


