//
//  KeychainTests.swift
//  SSKeychain
//
//  Created by Sam Soffes on 3/10/16.
//  Copyright © 2010-2016 Sam Soffes. All rights reserved.
//

import XCTest
import SSKeychain

class KeychainTests: XCTestCase {

	// MARK: - Properties

	let testService = "SSToolkitTestService"
	let testAccount = "SSToolkitTestAccount"
	let testPassword = "SSToolkitTestPassword"
	let testLabel = "SSToolkitLabel"


	// MARK: - XCTestCase

	override func tearDown() {
		SSFKeychain.deletePasswordForService(testService, account: testAccount)
		super.tearDown()
	}


	// MARK: - Tests

	func testNewItem() {
		// New item
		let newQuery = SSFKeychainQuery()
		newQuery.password = testPassword
		newQuery.service = testService
		newQuery.account = testAccount
		newQuery.label = testLabel
		try! newQuery.save()

		// Look up
		let lookupQuery = SSFKeychainQuery()
		lookupQuery.service = testService
		lookupQuery.account = testAccount
		try! lookupQuery.fetch()

		XCTAssertEqual(newQuery.password, lookupQuery.password)

		// Search for all accounts
		let allQuery = SSFKeychainQuery()
		var accounts = try! allQuery.fetchAll()
		XCTAssertTrue(self.accounts(accounts, containsAccountWithName: testAccount), "Matching account was not returned")

		// Check accounts for service
		allQuery.service = testService
		accounts = try! allQuery.fetchAll()
		XCTAssertTrue(self.accounts(accounts, containsAccountWithName: testAccount), "Matching account was not returned")

		// Delete
		let deleteQuery = SSFKeychainQuery()
		deleteQuery.service = testService
		deleteQuery.account = testAccount
		try! deleteQuery.deleteItem()
	}

	func testPasswordObject() {
		let newQuery = SSFKeychainQuery()
		newQuery.service = testService
		newQuery.account = testAccount

		let dictionary: [String: NSObject] = [
			"number": 42,
			"string": "Hello World"
		]

		newQuery.passwordObject = dictionary
		try! newQuery.save()

		let lookupQuery = SSFKeychainQuery()
		lookupQuery.service = testService
		lookupQuery.account = testAccount
		try! lookupQuery.fetch()

		let readDictionary = lookupQuery.passwordObject as! [String: NSObject]
		XCTAssertEqual(dictionary, readDictionary)
	}

	func testCreateWithMissingInformation() {
		var query = SSFKeychainQuery()
		query.service = testService
		query.account = testAccount
		XCTAssertThrowsError(try query.save())

		query = SSFKeychainQuery()
		query.account = testAccount
		query.password = testPassword
		XCTAssertThrowsError(try query.save())

		query = SSFKeychainQuery()
		query.service = testService
		query.password = testPassword
		XCTAssertThrowsError(try query.save())
	}

	func testDeleteWithMissingInformation() {
		var query = SSFKeychainQuery()
		query.account = testAccount
		XCTAssertThrowsError(try query.deleteItem())

		query = SSFKeychainQuery()
		query.service = testService
		XCTAssertThrowsError(try query.deleteItem())

		query = SSFKeychainQuery()
		query.account = testAccount
		XCTAssertThrowsError(try query.deleteItem())
	}

	func testFetchWithMissingInformation() {
		var query = SSFKeychainQuery()
		query.account = testAccount
		XCTAssertThrowsError(try query.fetch())

		query = SSFKeychainQuery()
		query.service = testService
		XCTAssertThrowsError(try query.fetch())
	}

	func testSynchronizable() {
		let createQuery = SSFKeychainQuery()
		createQuery.service = testService
		createQuery.account = testAccount
		createQuery.password = testPassword
		createQuery.synchronizationMode = .Yes
		try! createQuery.save()

		let noFetchQuery = SSFKeychainQuery()
		noFetchQuery.service = testService
		noFetchQuery.account = testAccount
	    noFetchQuery.synchronizationMode = .No
		XCTAssertThrowsError(try noFetchQuery.fetch())
		XCTAssertNotEqual(createQuery.password, noFetchQuery.password)

		let anyFetchQuery = SSFKeychainQuery()
		anyFetchQuery.service = testService
		anyFetchQuery.account = testAccount
		anyFetchQuery.synchronizationMode = .Any
		try! anyFetchQuery.fetch()
		XCTAssertEqual(createQuery.password, anyFetchQuery.password)
	}

	func testConvenienceMethods() {
		// Create a new item
		SSFKeychain.setPassword(testPassword, forService: testService, account: testAccount)

		// Check password
		XCTAssertEqual(testPassword, SSFKeychain.passwordForService(testService, account: testAccount))

		// Check all accounts
		XCTAssertTrue(accounts(SSFKeychain.allAccounts(), containsAccountWithName: testAccount))

		// Check account
		XCTAssertTrue(accounts(SSFKeychain.accountsForService(testService), containsAccountWithName: testAccount))

		#if !os(OSX)
			SSFKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
			XCTAssertEqual(String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly), String(SSFKeychain.accessibilityType().takeRetainedValue()))
		#endif
	}

	func testUpdateAccessibilityType() {
		SSFKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)

		// Create a new item
		SSFKeychain.setPassword(testPassword, forService: testService, account: testAccount)

		// Check all accounts
		XCTAssertTrue(accounts(SSFKeychain.allAccounts(), containsAccountWithName: testAccount))

		// Check account
		XCTAssertTrue(accounts(SSFKeychain.accountsForService(testService), containsAccountWithName: testAccount))

		SSFKeychain.setAccessibilityType(kSecAttrAccessibleAlwaysThisDeviceOnly)
		SSFKeychain.setPassword(testPassword, forService: testService, account: testAccount)

		// Check all accounts
		XCTAssertTrue(accounts(SSFKeychain.allAccounts(), containsAccountWithName: testAccount))

		// Check account
		XCTAssertTrue(accounts(SSFKeychain.accountsForService(testService), containsAccountWithName: testAccount))
	}
	

	// MARK: - Private

	private func accounts(accounts: [[String: AnyObject]], containsAccountWithName name: String) -> Bool {
		for account in accounts {
			if let acct = account["acct"] as? String where acct == name {
				return true
			}
		}

		return false
	}
}
