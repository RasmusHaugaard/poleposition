export default function mainRoute(state = "TERMINAL", action){
	switch (action.type){
		case "MAIN_ROUTE":
			return action.route;
		default:
			return state;
	}
}
