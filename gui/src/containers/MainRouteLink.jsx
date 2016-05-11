import React, {PropTypes} from 'react'
import {connect} from 'react-redux'
import {MenuItem} from 'material-ui'
import {mainRoute} from '../actions/mainRoute'

let MainRouteLink = ({route, onClick}) => (
	<MenuItem onClick={onClick}>{route}</MenuItem>
)

MainRouteLink.propTypes = {
	route: PropTypes.string.isRequired,
	onClick: PropTypes.func.isRequired
}

const mapStateToProps = (state, ownProps) => {
  return {
    route: ownProps.route
  }
}

const mapDispatchToProps = (dispatch, ownProps) => {
  return {
    onClick: () => {
      dispatch(mainRoute(ownProps.route))
    }
  }
}

MainRouteLink = connect(
	mapStateToProps,
	mapDispatchToProps
)(MainRouteLink)

export default MainRouteLink
