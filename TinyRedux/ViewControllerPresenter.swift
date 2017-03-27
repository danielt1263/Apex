//
//  ViewControllerPresenter.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import UIKit


public typealias ViewControllerFactory = [String: () -> UIViewController]

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
				let top = topViewController()
				guard self.viewControllers.values.contains(where: { $0.value == top }) else { return }
				assert(top != self.rootViewController, "Can't dismiss the root view controller. Did you forget fill in the alert IDs?")
				DispatchQueue.main.async {
					top.dismiss(animated: true, completion: {
						semaphore.signal()
					})
				}
				semaphore.wait()
			}
			
			func push(id: String) {
				guard let vc = self.factory[id]?() else { fatalError("can't construct view controller \(id)") }
				self.viewControllers[id] = WeakBox(value: vc)
				let top = topViewController()
				DispatchQueue.main.async {
					top.present(vc, animated: true, completion: {
						semaphore.signal()
					})
				}
				semaphore.wait()
			}
			
			self.cull()
			popPush(current: self.currentStack, target: presentationStack, pop: pop, push: push)
			self.currentStack = presentationStack
		}
	}

	private var unsubscriber: Unsubscriber? = nil
	private var currentStack: [String] = []
	private var viewControllers: [String: WeakBox<UIViewController>] = [:]
	private let queue = DispatchQueue(label: "view_controller_presenter")
	private let factory: ViewControllerFactory
	private let rootViewController: UIViewController

	private func cull() {
		for (key, box) in viewControllers {
			if box.value == nil {
				viewControllers.removeValue(forKey: key)
			}
		}
		while let i = currentStack.index(where: { !viewControllers.keys.contains($0) }) {
			currentStack.remove(at: i)
		}
	}

}

protocol ReferenceObject: class { }

struct WeakBox<T> where T: ReferenceObject {
	weak var value: T?
}

extension UIViewController: ReferenceObject { }

func topViewController() -> UIViewController {
	guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else { fatalError("No view controller present in app?") }
	var result = rootViewController
	while let vc = result.presentedViewController {
		result = vc
	}
	return result
}
