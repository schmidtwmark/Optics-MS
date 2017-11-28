//
//  Optics_MSTests.swift
//  Optics-MSTests
//
//  Created by Mark Schmidt on 4/11/17.
//  Copyright © 2017 Mark Schmidt. All rights reserved.
//

import XCTest

class GeometryTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCircleIntersect() {
       
        let a = Line(m: 0.0, b: 0.0)
        let c = Circle(radius: 2, center: CGPoint(x: 0.0, y: 0.0))
        
        if let intersects = calculateLineCircleIntersection(line: a, circle: c) {
            XCTAssertEqual(CGPoint(x: 2.0, y: 0.0), intersects.0)
            XCTAssertEqual(CGPoint(x: -2.0, y: 0.0), intersects.1)
        } else {
            XCTFail("Found no intersections")
        }
        
        let angled = Line(m: 1.0, b: 0.0)
        if let intersects = calculateLineCircleIntersection(line: angled, circle: c) {
            XCTAssertEqual(CGPoint(x: sqrt(2), y: sqrt(2)), intersects.0)
            XCTAssertEqual(CGPoint(x: -sqrt(2), y: -sqrt(2)), intersects.1)
        } else {
            XCTFail("Found no intersection")
        }
        
    }
    
    
    func testNoIntersect() {
        let a = Line(m: 4.0, b: 20.0)
        let c = Circle(radius: 2, center: CGPoint(x: 0.0, y: 0.0))
        
        if let _ = calculateLineCircleIntersection(line: a, circle: c) {
            XCTFail("Intersections detected")
        }
    }
    
    func testAcuteAngle() {
        let a = Line(m: 0.0, b: 0.0)
        let b = Line(m: 1.0, b: 0.0)
        
        let angle = calculateAngleBetweenLines(a: a, b: b)
        XCTAssertEqual(abs(angle), CGFloat.pi/4)
        
        let angle2 = calculateAngleBetweenLines(a: b, b: a)
        XCTAssertEqual(abs(angle2), CGFloat.pi/4)
    
        
    }
    
    func testObtuseAngle() {
        let a = Line(m: 0.0, b: 0.0)
        let b = Line(m: -1.0, b: 0.0)
        let angle = calculateAngleBetweenLines(a: a, b: b)
        XCTAssertEqual(abs(angle), CGFloat.pi/4)
        
        
        let angle2 = calculateAngleBetweenLines(a: b, b: a)
        XCTAssertEqual(abs(angle2), CGFloat.pi/4)
      
    }
    
    func testCircleSerialization() {
        let circle = Circle(radius: 2.0, center: CGPoint(x: 0.0, y: 3.0))
        let data = circle.serialize()
        print(data)
        
        let deserialized = Circle(data: data)
        XCTAssertEqual(deserialized.center, circle.center)
        XCTAssertEqual(deserialized.radius, circle.radius)
        
    }
    
    
}
