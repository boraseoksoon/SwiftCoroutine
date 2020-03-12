////
////  CoFuture+Await.swift
////  SwiftCoroutine
////
////  Created by Alex Belozierov on 31.12.2019.
////  Copyright © 2019 Alex Belozierov. All rights reserved.
////
//
//import Foundation
//
//extension CoFuture {
//    
//    public func await() throws -> Output {
//        let coroutine = try Coroutine.current()
//        while true {
//            if let result = result { return try result.get() }
//            coroutine.suspend {
//                self.subscribe(with: coroutine, handler: coroutine.resume)
//            }
//        }
//    }
//    
//    @inlinable public func awaitResult() -> OutputResult {
//        Result(catching: await)
//    }
//    
//    public func await(timeout: DispatchTime) throws -> Output {
//        let coroutine = try Coroutine.current(), mutex = NSLock()
//        var isTimeOut = false
//        let timer = DispatchSource.createTimer(timeout: timeout) {
//            mutex.lock()
//            isTimeOut = true
//            mutex.unlock()
//            if coroutine.state == .suspended { coroutine.resume() }
//        }
//        timer.activate()
//        defer { timer.cancel() }
//        while true {
//            mutex.lock()
//            if isTimeOut { throw CoFutureError.timeout }
//            if let result = result { return try result.get() }
//            coroutine.suspend {
//                self.subscribe(with: coroutine) {
//                    if coroutine.state == .suspended { coroutine.resume() }
//                }
//                mutex.unlock()
//            }
//        }
//    }
//    
//}
//
//

extension CoFuture {
    
    // MARK: - await
    
    public func await() throws -> Value {
        let coroutine = try Coroutine.current()
        lock()
        if let result = _result {
            unlock()
            return try result.get()
        }
        append { _ in coroutine.coroutine.resume() }
        coroutine.coroutine.suspend(with: unlock)
        return try _result!.get()
    }
    
//    public func await2() throws -> Value {
//        try FooAwaitable(mutex: mutex!) { completion in
//            if let result = self._result { return result }
//            self.append(callback: completion)
//            return nil
//        }.await()
//    }
    
}
