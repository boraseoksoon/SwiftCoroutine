//
//  Coroutine.swift
//  SwiftCoroutine
//
//  Created by Alex Belozierov on 01.02.2020.
//  Copyright © 2020 Alex Belozierov. All rights reserved.
//

import Dispatch

/// Additional struct with utility methods to work with coroutines.
///
/// - Important: All `await()` methods must be called inside a coroutine.
///
/// To check if inside a coroutine, use `Coroutine.isInsideCoroutine`.
/// If you call `await()` outside the coroutine, the precondition inside these methods will fail, and you'ill get an error.
/// In -Ounchecked builds, where preconditions are not evaluated to avoid any crashes,
/// a thread-blocking mechanism is used for waiting the result.
///
public struct Coroutine {
    
    /// Returns `true` if this property is called inside a coroutine.
    /// ```
    /// func awaitSomeData() throws -> Data {
    ///     //check if inside a coroutine
    ///     guard Coroutine.isInsideCoroutine else { throw . . . some error . . . }
    ///     Coroutine.await { . . . return some data . . . }
    /// }
    /// ```
    @inlinable public static var isInsideCoroutine: Bool {
        currentPointer != nil
    }
    
    // MARK: - await
    
    /// Suspends a coroutine and resumes it on callback. Must be called inside a coroutine.
    /// ```
    /// queue.startCoroutine {
    ///     Coroutine.await { callback in
    ///         someAsyncFunc { callback() }
    ///     }
    /// }
    /// ```
    /// - Parameter callback: The callback для resume coroutine.
    @inlinable public static func await(_ callback: (@escaping () -> Void) -> Void) {
        current.await { completion in callback { completion(()) } }
    }
    
    /// Suspends a coroutine and resumes it on callback.
    /// ```
    /// queue.startCoroutine {
    ///     let result = Coroutine.await { callback in
    ///         someAsyncFunc { result in callback(result) }
    ///     }
    /// }
    /// ```
    /// - Parameter callback: The callback for resuming a coroutine. Must be called inside a coroutine.
    /// - Returns: The result which is passed to callback.
    @inlinable public static func await<T>(_ callback: (@escaping (T) -> Void) -> Void) -> T {
        current.await(callback)
    }
    
    /// Suspends a coroutine and resumes it on callback. Must be called inside a coroutine.
    /// ```
    /// queue.startCoroutine {
    ///     let (a, b) = Coroutine.await { callback in
    ///         someAsyncFunc(callback: callback)
    ///     }
    /// }
    /// ```
    /// - Parameter callback: The callback для resume coroutine.
    /// - Returns: The result which is passed to callback.
    @inlinable public static func await<T, N>(_ callback: (@escaping (T, N) -> Void) -> Void) -> (T, N) {
        current.await { completion in callback { a, b in completion((a, b)) } }
    }
    
    /// Suspends a coroutine and resumes it on callback.
    /// ```
    /// queue.startCoroutine {
    ///     let (a, b, c) = Coroutine.await { callback in
    ///         someAsyncFunc(callback: callback)
    ///     }
    /// }
    /// ```
    /// - Parameter callback: The callback для resume coroutine. Must be called inside a coroutine.
    /// - Returns: The result which is passed to callback.
    @inlinable public static func await<T, N, M>(_ callback: (@escaping (T, N, M) -> Void) -> Void) -> (T, N, M) {
        current.await { completion in callback { a, b, c in completion((a, b, c)) } }
    }
    
    // MARK: - delay
    
    /// Suspends a coroutine for a certain time.  Must be called inside a coroutine.
    /// ```
    /// queue.startCoroutine {
    ///     while !someCondition() {
    ///         Coroutine.delay(.seconds(1))
    ///     }
    /// }
    /// ```
    /// - Parameter time: The time interval for which a coroutine will be suspended.
    @inlinable public static func delay(_ time: DispatchTimeInterval) {
        var timer: DispatchSourceTimer!
        await {
            timer = DispatchSource.createTimer(timeout: .now() + time, handler: $0)
            if #available(OSX 10.12, iOS 10.0, *) {
                timer.activate()
            } else {
                timer.resume()
            }
        }
    }
    
}
