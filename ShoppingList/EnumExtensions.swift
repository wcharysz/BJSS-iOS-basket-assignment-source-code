//
//  EnumExtensions.swift
//  ShoppingList
//
//  Created by Wojciech Charysz on 19.10.15.
//  Copyright © 2015 SlawekTrybus. All rights reserved.
//

import Foundation

protocol EnumCollection : Hashable {}
extension EnumCollection {
    static func cases() -> EnumSequence<Self> {
        return EnumSequence()
    }
}

class EnumGenerator<Enum : Hashable> : GeneratorType {
    var rawEnum = 0
    var done = false
    
    func getCase(ptr: UnsafeMutablePointer<Int>) -> Enum {
        return UnsafeMutablePointer<Enum>(ptr).memory
    }
    
    func next() -> Enum? {
        if done { return nil }
        
        let enumCase = getCase(&rawEnum)
        guard enumCase.hashValue == rawEnum else {
            done = true
            return nil
        }
        
        rawEnum++
        return enumCase
    }
}

class SingleEnumGenerator<Enum : Hashable> : EnumGenerator<Enum> {
    override func next() -> Enum? {
        return done ? nil : { done = true; return unsafeBitCast((), Enum.self) }()
    }
}

struct EnumSequence<Enum : Hashable> : SequenceType {
    func generate() -> EnumGenerator<Enum> {
        switch sizeof(Enum) {
        case 0: return SingleEnumGenerator()
        default: return EnumGenerator()
        }
    }
}

func iterateEnum<T: Hashable>(_: T.Type) -> AnyGenerator<T> {
    var i = 0
    return anyGenerator {
        let next = withUnsafePointer(&i) { UnsafePointer<T>($0).memory }
        return next.hashValue == i++ ? next : nil
    }
}