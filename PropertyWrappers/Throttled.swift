//
//  Throttled.swift
//  PropertyWrappers
//
//  Created by Petro Korienev on 2/9/20.
//  Copyright © 2020 PetroKorienev. All rights reserved.
//

import Foundation

@propertyWrapper
public class Throttled<T> {
    private let throttler: Throttler<T>
    
    public init(_ interval: TimeInterval, on queue: DispatchQueue = .main) {
        throttler = Throttler(interval, on: queue)
    }
    public func receive(_ value: T) {
        throttler.receive(value)
    }
    public func on(throttled: @escaping (T) -> ()) {
        throttler.on(throttled: throttled)
    }
    public var wrappedValue: T? {
        get { throttler.value }
        set(v) { if let v = v { throttler.receive(v) } }
    }
}

public class Throttler<T> {
    private(set) var value: T? = nil
    private var valueTimestamp: Date? = nil
    private var interval: TimeInterval
    private var queue: DispatchQueue
    private var callbacks: [(T) -> ()] = []
    
    public init(_ interval: TimeInterval, on queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }
    public func receive(_ value: T) {
        self.value = value
        guard valueTimestamp == nil else { return }
        self.dispatchThrottle()
    }
    public func on(throttled: @escaping (T) -> ()) {
        self.callbacks.append(throttled)
    }
    private func dispatchThrottle() {
        self.valueTimestamp = Date()
        queue.asyncAfter(deadline: .now() + interval) { [weak self] in
            self?.onDispatch()
        }
    }
    private func onDispatch() {
        self.valueTimestamp = nil
        sendValue()
    }
    private func sendValue() {
        if let value = self.value { callbacks.forEach { $0(value) } }
    }
}
