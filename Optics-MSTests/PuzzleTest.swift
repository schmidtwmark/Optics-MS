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
    
    func testLensSerialization() {
        let lens = Lens(leftRadius: 250.0, rightRadius: 240.5, height: 40.0, refractionIndex: 3)
        let data = lens.serialize()
        let lens2 = Lens(withData: data)
        
        XCTAssertEqual(lens.height, lens2.height)
        //XCTAssertEqual(lens.leftCircle.center, lens2.leftCircle.center)
    }
    
    func testPuzzleSerialization() {
        let puzzle = Puzzle(lens: Lens(leftRadius: 250.0, rightRadius: 240.5, height: 40.0, refractionIndex: 3), originAngle: 20.0, solutionY: 30.0, showStatus: .showAll, difficulty: .Medium)
        let data = puzzle.serialize()
        let puzzle2 = Puzzle(data: data)
        XCTAssertEqual(puzzle.originAngle, puzzle2.originAngle)
        XCTAssertEqual(puzzle.showStatus, puzzle2.showStatus)
        
    }
    
   
    
}
