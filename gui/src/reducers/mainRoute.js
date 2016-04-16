export default function mainRoute(state = "DEFAULT_ROUTE", action){
	switch (action.type){
		case "MAIN_ROUTE":
			return action.route;
		default:
			return state;
	}
}
