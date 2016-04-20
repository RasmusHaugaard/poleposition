import parseIHex from './parseIHex'
import {blSuccess, blError} from '../actions/bl'
import {send as btSend} from './bluetooth'

const DEBUG = false

const PAGESIZE = 64
const PAGESIZEB = PAGESIZE * 2
const PAGECOUNT = 256
const APP_PAGECOUNT = 224

const REPROGRAM_CODE = 88
const pf_write_page_code = 89
const pf_erase_page_code = 90
const pf_file_end_code = 91
const RESET_CODE = 92

const BUFFERSIZE = 1000
if (BUFFERSIZE < 3 + PAGESIZEB) throw("BUFFERSIZE skal være minimum 3 + PAGESIZEB!!!")

const ERASE_PAGE_BYTE_COUNT = 3
const WRITE_PAGE_BYTE_COUNT = 3 + PAGESIZEB

const AVR_WAS_RESET = 200
const PERMISSION_GRANTED = 203
const PAGE_WRITTEN = 204
const PAGE_ERASED = 205
const RESETTING = 206

const STATUS = {
	waitingForPermission: 0,
	writingPage: 1,
	erasingPage: 2,
	waitingForReset: 3
};

export const init = (success, progress) => {
	window.flasher = new Flasher(success, progress)
}

export const getHex = (callback) => {
	window.folderEntry.getFile('avr/build/program.hex', {create:false}, fileEntry => {
		fileEntry.file(file => {
			let fileReader = new FileReader()
			fileReader.onload = () => {
				if (typeof callback === "function") callback(fileReader.result)
			}
			fileReader.onerror = () => {
				throw("Read error!!")
			}
			fileReader.readAsText(file)
		})
	})
}

class Flasher {
	constructor(successCallback, progressCallback){
		this.pageIndex = 0
		this.noMorePages = false
		this.bytesInBuffer = 0
		this.successCallback = successCallback
		this.progressCallback = progressCallback
		getHex((hex) => {
			this.pages = parseIHex(hex, PAGESIZE)
			this.start()
		})
	}

	start(){
		this.startTime = new Date()
		this.status = [STATUS.waitingForPermission]
		btSend([REPROGRAM_CODE], this.handleBtCallback)
		this.bytesInBuffer++
	}

	handleBtCallback(success){
		if(!success){
			window.speak("I am sorry master. Something went wrong while programming the controller.")
			window.store.dispatch(blError())
		}
	}

	decreaseBytesInBuffer(byteCount){
		this.bytesInBuffer -= byteCount
		if (DEBUG) console.log("bytesInBuffer:", this.bytesInBuffer)
		if (DEBUG) console.log("noMorePages:", this.noMorePages)
		if (this.noMorePages){
			if (this.bytesInBuffer === 0) this.complete()
		}else{
			this.sendNextPage()
		}
	}

	sendNextPage(){
		if (this.pageIndex === APP_PAGECOUNT) throw("No more pages to send!")
		let page = this.pages[this.pageIndex]
		let bytesLeftInBuffer = BUFFERSIZE - this.bytesInBuffer
		if (typeof page === 'undefined'){
			if(bytesLeftInBuffer < ERASE_PAGE_BYTE_COUNT) return
			this.erasePage(this.pageIndex)
		}else{
			if(bytesLeftInBuffer < WRITE_PAGE_BYTE_COUNT) return
			this.writePage(this.pageIndex, page)
		}
		this.pageIndex++
		if(this.pageIndex === APP_PAGECOUNT){
			this.noMorePages = true
		}else{
			this.sendNextPage()
		}
	}

	receiveByte(byte){
		//if (DEBUG) console.log("ReceiveByte flasher")
		let curStatus = this.status.shift()
		switch (curStatus) {
			case STATUS.waitingForPermission:
				if (byte === PERMISSION_GRANTED){
					if (DEBUG) console.log("Permission granted..")
					this.decreaseBytesInBuffer(1)
					break;
				}
				throw("Received unexpected byte!", byte)
			case STATUS.writingPage:
				if (byte === PAGE_WRITTEN){
					if (DEBUG) console.log("Page Successfully flashed..")
					this.decreaseBytesInBuffer(WRITE_PAGE_BYTE_COUNT)
					break;
				}
				throw("Received unexpected byte!", byte)
			case STATUS.erasingPage:
				if (byte === PAGE_ERASED){
					if (DEBUG) console.log("Page Successfully erased..")
					this.decreaseBytesInBuffer(ERASE_PAGE_BYTE_COUNT)
					break;
				}
				throw("Received unexpected byte!", byte)
			case STATUS.waitingForResetting:
				if (byte === RESETTING){
					if (DEBUG) console.log("Resetting avr..")
					this.status.push(STATUS.waitingForReset)
					break;
				}
				throw("Received unexpected byte!", byte)
			case STATUS.waitingForReset:
				if (byte === AVR_WAS_RESET){
					this.successCallback(this.completionTime)
					break;
				}
				throw("Received unexpected byte!", byte)
			default:
				throw("Status: '" + status + "' not expected..")
		}
	}

	complete(){
		btSend([RESET_CODE], this.handleBtCallback)
		if (DEBUG) console.log("Programming complete with no errors.")
		if(DEBUG) console.log("Asking for reset..")
		this.status.push(STATUS.waitingForResetting)
		var completeTime = new Date()
		this.completionTime = completeTime - this.startTime
		window.speak("Uploaded your program to the controller in " + (this.completionTime / 1000).toFixed(2).toString() +  " seconds.")
	}

	erasePage(pageIndex){
		this.bytesInBuffer += ERASE_PAGE_BYTE_COUNT
		let address = PAGESIZEB * pageIndex
		let ZL = address & 0xFF
		let ZH = address >> 8
		if (DEBUG) console.log("Erasing page", pageIndex + "..", ZH, ZL)
		this.status.push(STATUS.erasingPage)
		btSend([pf_erase_page_code, ZL, ZH], this.handleBtCallback)
	}

	writePage(pageIndex, page){
		this.bytesInBuffer += WRITE_PAGE_BYTE_COUNT
		let address = PAGESIZEB * pageIndex
		let ZL = address & 0xFF
		let ZH = address >> 8
		this.status.push(STATUS.writingPage)
		if (DEBUG) console.log("Writing page", pageIndex + "..", ZH, ZL)
		btSend([pf_write_page_code, ZL, ZH], this.handleBtCallback)
		btSend(page.map((val) => {
			return (typeof val === "undefined") ? 255 : val
		}), this.handleBtCallback)
		if (DEBUG) console.log("Sent", page.length, "bytes..")
	}
}
