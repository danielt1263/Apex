//
//  ViewControllerPresenter.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import UIKit


public final class ViewControllerPresenter<State, Store: ObservableStore> where Store.State == State {

	public init(rootViewController: UIViewController, factories: [String: () -> UIViewController], store: Store, lens: @escaping (State) -> [String]) {
		self.factories = factories
		self.rootViewController = rootViewController
		unsubscriber = store.subscribe(observer: { [weak self] presentationStack in
			self?.configure(from: presentationStack)
		}, lens: lens)
	}

	func configure(from presentationStack: [String]) {
		queue.async {
			let semaphore = DispatchSemaphore(value: 0)
			if let index = indexOfMismatch(lhs: self.currentStack, rhs: presentationStack) {
				var count = self.viewControllerCount()
				while count > index {
					let top = self.topViewController()
					DispatchQueue.main.async {
						top.dismiss(animated: count == index + 1, completion: {
							semaphore.signal()
						})
					}
					semaphore.wait()
					count -= 1
				}
			}

			var count = self.viewControllerCount()
			while count < presentationStack.count {
				guard let vc = self.factories[presentationStack[count]]?() else { fatalError("can't construct view controller \(presentationStack[count])") }
				let top = self.topViewController()
				DispatchQueue.main.async {
					top.present(vc, animated: count == presentationStack.count - 1, completion: {
						semaphore.signal()
					})
				}
				semaphore.wait()
				count += 1
			}
		}
	}

	private var unsubscriber: Unsubscriber? = nil
	private var currentStack: [String] = []
	private let queue = DispatchQueue(label: "view_controller_presenter")
	private let factories: [String: () -> UIViewController]
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

func indexOfMismatch<T>(lhs: [T], rhs: [T]) -> Int?
	where T: Equatable {
		let combine = Array(zip(lhs, rhs))
		return combine.index(where: { $0.0 != $0.1 })
}
