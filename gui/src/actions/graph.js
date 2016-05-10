export const ADD_DATA_TO_GRAPH = "ADD_DATA_TO_GRAPH"
export const addDataToGraph = (data) => {
	return {
		type: ADD_DATA_TO_GRAPH,
		data
	}
}

export const CLEAR_GRAPH = "CLEAR_GRAPH"
export const clearGraph = (data) => {
	return {
		type: CLEAR_GRAPH
	}
}
