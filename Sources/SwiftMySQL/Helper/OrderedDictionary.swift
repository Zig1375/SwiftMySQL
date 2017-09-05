import Foundation

public struct OrderedDictionary<KeyType:Hashable, ValueType> : CustomStringConvertible {
    fileprivate var _dictionary:Dictionary<KeyType, ValueType>
    fileprivate var _keys:Array<KeyType>
    fileprivate let skip_nil : Bool;

    public init(skip_nil : Bool = true) {
        _dictionary = [:]
        _keys = []
        self.skip_nil = skip_nil;
    }

    public init(minimumCapacity:Int, skip_nil : Bool = true) {
        _dictionary = Dictionary<KeyType, ValueType>(minimumCapacity:minimumCapacity)
        _keys = Array<KeyType>()
        self.skip_nil = skip_nil;
    }

    public init(_ dictionary:Dictionary<KeyType, ValueType>, skip_nil : Bool = true) {
        _dictionary = dictionary
        _keys = [KeyType](dictionary.keys)
        self.skip_nil = skip_nil;
    }

    public init(_ orderedDictionary: OrderedDictionary<KeyType, ValueType>){
        _dictionary = orderedDictionary._dictionary
        _keys = orderedDictionary._keys
        skip_nil = orderedDictionary.skip_nil
    }

    public subscript(key:KeyType) -> ValueType? {
        get {
            return _dictionary[key]
        }
        set {
            if ((self.skip_nil) && (newValue == nil)) {
                self.removeValue(forKey: key)
                return;
            }

            if (!_keys.contains(key)) {
                _keys.append(key);
            }

            _dictionary[key] = newValue;
        }
    }

    public mutating func updateValue(value:ValueType, forKey key:KeyType) -> ValueType? {

        let oldValue = _dictionary.updateValue(value, forKey: key)
        if oldValue == nil {
            _keys.append(key)
        }
        return oldValue
    }

    public mutating func removeValue(forKey:KeyType) {
        _keys = _keys.filter { $0 != forKey }
        _dictionary.removeValue(forKey: forKey)
    }

    public mutating func removeAll(keepCapacity:Int) {
        _keys = []
        _dictionary = Dictionary<KeyType,ValueType>(minimumCapacity: keepCapacity)
    }

    public mutating func sortKeys( isOrderedBefore: (KeyType, KeyType) -> Bool) {
        _keys.sort(by: isOrderedBefore)
    }

    public var count: Int { get { return _dictionary.count } }

    // keys isn't lazy evaluated because it's just an array anyway
    public var keys:[KeyType] { get { return _keys } }

    // values is lazy evaluated because of the dictionary lookup and creating a new array
    public var values:AnyIterator<ValueType> {
        get {
            var index = 0
            return AnyIterator({ () -> ValueType? in
                if index >= self._keys.count {
                    return nil
                }
                else {
                    let key = self._keys[index]
                    index += 1
                    return self._dictionary[key]
                }
            })
        }
    }

    public var description : String {
        var result = [String]();
        for (key, val) in self {
            result.append("\"\(key)\" : \"\(val)\"");
        }

        return result.joined(separator: ", ");
    }
}

extension OrderedDictionary : Sequence {
    public func makeIterator() -> AnyIterator<(KeyType, ValueType)> {
        var index = 0
        return AnyIterator({ () -> (KeyType, ValueType)? in
            if index >= self._keys.count {
                return nil
            }
            else {
                let key = self._keys[index]
                index += 1
                return (key, self._dictionary[key]!)
            }
        })
    }
}

public func ==<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs._keys == rhs._keys && lhs._dictionary == rhs._dictionary
}

public func !=<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs._keys != rhs._keys || lhs._dictionary != rhs._dictionary
}