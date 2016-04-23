import {ADD_DATA_TO_GRAPH, CLEAR_GRAPH} from '../actions/graph'

const MAX_VALUES = 20000

export default function graph(
	state = [],
	action
){
	switch (action.type){
		case ADD_DATA_TO_GRAPH:
			let {name, point} = action.data
			let nameRow = state.filter(row => row.name === name)[0]
			if(!nameRow){
				return [
					...state,
					{name, values:[point]}
				]
			}else{
				let i = state.indexOf(nameRow)
				return [
					...state.slice(0, i),
					{...nameRow, values: [...nameRow.values.slice(- MAX_VALUES + 1), point]},
					...state.slice(i + 1)
				]
			}
		case CLEAR_GRAPH:
			return []
		default:
			return state
	}
}
