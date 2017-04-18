//
//  PuzzleTest.swift
//  Optics-MS
//
//  Created by Mark Schmidt on 4/18/17.
//  Copyright © 2017 Mark Schmidt. All rights reserved.
//

import XCTest

class PuzzleTest: XCTestCase {
    

    
    func testRandomEmpty() {
        let range : ClosedRange<CGFloat> = 0.0 ... 0.0
        let random = Puzzle.generateRandomNumber(withinRange: range)
        XCTAssertEqual(random, 0.0)
        
    }
    
    func testRandomNumber() {
        let range : ClosedRange<CGFloat> = -4.0 ... 5.0
        let random = Puzzle.generateRandomNumber(withinRange: range)
        print(random)
        XCTAssertTrue(range.contains(random))
    }
    
   
    
}
