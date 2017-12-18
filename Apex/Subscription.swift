//
//  Subscription.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/16/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License
//



public
protocol Subscription {
	func launch(dispatcher: Dispatcher)
	func cancel()
}
