export const MAIN_ROUTE = "MAIN_ROUTE"
export const mainRoute = (route) => {
	return {
		type: MAIN_ROUTE,
		route: route.toUpperCase()
	}
}
