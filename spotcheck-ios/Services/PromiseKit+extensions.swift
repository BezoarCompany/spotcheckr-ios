//
//  PromiseKitHelper.swift
//  TrueID
//
//  Created by Kittiphat Srilomsak on 3/21/2560 BE.
//  https://medium.com/@dimitarstefanovski/how-to-use-promisekit-for-swift-4bbb9e40f7cc

//  Modified by Spotcheck for 2020 Promise Kit
//  Copyright © 2017 peatiscoding.me all rights reserved.

import PromiseKit

extension Promise {
    
    /**
     * Create a final Promise that chain all delayed promise callback all together.
     */
    static func chain(_ promisesArray:[() -> Promise<T>]) -> Promise<[T]> {
        return Promise<[T]> { promise in
            var out = [T]()
            
            let fp:Promise<T>? = promisesArray.reduce(nil) { (accumulatedVar, closureElement) in
                return accumulatedVar?.then { c -> Promise<T> in
                    out.append(c)
                    return closureElement()
                } ?? closureElement()
            }
            
            fp?.done { c -> Void in
                out.append(c)
                return promise.fulfill(out)
            }.catch { err2 in
                return promise.reject(err2)
            }
            
        }
    }
}
