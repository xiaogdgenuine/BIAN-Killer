//
//  TimedSequence.swift
//  BackgroundItemsAddedKiller
//
//  Created by xiaogd on 2023/2/20.
//

import Foundation
import Combine

struct TimedSequence<T: Any>  {
    typealias TimedJointPublisher = (Publishers.Zip<Publishers.Sequence<[T], Never>, Publishers.Autoconnect<Timer.TimerPublisher>>)

    var sink: AnyCancellable?

    init(array: [T], interval: TimeInterval, closure: @escaping (T) -> Void) {
        let delayPublisher = Timer.publish(every: interval, on: .main, in: .default).autoconnect()
        let timedJointPublisher = Publishers.Zip(array.publisher, delayPublisher)
        self.sink = timedJointPublisher.sink(receiveValue: {r in
            closure(r.0)
        })
    }
}
