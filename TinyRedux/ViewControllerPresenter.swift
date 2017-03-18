//
//  ViewControllerPresenter.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import UIKit


public struct ViewControllerFactory {
	public let build: [String: () -> UIViewController]
	public let alertControllerIDs: Set<String>
	
	public init(factories: [String: () -> UIViewController], alertIDs: [String]) {
		build = factories
		alertControllerIDs = Set(alertIDs)
	}
}

public final class ViewControllerPresenter<State, Store: ObservableStore> where Store.State == State {

	public init(rootViewController: UIViewController, factory: ViewControllerFactory, store: Store, lens: @escaping (State) -> [String]) {
		self.factory = factory
		self.rootViewController = rootViewController
		unsubscriber = store.subscribe(observer: { [weak self] presentationStack in
			self?.configure(from: presentationStack)
		}, lens: lens)
	}

	func configure(from presentationStack: [String]) {
		queue.async {
			let semaphore = DispatchSemaphore(value: 0)

			func pop(id: String) {
				guard self.factory.alertControllerIDs.contains(id) == false else { return }
				let top = self.topViewController()
				assert(top != self.rootViewController, "Can't dismiss the root view controller. Did you forget fill in the alert IDs?")
				DispatchQueue.main.async {
					top.dismiss(animated: true, completion: {
						semaphore.signal()
					})
				}
				semaphore.wait()
			}
			
			func push(id: String) {
				guard let vc = self.factory.build[id]?() else { fatalError("can't construct view controller \(id)") }
				let top = self.topViewController()
				DispatchQueue.main.async {
					top.present(vc, animated: true, completion: {
						semaphore.signal()
					})
				}
				semaphore.wait()
			}
			
			popPush(current: self.currentStack, target: presentationStack, pop: pop, push: push)
			self.currentStack = presentationStack
		}
	}

	private var unsubscriber: Unsubscriber? = nil
	private var currentStack: [String] = []
	private let queue = DispatchQueue(label: "view_controller_presenter")
	private let factory: ViewControllerFactory
	private let rootViewController: UIViewController

	private func viewControllerCount() -> Int {
		var result = 0
		var controller = rootViewController
		while let vc = controller.presentedViewController {
			result += 1
			controller = vc
		}
		return result
	}

	private func topViewController() -> UIViewController {
		var result = rootViewController
		while let vc = result.presentedViewController {
			result = vc
		}
		return result
	}
}
