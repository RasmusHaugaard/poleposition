import {BL_PROGRAMMING, BL_SUCCESS, BL_ERROR, BL_PROGRESS, STATUS} from '../actions/bl'

export default function bl(
	state = {
		status: STATUS.NOT_PROGRAMMING,
		progress: 0
	},
	action){

	switch (action.type){
		case BL_PROGRAMMING:
			return {
				status: STATUS.PROGRAMMING,
				progress: 0
			}
		case BL_SUCCESS:
		case BL_ERROR:
			return {
				status: STATUS.NOT_PROGRAMMING,
				progress: 0
			}
		case BL_PROGRESS:
			return {
				status: STATUS.PROGRAMMING,
				progress: action.progress
			}
		default:
			return state
	}
}
