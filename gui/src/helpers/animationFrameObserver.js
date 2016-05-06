import Rx from 'rx'

const request = window.requestAnimationFrame
const	cancel = window.cancelAnimationFrame

export default function(){
	return Rx.Observable.create(function (observer) {
			var requestId,
					startTime = Date.now(),
					callback = function (currentTime) {
							if (typeof requestId === "number") {
									requestId = request(callback);
							}
							observer.onNext(Math.max(0, currentTime - startTime))
							startTime = currentTime
					}
			requestId = request(callback)
			return function () {
					if (typeof requestId === "number") {
							var r = requestId
							requestId = false
							cancel(r)
					}
			}
	})
	}
}
