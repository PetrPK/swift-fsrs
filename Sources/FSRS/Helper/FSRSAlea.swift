//
//  FSRSAlea.swift
//
//  Created by nkq on 10/13/24.
//

import Foundation

class FSRSAlea {
    struct State: Equatable {
        var c: Int
        var s0: Double
        var s1: Double
        var s2: Double
    }
    
    private var c: Int
    private var s0: Double
    private var s1: Double
    private var s2: Double

    init(seed: Any? = nil) {
        var mash = Mash()
        c = 1
        s0 = mash.mash(" ")
        s1 = mash.mash(" ")
        s2 = mash.mash(" ")

        let seedValue: String = String(describing: seed ?? Date().timeIntervalSince1970)
        s0 -= mash.mash(seedValue)
        if s0 < 0 { s0 += 1 }
        s1 -= mash.mash(seedValue)
        if s1 < 0 { s1 += 1 }
        s2 -= mash.mash(seedValue)
        if s2 < 0 { s2 += 1 }
    }

    func next() -> Double {
        let t = 2091639 * s0 + Double(c) * pow(2, -32)
        s0 = s1
        s1 = s2
        c = Int(floor(t))
        s2 = t - floor(t)
        return s2
    }

    var state: State {
        get {
            State(c: c, s0: s0, s1: s1, s2: s2)
        }
        set {
            c = newValue.c
            s0 = newValue.s0
            s1 = newValue.s1
            s2 = newValue.s2
        }
    }
}

struct Mash {
    var n: Double = 0xefc8249d
    
    mutating func mash(_ str: String) -> Double {
        var n: Double = self.n
        for c in str {
            n += Double(UInt32(c.asciiValue!))
            var h = 0.02519603282416938 * n
            n = Double(UInt32(h.rounded(.down)))
            h -= n
            h *= n
            n = Double(UInt32(h.rounded(.down)))
            h -= n
            n += h * pow(2, 32)
        }
        self.n = n
        return n * pow(2, -32)
    }
}

protocol PRNG {
    func next() -> Double
    func int32() -> Int32
    func double() -> Double
    func state() -> FSRSAlea.State
    func importState(_ state: FSRSAlea.State)
}

struct RandomNumberGeneratorWrapper: PRNG {
    private let alea: FSRSAlea
    
    init(seed: Any? = nil) {
        alea = FSRSAlea(seed: seed)
    }

    func next() -> Double {
        alea.next()
    }

    func int32() -> Int32 {
        Int32(truncatingIfNeeded: Int(alea.next() * Double(0x100000000)))
    }

    func double() -> Double {
        next() + Double(UInt(next() * 0x200000)) * pow(2, -53)
    }

    func state() -> FSRSAlea.State {
        alea.state
    }

    func importState(_ state: FSRSAlea.State) {
        alea.state = state
    }
}

func alea(seed: Any? = nil) -> RandomNumberGeneratorWrapper {
    RandomNumberGeneratorWrapper(seed: seed)
}

