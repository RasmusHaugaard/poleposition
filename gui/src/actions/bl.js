import {init as initFlasher} from '../services/flasher'

export const STATUS = {
	PROGRAMMING: "PROGRAMMING",
	NOT_PROGRAMMING: "NOT_PROGRAMMING"
}

export const BL_PROGRAM = "BL_PROGRAM"
export const blProgram = () => {
	return (dispatch) => {
		dispatch(blProgramming())
		initFlasher(
			() => {
				dispatch(blSuccess())
			},
			(progress) => {
				dispatch(blProgess(progress))
			}
		)
	}
}

export const BL_PROGRAMMING = "BL_PROGRAMMING"
export const blProgramming = () => {
	return {
		type: BL_PROGRAMMING
	}
}

export const BL_PROGRESS = "BL_PROGRESS"
export const blProgess = (progress) => {
	return {
		type: BL_PROGRESS,
		progress
	}
}

export const BL_SUCCESS = "BL_SUCCESS"
export const blSuccess = () => {
	return {
		type: BL_SUCCESS
	}
}

export const BL_ERROR = "BL_ERROR"
export const blError = () => {
	return {
		type: BL_ERROR
	}
}
