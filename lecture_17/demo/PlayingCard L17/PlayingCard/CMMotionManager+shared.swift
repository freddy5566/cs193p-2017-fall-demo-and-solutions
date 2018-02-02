//
//  CMMotionManager+shared.swift
//  PlayingCard
//
//  Created by CS193p Instructor on 11/29/17.
//  Copyright © 2017 CS193p Instructor. All rights reserved.
//

import CoreMotion

// we add a static var
// so we can get a "shared" CMMotionManager
// that we could use throughout our app
// by simply accessing CMMotionManager.shared

extension CMMotionManager {
    static var shared = CMMotionManager()
}
